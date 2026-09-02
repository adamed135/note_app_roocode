// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get notesApp => 'تطبيق الملاحظات';

  @override
  String get notes => 'الملاحظات';

  @override
  String get editNote => 'تعديل ملاحظة';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get title => 'العنوان';

  @override
  String get content => 'النص';

  @override
  String get pickImage => 'اختيار صورة';

  @override
  String get search => 'بحث...';

  @override
  String get noNotes => 'لا توجد ملاحظات';

  @override
  String get tasksToDo => 'المهام المطلوبة';

  @override
  String get all => 'الكل';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get completed => 'مكتمل';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get dueTime => 'وقت الاستحقاق';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get taskReminder => 'تذكير بالمهمة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get receiveNotifications => 'تلقي إشعارات تذكير المهام';

  @override
  String get testNotification => 'اختبار الإشعار';

  @override
  String get sendTestNotification => 'إرسال إشعار اختبار للتحقق من الأذونات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get confirmDelete => 'هل أنت متأكد من حذف هذه المهمة؟';

  @override
  String get titleAndDescriptionRequired => 'العنوان والوصف مطلوبان';

  @override
  String taskDeleted(Object title) {
    return 'تم حذف $title';
  }

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get french => 'الفرنسية';

  @override
  String get arabic => 'العربية';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';
}
