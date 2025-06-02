// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, unused_local_variable, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/models.dart' as models;
import '../appWrite/appwrite_client.dart';
import '../utils/error_translator.dart';
import '../providers/theme_provider.dart';

/// شاشة الملف الشخصي للمستخدم
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // متغيرات التحكم في حقول النص
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  // متغيرات حالة الشاشة
  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPassword = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // تحميل بيانات المستخدم عند بدء الشاشة
  }

  @override
  void dispose() {
    // تنظيف المتحكمات عند إغلاق الشاشة
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  /// دالة تحميل بيانات المستخدم
  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  /// دالة تحديث اسم المستخدم
  Future<void> _updateName() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال الاسم';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await AppwriteClient.updateName(_nameController.text.trim());
      await authProvider.initialize();

      setState(() {
        _isEditingName = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث الاسم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorTranslator.getAppwriteErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// دالة تحديث البريد الإلكتروني
  Future<void> _updateEmail() async {
    if (_emailController.text.isEmpty ||
        _currentPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال البريد الإلكتروني وكلمة المرور الحالية';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await AppwriteClient.updateEmail(
        _emailController.text.trim(),
        _currentPasswordController.text,
      );
      await authProvider.initialize();

      setState(() {
        _isEditingEmail = false;
        _currentPasswordController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث البريد الإلكتروني بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorTranslator.getAppwriteErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// دالة تحديث كلمة المرور
  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال كلمة المرور الحالية والجديدة';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AppwriteClient.updatePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      setState(() {
        _isEditingPassword = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث كلمة المرور بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorTranslator.getAppwriteErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// دالة تسجيل الخروج
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const mainColor = Color(0xFF7c7be6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w500),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return Center(
              child: Text(
                'لم يتم العثور على بيانات المستخدم',
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDark
                                ? theme.colorScheme.surface
                                : Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey[400],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: mainColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: mainColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF392525) : Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: isDark ? Color(0xFFFF8A80) : Colors.red[900],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'المعلومات الشخصية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                _buildProfileOption(
                  icon: Icons.person,
                  title: 'تعديل الملف الشخصي',
                  onTap: () {
                    _showEditNameDialog(context, user);
                  },
                ),
                _buildProfileOption(
                  icon: Icons.lock,
                  title: 'تغيير كلمة المرور',
                  onTap: () {
                    _showChangePasswordDialog(context);
                  },
                ),
                _buildProfileOption(
                  icon: Icons.email,
                  title: 'تغيير البريد الإلكتروني',
                  onTap: () {
                    _showChangeEmailDialog(context, user);
                  },
                ),
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'مركز المساعدة',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('هذه الميزة غير متوفرة حاليًا')),
                    );
                  },
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                              activeColor: mainColor,
                            );
                          },
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'الوضع الليلي',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Theme.of(context).brightness == Brightness.dark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: mainColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  margin: EdgeInsets.all(16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Color(0xFF381F1F) : Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isDark ? 0 : 2,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: isDark ? Color(0xFFFF8A80) : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// دالة بناء خيار الملف الشخصي
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Color(0xFF7c7be6).withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[400],
            ),
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Color(0xFF7c7be6).withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 23,
                color: Color(0xFF7c7be6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// دالة عرض نافذة تعديل الاسم
  void _showEditNameDialog(BuildContext context, models.User user) {
    _nameController.text = user.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل الاسم', textAlign: TextAlign.right),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'الاسم',
            border: OutlineInputBorder(),
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateName();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7c7be6),
            ),
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  /// دالة عرض نافذة تغيير البريد الإلكتروني
  void _showChangeEmailDialog(BuildContext context, models.User user) {
    _emailController.text = user.email;
    _currentPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تغيير البريد الإلكتروني', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني الجديد',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الحالية',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textAlign: TextAlign.right,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateEmail();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7c7be6),
            ),
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  /// دالة عرض نافذة تغيير كلمة المرور
  void _showChangePasswordDialog(BuildContext context) {
    _currentPasswordController.clear();
    _newPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تغيير كلمة المرور', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الحالية',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textAlign: TextAlign.right,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updatePassword();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7c7be6),
            ),
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
