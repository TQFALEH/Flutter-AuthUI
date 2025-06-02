class ErrorTranslator {
  // ترجمة رسائل الخطأ من الإنجليزية إلى العربية
  static String translate(String errorMessage) {
    // تنظيف رسالة الخطأ
    String cleanedError = errorMessage.toLowerCase();
    
    // إزالة أي معلومات تقنية إضافية
    if (cleanedError.contains(':')) {
      cleanedError = cleanedError.split(':').last.trim();
    }
    
    // قاموس الترجمة
    final Map<String, String> errorTranslations = {
      // أخطاء المصادقة
      'invalid credentials': 'بيانات الاعتماد غير صالحة، يرجى التحقق من البريد الإلكتروني وكلمة المرور',
      'invalid email': 'البريد الإلكتروني غير صالح',
      'invalid password': 'كلمة المرور غير صالحة',
      'email already exists': 'البريد الإلكتروني مستخدم بالفعل',
      'user not found': 'لم يتم العثور على المستخدم',
      'password too short': 'كلمة المرور قصيرة جدًا، يجب أن تكون 8 أحرف على الأقل',
      'weak password': 'كلمة المرور ضعيفة، يرجى استخدام مزيج من الأحرف والأرقام والرموز',
      'wrong password': 'كلمة المرور غير صحيحة',
      'user already exists': 'المستخدم موجود بالفعل',
      'unauthorized': 'غير مصرح به، يرجى تسجيل الدخول مرة أخرى',
      'session expired': 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
      
      // أخطاء الشبكة
      'network error': 'خطأ في الاتصال بالشبكة، يرجى التحقق من اتصالك بالإنترنت',
      'connection failed': 'فشل الاتصال، يرجى المحاولة مرة أخرى',
      'timeout': 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
      'server error': 'خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقًا',
      
      // أخطاء قاعدة البيانات
      'document not found': 'لم يتم العثور على المستند',
      'permission denied': 'تم رفض الإذن، ليس لديك صلاحية للقيام بهذا الإجراء',
      'database error': 'خطأ في قاعدة البيانات، يرجى المحاولة مرة أخرى',
      
      // أخطاء التخزين
      'file too large': 'الملف كبير جدًا، يرجى تحميل ملف أصغر',
      'invalid file type': 'نوع الملف غير صالح، يرجى تحميل ملف بتنسيق مدعوم',
      'storage error': 'خطأ في التخزين، يرجى المحاولة مرة أخرى',
      
      // أخطاء عامة
      'unknown error': 'حدث خطأ غير معروف، يرجى المحاولة مرة أخرى',
      'operation failed': 'فشلت العملية، يرجى المحاولة مرة أخرى',
      'invalid request': 'طلب غير صالح، يرجى التحقق من المعلومات المدخلة',
      'bad request': 'طلب غير صالح، يرجى التحقق من المعلومات المدخلة',
      'not found': 'لم يتم العثور على الموارد المطلوبة',
      'internal error': 'خطأ داخلي، يرجى المحاولة مرة أخرى لاحقًا',
      
      // أخطاء Appwrite محددة
      'general_argument_invalid': 'معلومات غير صالحة، يرجى التحقق من البيانات المدخلة',
      'general_unauthorized_scope': 'غير مصرح لك بالقيام بهذا الإجراء',
      'user_unauthorized': 'غير مصرح به، يرجى تسجيل الدخول مرة أخرى',
      'user_invalid_credentials': 'بيانات الاعتماد غير صالحة، يرجى التحقق من البريد الإلكتروني وكلمة المرور',
      'user_already_exists': 'المستخدم موجود بالفعل',
      'user_not_found': 'لم يتم العثور على المستخدم',
      'user_password_mismatch': 'كلمة المرور غير متطابقة',
      'user_email_already_exists': 'البريد الإلكتروني مستخدم بالفعل',
      'user_password_reset_required': 'يجب إعادة تعيين كلمة المرور',
      'user_blocked': 'تم حظر المستخدم، يرجى الاتصال بالدعم',
      'user_session_already_exists': 'جلسة المستخدم موجودة بالفعل',
      'user_invalid_token': 'رمز غير صالح، يرجى تسجيل الدخول مرة أخرى',
      'user_jwt_invalid': 'رمز JWT غير صالح، يرجى تسجيل الدخول مرة أخرى',
      'user_session_not_found': 'لم يتم العثور على جلسة المستخدم، يرجى تسجيل الدخول مرة أخرى',
      'user_phone_already_exists': 'رقم الهاتف مستخدم بالفعل',
      'user_phone_not_found': 'لم يتم العثور على رقم الهاتف',
    };
    
    // البحث عن ترجمة مناسبة
    for (var key in errorTranslations.keys) {
      if (cleanedError.contains(key)) {
        return errorTranslations[key]!;
      }
    }
    
    // إذا لم يتم العثور على ترجمة، إرجاع رسالة عامة
    return 'حدث خطأ: $errorMessage';
  }
  
  // استخراج رسالة الخطأ من استثناء Appwrite
  static String getAppwriteErrorMessage(dynamic error) {
    try {
      // محاولة استخراج رسالة الخطأ من كائن الاستثناء
      String errorMessage = error.toString();
      
      // البحث عن نمط رسالة الخطأ في Appwrite
      RegExp regExp = RegExp(r'message: (.*?)(,|\))');
      var match = regExp.firstMatch(errorMessage);
      
      if (match != null && match.groupCount >= 1) {
        return translate(match.group(1)!);
      }
      
      // إذا لم يتم العثور على نمط محدد، ترجمة الرسالة الكاملة
      return translate(errorMessage);
    } catch (e) {
      // في حالة حدوث خطأ أثناء معالجة الاستثناء
      return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
    }
  }
}
