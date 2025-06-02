import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/meal_provider.dart';
import '../appWrite/appwrite_client.dart' as appwrite;

class EditMealScreen extends StatefulWidget {
  final dynamic meal;

  const EditMealScreen({Key? key, required this.meal}) : super(key: key);

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _mealNameController;
  late TextEditingController _carbsController;
  late TextEditingController _restaurantNameController;
  late TextEditingController _notesController;

  bool _isSubmitting = false;
  String? _errorMessage;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _mealNameController =
        TextEditingController(text: widget.meal.data['mealName']);
    _carbsController =
        TextEditingController(text: widget.meal.data['carbs'].toString());
    _restaurantNameController =
        TextEditingController(text: widget.meal.data['restaurantName'] ?? '');
    _notesController =
        TextEditingController(text: widget.meal.data['notes'] ?? '');
    _currentImageUrl = widget.meal.data['imageUrl'];
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _carbsController.dispose();
    _restaurantNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // التقاط صورة من الكاميرا
  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
        _currentImageUrl = null;
      });
    }
  }

  // اختيار صورة من المعرض
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _currentImageUrl = null;
      });
    }
  }

  // عرض خيارات اختيار الصورة
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر مصدر الصورة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'الكاميرا',
                    onTap: () {
                      Navigator.pop(context);
                      _takePicture();
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'المعرض',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // بناء خيار مصدر الصورة
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const three = Color(0xFF7c7be6);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: three.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: three,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      String? imageUrl = _currentImageUrl;

      // رفع الصورة الجديدة إذا تم اختيارها
      if (_selectedImage != null) {
        try {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

          final result = await FlutterImageCompress.compressWithFile(
            _selectedImage!.absolute.path,
            minWidth: 1024,
            minHeight: 1024,
            quality: 85,
            format: CompressFormat.jpeg,
          );

          if (result == null) {
            throw Exception('فشل في ضغط الصورة');
          }

          final tempDir = Directory.systemTemp;
          final tempFile =
              await File('${tempDir.path}/$fileName').writeAsBytes(result);

          imageUrl = await appwrite.AppwriteClient.uploadMealImage(
            tempFile.path,
            fileName,
          );

          await tempFile.delete();
        } catch (uploadError) {
          print('خطأ في رفع الصورة: $uploadError');
          setState(() {
            _errorMessage = 'فشل في رفع الصورة: ${uploadError.toString()}';
            _isSubmitting = false;
          });
          return;
        }
      }

      // تحديث بيانات الوجبة
      final success = await appwrite.AppwriteClient.updateMeal(
        mealId: widget.meal.$id,
        mealName: _mealNameController.text.trim(),
        carbs: double.parse(_carbsController.text),
        restaurantName: _restaurantNameController.text.trim().isNotEmpty
            ? _restaurantNameController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        imageUrl: imageUrl,
      );

      if (success && mounted) {
        // تحديث الواجهة
        final mealProvider = Provider.of<MealProvider>(context, listen: false);
        await mealProvider.loadMeals();

        Navigator.of(context)
            .pop(true); // Return true to indicate successful update
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const two = Color(0xFFF5F5F5);
    const three = Color(0xFF7c7be6);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // زر الرجوع
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 100),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'تعديل الوجبة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 30),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 8),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // اسم الوجبة
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: two,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: TextFormField(
                          controller: _mealNameController,
                          style: TextStyle(),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor: three,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            fillColor: three,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            focusColor: Colors.transparent,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: 'اسم الوجبة',
                            hintStyle: TextStyle(
                                color: Color(0xFFa3a3a3), fontSize: 17),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم الوجبة';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      // كمية الكربوهيدرات
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: two,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: TextFormField(
                          controller: _carbsController,
                          style: TextStyle(),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          cursorColor: three,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            fillColor: three,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            focusColor: Colors.transparent,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: 'كمية الكربوهيدرات',
                            hintStyle: TextStyle(
                                color: Color(0xFFa3a3a3), fontSize: 17),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كمية الكربوهيدرات';
                            }
                            try {
                              final number = double.parse(value);
                              if (number <= 0) {
                                return 'الرجاء إدخال رقم موجب';
                              }
                            } catch (e) {
                              return 'الرجاء إدخال رقم صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      // اسم المطعم
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: two,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _restaurantNameController,
                          style: TextStyle(),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor: three,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            fillColor: three,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            focusColor: Colors.transparent,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: 'اسم المطعم (اختياري)',
                            hintStyle: TextStyle(
                                color: Color(0xFFa3a3a3), fontSize: 17),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // ملاحظات
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: two,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _notesController,
                          style: TextStyle(),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: 3,
                          cursorColor: three,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            fillColor: three,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            focusColor: Colors.transparent,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: 'ملاحظات (اختياري)',
                            hintStyle: TextStyle(
                                color: Color(0xFFa3a3a3), fontSize: 17),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // صورة الوجبة
                      GestureDetector(
                        onTap: _showImageSourceOptions,
                        child: Container(
                          width: 342,
                          height: 200,
                          decoration: BoxDecoration(
                            color: two,
                            borderRadius: BorderRadius.circular(12),
                            image: (_selectedImage != null)
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : (_currentImageUrl != null)
                                    ? DecorationImage(
                                        image: NetworkImage(_currentImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: (_selectedImage == null &&
                                  _currentImageUrl == null)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'تغيير الصورة',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 40),

                      // زر الحفظ
                      SizedBox(
                        width: 340,
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(three),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 6, horizontal: 95),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _updateMeal,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 30,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'حفظ التغييرات',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
