import 'providers/language_notifier.dart';

class AppLocalizations {
  static const Map<String, Map<AppLanguage, String>> _localized = {
    // ----- ACCOUNT / COMMON -----
    'account': {
      AppLanguage.latin: 'Account',
      AppLanguage.arabic: 'الحساب',
    },
    'welcome_back': {
      AppLanguage.latin: 'Welcome to Ellil',
      AppLanguage.arabic: 'أهلاً بك في إيليل',
    },
    'featured_books': {
      AppLanguage.latin: 'Featured Books',
      AppLanguage.arabic: 'أجدد الكتب',
    },
    'continue_listening': {
      AppLanguage.latin: 'Continue Listening',
      AppLanguage.arabic: 'مواصلة الاستماع',
    },
    'recommended_books': {
      AppLanguage.latin: 'Recommended Books',
      AppLanguage.arabic: 'الكتب الموصى بها',
    },
    'explore': {
      AppLanguage.latin: 'Choose By Category',
      AppLanguage.arabic: 'إختر الفئة بحسب النوع',
    },
    'your_library': {
      AppLanguage.latin: 'Your Library',
      AppLanguage.arabic: 'مكتبتك',
    },
    'search_placeholder': {
      AppLanguage.latin: 'Search your books',
      AppLanguage.arabic: 'ابحث في كتبك',
    },
    'profile': {
      AppLanguage.latin: 'Profile',
      AppLanguage.arabic: 'حسابي',
    },
    'ellil': {
      AppLanguage.latin: 'Ellil',
      AppLanguage.arabic: 'إليل',
    },
    'subscription': {
      AppLanguage.latin: 'Subscription',
      AppLanguage.arabic: 'الاشتراك',
    },
    'subscription_plans': {
      AppLanguage.latin: 'Subscription Plans',
      AppLanguage.arabic: 'خطط الاشتراك',
    },
    'sub_active': {
      AppLanguage.latin: 'Active',
      AppLanguage.arabic: 'اشتراك نشط',
    },
    'playback_settings': {
      AppLanguage.latin: 'Playback Settings',
      AppLanguage.arabic: 'إعدادات التشغيل',
    },
    'autoplay_title': {
      AppLanguage.latin: 'Auto-play next chapter',
      AppLanguage.arabic: 'تشغيل الفصل التالي تلقائيًا',
    },
    'autoplay_subtitle': {
      AppLanguage.latin:
          'Automatically play the next chapter when current ends.',
      AppLanguage.arabic:
          'تشغيل الفصل التالي تلقائيًا عند انتهاء الفصل الحالي.',
    },
    'subscribed': {
      AppLanguage.latin: 'Subscribed',
      AppLanguage.arabic: 'مشترك',
    },
    'subscribe_now': {
      AppLanguage.latin: 'Subscribe Now',
      AppLanguage.arabic: 'اشترك الآن',
    },
    'no_active_subscription': {
      AppLanguage.latin: 'No active subscription',
      AppLanguage.arabic: 'لا يوجد اشتراك نشط',
    },
    'plan': {
      AppLanguage.latin: 'Plan',
      AppLanguage.arabic: 'اسم الاشتراك',
    },
    'valid_until': {
      AppLanguage.latin: 'Valid Until',
      AppLanguage.arabic: 'صالحة حتى',
    },
    'timer_title': {
      AppLanguage.latin: 'Sleep timer',
      AppLanguage.arabic: 'توقيت النوم',
    },
    'timer_subtitle': {
      AppLanguage.latin: 'To turn off sound',
      AppLanguage.arabic: 'لبرمجة إيقاف الصوت',
    },
    'app_settings': {
      AppLanguage.latin: 'App Settings',
      AppLanguage.arabic: 'إعدادات التطبيق',
    },
    'language_title': {
      AppLanguage.latin: 'Arabic Language',
      AppLanguage.arabic: 'اللغة العربية',
    },
    'language_subtitle': {
      AppLanguage.latin: 'Switch between arabic and english languages.',
      AppLanguage.arabic: 'التبديل بين اللغتين العربية والانجليزية.',
    },
    'dark_mode_title': {
      AppLanguage.latin: 'Dark Mode',
      AppLanguage.arabic: 'الوضع الليلي',
    },
    'dark_mode_subtitle': {
      AppLanguage.latin: 'Switch between dark and light themes.',
      AppLanguage.arabic: 'التبديل بين السمات الداكنة والفاتحة.',
    },
    'download_title': {
      AppLanguage.latin: 'Download on WI-FI only',
      AppLanguage.arabic: 'التنزيل عبر شبكة WI-FI فقط',
    },
    'download_subtitle': {
      AppLanguage.latin: 'Save mobile data by downloading only on WI-FI',
      AppLanguage.arabic:
          'توفير بيانات الهاتف المحمول عن طريق التنزيل فقط على شبكة WI-FI',
    },
    'notifications_title': {
      AppLanguage.latin: 'Notifications',
      AppLanguage.arabic: 'إشعارات',
    },
    'notifications_subtitle': {
      AppLanguage.latin: 'Manage notification preferences',
      AppLanguage.arabic: 'إدارة تفضيلات الإخطار',
    },
    'sign_out': {
      AppLanguage.latin: 'Sign Out',
      AppLanguage.arabic: 'تسجيل الخروج',
    },
    // book zone tabs
    'books': {
      AppLanguage.latin: 'Books',
      AppLanguage.arabic: 'الكتب',
    },
    'authors': {
      AppLanguage.latin: 'Authors',
      AppLanguage.arabic: 'المؤلفون',
    },
    'narrators': {
      AppLanguage.latin: 'Narrators',
      AppLanguage.arabic: 'الرواة',
    },
    'publishers': {
      AppLanguage.latin: 'Publishers',
      AppLanguage.arabic: 'الناشرون',
    },

    'publisher': {
      AppLanguage.latin: 'Publisher',
      AppLanguage.arabic: 'الناشر',
    },

    'about': {
      AppLanguage.latin: 'About',
      AppLanguage.arabic: 'السيرة الذاتية',
    },

    'chapters': {
      AppLanguage.latin: 'Chapters',
      AppLanguage.arabic: 'فصول',
    },

    'no_chapters': {
      AppLanguage.latin: 'No chapters available',
      AppLanguage.arabic: 'لا توجد فصول متاحة',
    },

    'written_by': {
      AppLanguage.latin: 'Written By',
      AppLanguage.arabic: 'كتب بواسطة',
    },

    'narrated_by': {
      AppLanguage.latin: 'Narrated By',
      AppLanguage.arabic: 'رواه',
    },

    'buy_now': {
      AppLanguage.latin: 'Buy Now',
      AppLanguage.arabic: 'اشتري الآن',
    },

    'history': {
      AppLanguage.latin: 'History',
      AppLanguage.arabic: 'مواصلة الاستماع',
    },

    'start_listening': {
      AppLanguage.latin: 'Start Listening',
      AppLanguage.arabic: 'ابدأ الاستماع',
    },

    'listen_another_time': {
      AppLanguage.latin: 'Listen Book Another Time',
      AppLanguage.arabic: 'استمع للكتاب مرة أخرى',
    },

    'listen_chapter': {
      AppLanguage.latin: 'Listen Chapter',
      AppLanguage.arabic: 'استماع الفصل',
    },

    'start_listen': {
      AppLanguage.latin: 'Do you want to start listening this chapter?',
      AppLanguage.arabic: 'هل تريد أن تبدأ بالاستماع لهذا الفصل؟',
    },

    'relisten_book_title': {
      AppLanguage.latin: 'Re Listen Book',
      AppLanguage.arabic: 'إعادة الاستماع للكتاب',
    },

    'relisten_book_subtitle': {
      AppLanguage.latin:
          'Are you sure you want to re start listening the book?',
      AppLanguage.arabic: 'هل أنت متأكد أنك تريد إعادة الاستماع للكتاب؟',
    },

    // listening zoon
    'continue_to_chapter_title': {
      AppLanguage.latin: 'Continue to next chapter?',
      AppLanguage.arabic: 'الانتقال إلى الفصل التالي؟',
    },

    'continue_to_chapter_subtitle': {
      AppLanguage.latin: 'Do you want to continue to next chapter?',
      AppLanguage.arabic: 'هل تريد الإنتقال إلى الفصل التالي؟',
    },

    'book_completed': {
      AppLanguage.latin: 'Book Completed',
      AppLanguage.arabic: 'اكتمل الكتاب',
    },

    'book_completed_congrats': {
      AppLanguage.latin: 'Congratulations! You have finished this book.',
      AppLanguage.arabic: 'مبروك! لقد انتهيت من قراءة هذا الكتاب.',
    },

    'no': {
      AppLanguage.latin: 'No',
      AppLanguage.arabic: 'لا',
    },

    'yes': {
      AppLanguage.latin: 'Yes',
      AppLanguage.arabic: 'نعم',
    },

    'confirm': {
      AppLanguage.latin: 'Confirm',
      AppLanguage.arabic: 'مؤكد',
    },

    'ok': {
      AppLanguage.latin: 'Ok',
      AppLanguage.arabic: 'حسنا',
    },

    'no_book_selected': {
      AppLanguage.latin: 'No Book Selected',
      AppLanguage.arabic: 'لم يتم تحديد كتاب',
    },

    'no_book_selected_subtext': {
      AppLanguage.latin: 'Please choose a book before navigating to this page.',
      AppLanguage.arabic: 'الرجاء اختيار الكتاب قبل الانتقال إلى هذه الصفحة.',
    },

    'choose_book': {
      AppLanguage.latin: 'Choose Book',
      AppLanguage.arabic: 'اختر كتاب',
    },

    'you_are': {
      AppLanguage.latin: 'You are a',
      AppLanguage.arabic: 'أنت',
    },

    'import_podcast': {
      AppLanguage.latin: 'Import A Podcast',
      AppLanguage.arabic: 'رفع بودكاست',
    },
    'theme_dark': {
      AppLanguage.latin: 'Dark',
      AppLanguage.arabic: 'داكن',
    },
    'theme_light': {
      AppLanguage.latin: 'Light',
      AppLanguage.arabic: 'فاتح',
    },
    'language': {
      AppLanguage.latin: 'Language',
      AppLanguage.arabic: 'اللغة',
    },
    'latin': {
      AppLanguage.latin: 'Latin',
      AppLanguage.arabic: 'لاتيني',
    },
    'arabic': {
      AppLanguage.latin: 'Arabic',
      AppLanguage.arabic: 'العربية',
    },

    // ----- HOME -----
    'search': {
      AppLanguage.latin: 'Search',
      AppLanguage.arabic: 'بحث',
    },
    'free': {
      AppLanguage.latin: 'Free',
      AppLanguage.arabic: 'مجاني',
    },

    'home': {
      AppLanguage.latin: 'Home',
      AppLanguage.arabic: 'الرئيسية',
    },
    'library': {
      AppLanguage.latin: 'Library',
      AppLanguage.arabic: 'مكتبة',
    },
    'listen': {
      AppLanguage.latin: 'Listen',
      AppLanguage.arabic: 'استمع',
    },
    'playlist': {
      AppLanguage.latin: 'Playlists',
      AppLanguage.arabic: 'قوائم التشغيل',
    },
    'recently_added': {
      AppLanguage.latin: 'Recently added',
      AppLanguage.arabic: 'المضافة حديثاً',
    },
    'by': {
      AppLanguage.latin: 'By',
      AppLanguage.arabic: 'بواسطة',
    },
    'likes': {
      AppLanguage.latin: 'likes',
      AppLanguage.arabic: 'إعجابات',
    },
    'research': {
      AppLanguage.latin: 'Research',
      AppLanguage.arabic: 'أبحاث',
    },
    'science': {
      AppLanguage.latin: 'Science',
      AppLanguage.arabic: 'علوم',
    },
    'literature': {
      AppLanguage.latin: 'Literature',
      AppLanguage.arabic: 'أدب',
    },
    'unlock': {
      AppLanguage.latin: 'Unlock',
      AppLanguage.arabic: 'فتح',
    },
    // ----- PLAYER -----
    'add_to_playlist': {
      AppLanguage.latin: 'Add to playlist',
      AppLanguage.arabic: 'أضف إلى قائمة التشغيل',
    },
    'report': {
      AppLanguage.latin: 'Report',
      AppLanguage.arabic: 'إبلاغ',
    },
    'added_to_playlist': {
      AppLanguage.latin: 'Correctly added to the playlist!',
      AppLanguage.arabic: 'تمت الإضافة إلى قائمة التشغيل!',
    },
    'reported': {
      AppLanguage.latin: 'Correctly reported!',
      AppLanguage.arabic: 'تم الإبلاغ بنجاح!',
    },
    'add_notes': {
      AppLanguage.latin: 'Add notes',
      AppLanguage.arabic: 'أضف ملاحظات',
    },
    'consult_notes': {
      AppLanguage.latin: 'Consult notes',
      AppLanguage.arabic: 'عرض الملاحظات',
    },
    'no_current_notes': {
      AppLanguage.latin: 'No current notes',
      AppLanguage.arabic: 'لا توجد ملاحظات حالية',
    },
    'notes': {
      AppLanguage.latin: 'Notes',
      AppLanguage.arabic: 'ملاحظات',
    },
    'share': {
      AppLanguage.latin: 'Share',
      AppLanguage.arabic: 'مشاركة',
    },
    'play': {
      AppLanguage.latin: 'Play',
      AppLanguage.arabic: 'تشغيل',
    },
    'pause': {
      AppLanguage.latin: 'Pause',
      AppLanguage.arabic: 'إيقاف مؤقت',
    },
    'comments': {
      AppLanguage.latin: 'comments',
      AppLanguage.arabic: 'تعليقات',
    },
    'minutes': {
      AppLanguage.latin: 'min',
      AppLanguage.arabic: 'دقيقة',
    },

    // ----- PAYWALL -----
    'pay_to_unlock': {
      AppLanguage.latin: 'Pay to unlock',
      AppLanguage.arabic: 'ادفع لفتح',
    },
    'audio_unlocked': {
      AppLanguage.latin: 'Audio unlocked!',
      AppLanguage.arabic: 'تم فتح الصوت!',
    },
    'purchase_error': {
      AppLanguage.latin: 'Could not complete purchase.',
      AppLanguage.arabic: 'تعذر إكمال الشراء.',
    },

    'purchased': {
      AppLanguage.latin: 'Purchased',
      AppLanguage.arabic: 'تم شراؤها',
    },

    // ----- FAVORITES & PLAYLIST -----
    'favourites': {
      AppLanguage.latin: 'Favourites',
      AppLanguage.arabic: 'المفضلة',
    },
    'create': {
      AppLanguage.latin: 'CREATE',
      AppLanguage.arabic: 'إنشاء',
    },
    'new_playlist': {
      AppLanguage.latin: 'New playlist',
      AppLanguage.arabic: 'قائمة تشغيل جديدة',
    },
    'name': {
      AppLanguage.latin: 'Name',
      AppLanguage.arabic: 'الاسم',
    },
    'loading': {
      AppLanguage.latin: 'Loading...',
      AppLanguage.arabic: 'جار التحميل...',
    },

    // ----- PURCHASES -----
    'purchase': {
      AppLanguage.latin: 'Purchase',
      AppLanguage.arabic: 'شراء',
    },
    'my_purchased': {
      AppLanguage.latin: 'My Purchased Audios',
      AppLanguage.arabic: 'الصوتيات المشتراة',
    },
    'no_purchases': {
      AppLanguage.latin: 'No purchases yet.',
      AppLanguage.arabic: 'لا توجد مشتريات بعد.',
    },

    // ----- GENERIC -----
    'error': {
      AppLanguage.latin: 'Error',
      AppLanguage.arabic: 'خطأ',
    },
    'success': {
      AppLanguage.latin: 'Success',
      AppLanguage.arabic: 'نجاح',
    },
    'delete': {
      AppLanguage.latin: 'Delete',
      AppLanguage.arabic: 'حذف',
    },
    'edit': {
      AppLanguage.latin: 'Edit',
      AppLanguage.arabic: 'تعديل',
    },
    'update': {
      AppLanguage.latin: 'Update',
      AppLanguage.arabic: 'تحديث',
    },

    // ----- NARRATOR SCREEN -----
    'narrations': {
      AppLanguage.latin: 'Narrations',
      AppLanguage.arabic: 'الروايات',
    },
    'narrator': {
      AppLanguage.latin: 'Narrator',
      AppLanguage.arabic: 'راوي',
    },
    'about_the_narrator': {
      AppLanguage.latin: 'About the Narrator',
      AppLanguage.arabic: 'عن الراوي',
    },
    'works': {
      AppLanguage.latin: 'Works',
      AppLanguage.arabic: 'أعمال',
    },
    'no_books_available': {
      AppLanguage.latin: 'No books available.',
      AppLanguage.arabic: 'لا توجد كتب متاحة.',
    },

    // ----- AUTHOR SCREEN -----
    'author': {
      AppLanguage.latin: 'Author',
      AppLanguage.arabic: 'مؤلف',
    },
    'about_the_author': {
      AppLanguage.latin: 'About the Author',
      AppLanguage.arabic: 'عن المؤلف',
    },
    'popular_works': {
      AppLanguage.latin: 'Popular Works',
      AppLanguage.arabic: 'أعمال شهيرة',
    },

    // ----- PUBLISHER SCREEN -----
    'publishing_house': {
      AppLanguage.latin: 'Publishing House',
      AppLanguage.arabic: 'دار نشر',
    },
    'publications': {
      AppLanguage.latin: 'Publications',
      AppLanguage.arabic: 'إصدارات',
    },
    'titles': {
      AppLanguage.latin: 'Titles',
      AppLanguage.arabic: 'عناوين',
    },

    // ----- LISTENING SCREEN -----
    "choose_book_to_listen": {
      AppLanguage.latin: "Please choose a book to start listening.",
      AppLanguage.arabic: "يرجى اختيار كتاب للبدء في الاستماع."
    },
    "access_restricted": {
      AppLanguage.latin: "Access Restricted",
      AppLanguage.arabic: "الدخول مقيد"
    },
    "subscription_required_to_listen": {
      AppLanguage.latin:
          "You need an active subscription or to purchase this book to listen.",
      AppLanguage.arabic: "تحتاج إلى اشتراك نشط أو شراء هذا الكتاب للاستماع."
    },
    "subscribe_unlock_book": {
      AppLanguage.latin: "Subscribe / Unlock Book",
      AppLanguage.arabic: "اشترك / افتح الكتاب"
    },
    "show_transcript": {
      AppLanguage.latin: "Show Transcript",
      AppLanguage.arabic: "عرض النص"
    },
    "add_comment": {
      AppLanguage.latin: "Add Comment",
      AppLanguage.arabic: "أضف تعليق"
    },
    "write_your_comment": {
      AppLanguage.latin: "Write your comment...",
      AppLanguage.arabic: "اكتب تعليقك..."
    },
    "cancel": {AppLanguage.latin: "Cancel", AppLanguage.arabic: "إلغاء"},
    "submit": {AppLanguage.latin: "Submit", AppLanguage.arabic: "إرسال"},

    // ----- Sleep Timer Widget -----
    "sleep_timer": {
      AppLanguage.latin: "Sleep Timer",
      AppLanguage.arabic: "مؤقت النوم"
    },
    "start": {AppLanguage.latin: "Start", AppLanguage.arabic: "ابدأ"},
    "stop": {AppLanguage.latin: "Stop", AppLanguage.arabic: "توقف"},
    "close": {AppLanguage.latin: "Close", AppLanguage.arabic: "إغلاق"},

    // ----- Specific Genre Page -----
    'price_symbol': {
      AppLanguage.latin: '\$',
      AppLanguage.arabic: 'د.أ',
    },

    'no_books_found': {
      AppLanguage.latin: 'No books found',
      AppLanguage.arabic: 'لم يتم العثور على كتب',
    },

    'check_other_genres': {
      AppLanguage.latin: 'Check other genres for now',
      AppLanguage.arabic: 'تحقق من أنواع أخرى حالياً',
    },

    'email': {
      AppLanguage.latin: 'Email',
      AppLanguage.arabic: 'البريد الإلكتروني',
    },
    'password': {
      AppLanguage.latin: 'Password',
      AppLanguage.arabic: 'كلمة المرور',
    },
    'login': {
      AppLanguage.latin: 'Login',
      AppLanguage.arabic: 'تسجيل الدخول',
    },
    'create_account': {
      AppLanguage.latin: 'Create Account',
      AppLanguage.arabic: 'إنشاء حساب',
    },
    'or': {
      AppLanguage.latin: 'OR',
      AppLanguage.arabic: 'أو',
    },
    'welcome_back_login': {
      AppLanguage.latin: 'Welcome 👋',
      AppLanguage.arabic: 'مرحبا 👋',
    },
    'sign_in_continue': {
      AppLanguage.latin: 'Sign in to continue',
      AppLanguage.arabic: 'سجّل الدخول للمتابعة',
    },
    'about_login': {
      AppLanguage.latin: 'About',
      AppLanguage.arabic: 'حول التطبيق',
    },
    'about_this_app': {
      AppLanguage.latin: 'About this app',
      AppLanguage.arabic: 'حول هذا التطبيق',
    },
    'about_message': {
      AppLanguage.latin:
          'Ellil is an Arabic audiobook app designed for readers and learners. Discover and listen to books, research, and papers anytime, anywhere.\n\nBecause knowledge deserves to be heard.\n\n www.ellil.io',
      AppLanguage.arabic:
          '"إليل" تطبيق كتب صوتية عربي مصمم للقراء والمتعلمين. اكتشف واستمع إلى الكتب والأبحاث والأوراق العلمية في أي وقت وفي أي مكان.\n لأن المعرفة تستحق أن تُسمع.'
    },
    'register_description': {
      AppLanguage.latin: 'Register yourself and start your journey 🚀',
      AppLanguage.arabic: 'قم بالتسجيل وابدأ رحلتك 🚀',
    },
    'fill_info': {
      AppLanguage.latin: 'Please, fill out your information',
      AppLanguage.arabic: 'يرجى ملء جميع المعلومات المطلوبة',
    },
    'passwords_not_match': {
      AppLanguage.latin: 'Passwords do not match',
      AppLanguage.arabic: 'كلمتا المرور غير متطابقتين',
    },
    'review_info': {
      AppLanguage.latin: 'Please review the info you entered',
      AppLanguage.arabic: 'يرجى التحقق من المعلومات التي أدخلتها',
    },
    'register': {
      AppLanguage.latin: 'Register',
      AppLanguage.arabic: 'تسجيل',
    },
    'your_name': {
      AppLanguage.latin: 'Your Name',
      AppLanguage.arabic: 'اسمك',
    },
    'your_email': {
      AppLanguage.latin: 'Your Email',
      AppLanguage.arabic: 'بريدك الإلكتروني',
    },
    'date_of_birth': {
      AppLanguage.latin: 'Date of Birth',
      AppLanguage.arabic: 'تاريخ الميلاد',
    },
    'confirm_password': {
      AppLanguage.latin: 'Confirm Password',
      AppLanguage.arabic: 'تأكيد كلمة المرور',
    },

    // ----- Book Page -----
    'download_comments': {
      AppLanguage.latin: 'Download Comments',
      AppLanguage.arabic: 'تحميل التعليقات',
    },
    'share_book': {
      AppLanguage.latin: 'Share Book',
      AppLanguage.arabic: 'مشاركة الكتاب',
    },
    'an_error_occurred': {
      AppLanguage.latin: 'An error occurred. Please try again later.',
      AppLanguage.arabic: 'حدث خطأ. يرجى المحاولة لاحقًا.',
    },
    'subscribe_before_listening': {
      AppLanguage.latin: 'Please subscribe before listening to purchased book',
      AppLanguage.arabic: 'يرجى الاشتراك قبل الاستماع إلى الكتاب المشتَرَى',
    },
    'book_already_purchased': {
      AppLanguage.latin: 'Book already purchased',
      AppLanguage.arabic: 'تم شراء هذا الكتاب مسبقًا',
    },
    'book_purchased_successfully': {
      AppLanguage.latin: 'Book has been purchased successfully',
      AppLanguage.arabic: 'تم شراء الكتاب بنجاح',
    },
    'purchase_failed': {
      AppLanguage.latin: 'Failed to purchase the book. Please try again.',
      AppLanguage.arabic: 'فشل في شراء الكتاب. يرجى المحاولة مرة أخرى.',
    },

    'no_history_yet': {
      AppLanguage.latin: 'No books in history yet',
      AppLanguage.arabic: 'لا توجد كتب في السجل بعد',
    },
    // ----- Library Page -----

    'no_purchased_books': {
      AppLanguage.latin: 'No purchased books yet',
      AppLanguage.arabic: 'لا توجد كتب تم شراؤها بعد',
    },

    'no_results_found': {
      AppLanguage.latin: 'No results found',
      AppLanguage.arabic: 'لم يتم العثور على نتائج',
    },

    'start_listening_to_see_books_here': {
      AppLanguage.latin: 'Start listening to books and they will appear here.',
      AppLanguage.arabic: 'ابدأ الاستماع إلى الكتب وستظهر هنا.',
    },

    'buy_audiobooks_to_see_them_here': {
      AppLanguage.latin: 'Purchase audiobooks to see them listed here.',
      AppLanguage.arabic: 'قم بشراء الكتب الصوتية لتظهر هنا.',
    },

    'browse_books': {
      AppLanguage.latin: 'Browse Books',
      AppLanguage.arabic: 'تصفح الكتب',
    },
  };

  static String tr(String key, AppLanguage lang) {
    return _localized[key]?[lang] ?? key;
  }
}
