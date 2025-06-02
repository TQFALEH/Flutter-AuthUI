// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, unused_local_variable, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../providers/meal_provider.dart';
import '../appWrite/appwrite_client.dart' as appwrite;

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({Key? key}) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  final _carbsController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  File? _selectedImage;

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

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      String? imageUrl;

      // رفع الصورة إذا تم اختيارها
      if (_selectedImage != null) {
        try {
          // Generate a unique filename with .jpg extension
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Compress the image before upload
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

          // Save compressed image to temporary file
          final tempDir = Directory.systemTemp;
          final tempFile =
              await File('${tempDir.path}/$fileName').writeAsBytes(result);

          // Upload the compressed image
          imageUrl = await appwrite.AppwriteClient.uploadMealImage(
            tempFile.path,
            fileName,
          );

          // Clean up temporary file
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

      final success = await mealProvider.addMeal(
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
        Navigator.of(context).pop();
      } else if (mounted) {
        setState(() {
          _errorMessage = mealProvider.error ?? 'فشل في حفظ الوجبة';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // إغلاق لوحة المفاتيح عند النقر خارج حقول الإدخال
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    const one = Color.fromARGB(213, 32, 32, 32);
    const two = Color(0xFFF5F5F5);
    const three = Color(0xFF7c7be6);

    return Consumer<MealProvider>(
      builder: (context, mealProvider, child) => GestureDetector(
        onTap: _dismissKeyboard,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
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
                  reverse: false,
                  child: Column(
                    children: [
                      Text(
                        'إضافة وجبة',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // عرض رسالة الخطأ إذا وجدت
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
                              margin: EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
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
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
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
                              margin: EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: TextFormField(
                                controller: _carbsController,
                                style: TextStyle(),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                textInputAction: TextInputAction.next,
                                cursorColor: three,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  fillColor: three,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  focusColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
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

                            // اسم المطعم (اختياري)
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: two,
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
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
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  hintText: 'اسم المطعم (اختياري)',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFa3a3a3), fontSize: 17),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // ملاحظات (اختياري)
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: two,
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
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
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
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
                                  image: _selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(_selectedImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _selectedImage == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'إضافة صورة',
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
                            SizedBox(height: 110),

                            // زر الحفظ
                            SizedBox(
                              width: 340,
                              child: TextButton(
                                  style: ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(9))),
                                      backgroundColor:
                                          WidgetStatePropertyAll(three),
                                      padding: WidgetStatePropertyAll(
                                          EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 95))),
                                  onPressed: _isSubmitting ? null : _saveMeal,
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
                                            'حفظ الوجبة',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2),
                                          ),
                                  )),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
