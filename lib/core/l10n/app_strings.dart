import '../../shared/data/locale_provider.dart';

class AppStrings {
  static AppStrings get current =>
      LocaleProvider.instance.isEn ? _en : _bn;

  // ─── Common ───
  final String appName = 'Hilful Fuzul';
  final String appNameBn = 'Hilful Fuzul';
  final String save = 'Save';
  final String cancel = 'Cancel';
  final String delete = 'Delete';
  final String retry = 'Try Again';
  final String close = 'Close';
  final String error = 'Error';
  final String loading = 'Loading...';
  final String yes = 'Yes';
  final String no = 'No';

  // ─── Auth ───
  final String admin = 'Admin';
  final String memberOrCollector = 'Member / Collector';
  final String email = 'Email';
  final String password = 'Password';
  final String name = 'Name';
  final String phone = 'Phone Number';
  final String login = 'Login';
  final String register = 'Register';
  final String firstAdmin = 'First Admin';
  final String loginSubtitle = 'Keshabpur Paschimpara';
  final String phoneOrUserId = 'Phone Number / User ID';
  final String userIdAuto = 'User ID (auto)';
  final String adminNote = 'If admin adds member, phone number is the user ID';
  final String alreadyAccount = 'Already have an account? Login';
  final String firstTime = 'First time? Admin Register';

  // ─── Auth Errors ───
  final String userNotFound = 'User not found — register as admin first';
  final String wrongPassword = 'Invalid email/password';
  final String emailInUse = 'Email already in use';
  final String weakPassword = 'Password must be at least 6 characters';
  final String invalidEmail = 'Invalid email';
  final String enableAuth = 'Enable Email/Password Auth in Firebase Console → Authentication';

  // ─── Dashboard ───
  final String dashboard = 'Dashboard';
  final String totalCollection = 'Total Collection';
  final String totalDonation = 'Total Donation';
  final String currentBalance = 'Current Balance';
  final String totalMembers = 'Total Members';
  final String thisMonthCollection = 'This Month Collection';
  final String enterCollection = 'Enter Collection';
  final String quickActions = 'Quick Actions';
  final String members = 'Members';
  final String help = 'Aid';
  final String reports = 'Reports';
  final String monthlyCollectionGraph = 'Monthly Collection Graph';
  final String recentCollections = 'Recent Collections';
  final String viewAll = 'View All';
  final String noCollectionsYet = 'No collections yet';
  final String welcome = 'Welcome';

  // ─── Members ───
  final String memberList = 'Member List';
  final String newMember = 'New Member';
  final String searchNameOrPhone = 'Search by name or phone';
  final String memberProfile = 'Member Profile';
  final String totalTimes = 'Total Times';
  final String topDonors = 'Top Donors';
  final String topDonorsList = 'Top Donors List';
  final String top10 = 'Top 10';
  final String allDonors = 'All Donors';
  final String viewMore = 'View More';
  final String allTime = 'All Time';
  final String thisMonth = 'This Month';
  final String allTimeDonation = 'All-Time Collection';
  final String monthlyDonation = 'This Month\'s Collection';
  final String noTopDonorsYet = 'No data available';
  final String times = 'times';
  final String newDonationEntry = 'New Donation Entry';
  final String monthlySummary = 'Monthly Summary';
  final String donationHistory = 'Donation History';
  final String noDonationsYet = 'No donations yet';
  final String receipt = 'Receipt';
  final String deleteMember = 'Delete Member';
  final String deleteMemberConfirm = 'Are you sure you want to delete this member?';
  final String memberDeleted = 'Member deleted successfully';
  final String changeRole = 'Change Role';
  final String changeRoleTitle = 'Change Role';
  final String changeRoleDesc = 'Change role for';
  final String roleChanged = 'Role changed successfully';
  final String superAdmin = 'Super Admin';
  final String collector = 'Collector';
  final String memberRole = 'Member';
  final String superAdminDesc = 'Full access — can manage everything';
  final String collectorDesc = 'Collection records and data management';
  final String memberDesc = 'View-only access';
  final String saveChanges = 'Save';
  final String addMember = 'Add Member';
  final String fullName = 'Full Name';
  final String nidOptional = 'NID Number (Optional)';
  final String nidHint = 'National ID number';
  final String address = 'Address';
  final String addressHint = 'Village/Area, Upazila, District';
  final String role = 'Role';
  final String initialPassword = 'Initial Password';
  final String activeMember = 'Active Member';
  final String profileUpdated = 'Profile updated successfully';
  final String profileEdit = 'Edit Profile';

  // ─── Collections ───
  final String collectDonation = 'Collect Donation';
  final String collections = 'Collections';
  final String donor = 'Donor';
  final String selectDonor = 'Select Donor';
  final String selfCollection = 'Self Collection';
  final String newMemberPlus = '+ New Member';
  final String amountTaka = 'Amount (Taka)';
  final String paymentMode = 'Payment Mode';
  final String cash = 'Cash';
  final String bkash = 'Bkash';
  final String other = 'Other';
  final String date = 'Date';
  final String note = 'Note';
  final String saveAndReceipt = 'Save & Receipt';
  final String donationSaved = 'Donation Saved';
  final String editDonation = 'Edit Collection';
  final String donationUpdated = 'Collection updated';
  final String receiptPdf = 'Receipt PDF';
  final String collectionHistory = 'Collection History';
  final String searchNameOrReceipt = 'Search by name or receipt no.';
  final String allMonths = 'All Months';
  final String noCollectionsFound = 'No collections found';

  // ─── Aid ───
  final String helpDistribution = 'Aid Distribution';
  final String newHelp = 'New Aid';
  final String searchNamePhoneOrNid = 'Search by name, phone or NID';
  final String noHelpRecords = 'No aid records';
  final String newHelpTitle = 'New Aid';
  final String recipientName = 'Recipient Name *';
  final String nidNumber = 'NID Number *';
  final String nidDigits = '13 digits';
  final String phoneNumber = 'Phone Number *';
  final String fullAddress = 'Address *';
  final String reason = 'Reason *';
  final String descriptionNote = 'Description Note';
  final String additionalInfo = 'Additional info';
  final String recordHelp = 'Record Aid';
  final String helpRecordSaved = 'Aid record saved';
  final String helpDetail = 'Aid Detail';
  final String recordNotFound = 'Record not found';
  final String recordLoadError = 'Failed to load record.';
  final String recordNotFoundMsg = 'Record not found';
  final String deleteHelpRecord = 'Delete Aid Record';
  final String deleteHelpConfirm = 'Are you sure you want to delete this record?';
  final String recordDeleted = 'Record deleted successfully';

  // ─── Aid Reasons ───
  final String medical = 'Medical';
  final String education = 'Education';
  final String widowHelp = 'Widow Aid';
  final String others = 'Others';

  // ─── Reports ───
  final String customReport = 'Custom Report';
  final String year = 'Year';
  final String yearlySummary = 'Yearly Summary';
  final String collectionList = 'Collection List';
  final String selectedYear = 'Selected Year';
  final String monthlyCollectionSummary = 'Monthly Collection Summary';
  final String byMonth = 'By Month';
  final String helpDistributionReport = 'Aid Distribution Report';

  // ─── Profile ───
  final String myProfile = 'My Profile';
  final String myDonationHistory = 'My Donation History';

  // ─── Settings ───
  final String settings = 'Settings';
  final String account = 'Account';
  final String myProfileSettings = 'My Profile';
  final String changePassword = 'Change Password';
  final String logout = 'Logout';
  final String reportSection = 'Report';
  final String customReportExport = 'Custom Report';
  final String excelPdfExport = 'Excel / PDF Export';
  final String organization = 'Organization';
  final String organizationName = 'Organization Name';
  final String enterOrgName = 'Enter organization name';
  final String saveName = 'Save Name';
  final String orgNameSaved = 'Organization name saved';
  final String collectorPermission = 'Collector Permission';
  final String collectorPermDesc = 'Control collector permissions from Super Admin';
  final String memberProfileEdit = 'Member Profile Edit';
  final String memberProfileEditDesc = 'Collector can edit member name and info';
  final String helpOutgoingEntry = 'Aid / Outgoing Entry';
  final String helpOutgoingDesc = 'Collector can record aid distribution';
  final String appSection = 'App';
  final String darkMode = 'Dark Mode';
  final String darkModeDesc = 'Use dark theme';
  final String aboutApp = 'About App';
  final String language = 'Language';
  final String bengali = 'Bengali';
  final String english = 'English';
  final String onlyBengali = 'Only Bengali';
  final String aboutDesc = 'Organization accounting, donation and aid distribution management app.';

  // ─── Password Change ───
  final String currentPassword = 'Current Password';
  final String newPassword = 'New Password';
  final String confirmPassword = 'Confirm New Password';
  final String passwordUpdated = 'Password updated';
  final String passwordMismatch = 'Passwords do not match';

  // ─── Validators ───
  final String enterPhone = 'Enter phone number';
  final String phoneMustBe11 = 'Phone number must be 11 digits';
  final String phoneMustStart01 = 'Phone number must start with 01';
  final String enterValidPhone = 'Enter valid phone number (01XXXXXXXXX)';
  final String enterAmount = 'Enter amount';
  final String enterNumber = 'Enter a number';
  final String amountMustBePositive = 'Amount must be greater than 0';
  final String minAmount10 = 'Minimum 10 Taka';
  final String maxAmount1Cr = 'Maximum 1 Crore Taka';
  final String enterName = 'Enter name';
  final String nameMin2 = 'Name must be at least 2 characters';
  final String enterEmail = 'Enter email';
  final String enterValidEmail = 'Enter valid email';
  final String enterPassword = 'Enter password';
  final String passwordMin6 = 'Password must be at least 6 characters';
  final String nidDigitsError = 'NID must be 10, 13 or 17 digits';

  // ─── Receipt / PDF ───
  final String donationReceipt = 'Donation Receipt';
  final String receiptNo = 'Receipt No.';
  final String amount = 'Amount';
  final String taka = 'Taka';
  final String takaOnly = 'Taka Only';
  final String entryBy = 'Entered by';
  final String thankYou = 'Thank You';
  final String thankYouMsg = 'Thank you for your valuable contribution to social welfare.';
  final String socialWelfareOrg = 'Social Welfare Organization';
  final String receiptDownload = 'Receipt download';
  final String receiptFailed = 'Receipt generation failed';

  // ─── Export ───
  final String memberListReport = 'Member List';
  final String collectionReport = 'Collection Report';
  final String monthlyCollection = 'Monthly Collection';
  final String total = 'Total';
  final String status = 'Status';
  final String active = 'Active';
  final String inactive = 'Inactive';
  final String month = 'Month';
  final String summary = 'Summary';
  final String subject = 'Subject';
  final String created = 'created';

  // ─── Trash ───
  final String trash = 'Trash';
  final String moveToTrash = 'Move to Trash';
  final String moveToTrashConfirm = 'Are you sure you want to move this to trash?';
  final String restore = 'Restore';
  final String restoreConfirm = 'Restore this item?';
  final String permanentlyDelete = 'Permanently Delete';
  final String permanentlyDeleteConfirm = 'Permanently delete? This cannot be undone.';
  final String itemMovedToTrash = 'Moved to trash';
  final String itemRestored = 'Restored successfully';
  final String itemPermanentlyDeleted = 'Permanently deleted';
  final String noTrashItems = 'Trash is empty';
  final String emptyTrash = 'Empty Trash';
  final String emptyTrashConfirm = 'Permanently delete all items in trash? This cannot be undone.';
  final String trashEmptied = 'Trash emptied';

  // ─── Bottom Nav ───
  final String navDashboard = 'Dashboard';
  final String navMembers = 'Members';
  final String navHelp = 'Aid';
  final String navSettings = 'Settings';

  // ─── Collector Stats ───
  final String collectorCollectionSummary = 'Collector Collection Summary';
  final String collectorCollectionSummaryDesc = 'See how much each collector collected';
  final String totalCollected = 'Total Collected';
  final String totalEntries = 'Entries';
  final String noCollectorsYet = 'No collector data yet';
  final String myCollectionHistory = 'My Collection History';
  final String viewCollectionHistory = 'View Collection History';
  final String collectedBy = 'Collected by';

  // ─── Months ───
  final String jan = 'Jan';
  final String feb = 'Feb';
  final String mar = 'Mar';
  final String apr = 'Apr';
  final String may = 'May';
  final String jun = 'Jun';
  final String jul = 'Jul';
  final String aug = 'Aug';
  final String sep = 'Sep';
  final String oct = 'Oct';
  final String nov = 'Nov';
  final String dec = 'Dec';

  final String january = 'January';
  final String february = 'February';
  final String march = 'March';
  final String april = 'April';
  final String june = 'June';
  final String july = 'July';
  final String august = 'August';
  final String september = 'September';
  final String october = 'October';
  final String november = 'November';
  final String december = 'December';

  List<String> get monthShortNames => [
    jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec,
  ];

  List<String> get monthNames => [
    january, february, march, april, may, june,
    july, august, september, october, november, december,
  ];

  // ─── Number Words ───
  final String zero = 'zero';
  final String one = 'one';
  final String two = 'two';
  final String three = 'three';
  final String four = 'four';
  final String five = 'five';
  final String six = 'six';
  final String seven = 'seven';
  final String eight = 'eight';
  final String nine = 'nine';
  final String ten = 'ten';
  final String twenty = 'twenty';
  final String thirty = 'thirty';
  final String forty = 'forty';
  final String fifty = 'fifty';
  final String sixty = 'sixty';
  final String seventy = 'seventy';
  final String eighty = 'eighty';
  final String ninety = 'ninety';
  final String hundred = 'hundred';
  final String thousand = 'thousand';
  final String lakh = 'lakh';
  final String crore = 'crore';

  // ─── Dashboard Chart Months ───
  final String chartJan = 'Jan';
  final String chartFeb = 'Feb';
  final String chartMar = 'Mar';
  final String chartApr = 'Apr';
  final String chartMay = 'May';
  final String chartJun = 'Jun';
  final String chartJul = 'Jul';
  final String chartAug = 'Aug';
  final String chartSep = 'Sep';
  final String chartOct = 'Oct';
  final String chartNov = 'Nov';
  final String chartDec = 'Dec';

  // ─── Unit ───
  final String person = 'person';

  // ─── Snackbar generic ───
  final String failedPrefix = 'Failed';
  final String exportFailed = 'Export failed';
}

// Bengali strings
final _bn = _BnStrings();
// English strings
final _en = _EnStrings();

class _BnStrings extends AppStrings {
  // Common
  @override final String appName = 'Hilful Fuzul';
  @override final String appNameBn = 'Hilful Fuzul';
  @override final String save = 'সংরক্ষণ';
  @override final String cancel = 'বাতিল';
  @override final String delete = 'মুছুন';
  @override final String retry = 'আবার চেষ্টা করুন';
  @override final String close = 'বন্ধ';
  @override final String error = 'ত্রুটি';
  @override final String loading = 'লোড হচ্ছে...';
  @override final String yes = 'হ্যাঁ';
  @override final String no = 'না';

  // Auth
  @override final String admin = 'অ্যাডমিন';
  @override final String memberOrCollector = 'মেম্বার / কালেক্টর';
  @override final String email = 'ইমেইল';
  @override final String password = 'পাসওয়ার্ড';
  @override final String name = 'নাম';
  @override final String phone = 'ফোন নম্বর';
  @override final String login = 'লগইন';
  @override final String register = 'রেজিস্টার';
  @override final String firstAdmin = 'প্রথম অ্যাডমিন তৈরি';
  @override final String loginSubtitle = 'কেশবপুর পশ্চিমপাড়া';
  @override final String phoneOrUserId = 'ফোন নম্বর / ইউজার আইডি';
  @override final String userIdAuto = 'ইউজার আইডি (অটো)';
  @override final String adminNote = 'অ্যাডমিন মেম্বার যোগ করলে ফোন নম্বরই ইউজার আইডি';
  @override final String alreadyAccount = 'আগে থেকে অ্যাকাউন্ট আছে? লগইন';
  @override final String firstTime = 'প্রথমবার? অ্যাডমিন রেজিস্টার';

  // Auth Errors
  @override final String userNotFound = 'ইউজার পাওয়া যায়নি — প্রথমবার হলে অ্যাডমিন রেজিস্টার করুন';
  @override final String wrongPassword = 'ইমেইল/পাসওয়ার্ড ভুল';
  @override final String emailInUse = 'ইমেইল ইতিমধ্যে ব্যবহৃত';
  @override final String weakPassword = 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
  @override final String invalidEmail = 'ইমেইল সঠিক নয়';
  @override final String enableAuth = 'Email/Password Auth চালু করুন Firebase Console → Authentication';

  // Dashboard
  @override final String dashboard = 'ড্যাশবোর্ড';
  @override final String totalCollection = 'মোট কালেকশন';
  @override final String totalDonation = 'মোট ডোনেশন';
  @override final String currentBalance = 'বর্তমান ব্যালেন্স';
  @override final String totalMembers = 'মোট মেম্বার';
  @override final String thisMonthCollection = 'এই মাসের কালেকশন';
  @override final String enterCollection = 'কালেকশন এন্ট্রি করুন';
  @override final String quickActions = 'কুইক অ্যাকশন';
  @override final String members = 'মেম্বার';
  @override final String help = 'সহায়তা';
  @override final String reports = 'রিপোর্ট';
  @override final String monthlyCollectionGraph = 'মান্থলি কালেকশন গ্রাফ';
  @override final String recentCollections = 'সাম্প্রতিক কালেকশন';
  @override final String viewAll = 'সব দেখুন';
  @override final String noCollectionsYet = 'এখনো কোনো কালেকশন নেই';
  @override final String welcome = 'স্বাগতম';

  // Members
  @override final String memberList = 'মেম্বার তালিকা';
  @override final String newMember = 'নতুন মেম্বার';
  @override final String searchNameOrPhone = 'নাম বা ফোন দিয়ে খুঁজুন';
  @override final String memberProfile = 'মেম্বার প্রোফাইল';
  @override final String totalTimes = 'মোট বার';
  @override final String topDonors = 'শীর্ষ দাতা';
  @override final String topDonorsList = 'টপ ডোনার তালিকা';
  @override final String top10 = 'সেরা ১০';
  @override final String allDonors = 'সকল দাতা';
  @override final String viewMore = 'সব দেখুন';
  @override final String allTime = 'সর্বকালীন';
  @override final String thisMonth = 'এই মাস';
  @override final String allTimeDonation = 'সর্বকালীন সংগ্রহ';
  @override final String monthlyDonation = 'এই মাসের সংগ্রহ';
  @override final String noTopDonorsYet = 'এখনো কোনো তথ্য নেই';
  @override final String times = 'বার';
  @override final String newDonationEntry = 'নতুন ডোনেশন এন্ট্রি';
  @override final String monthlySummary = 'মাসভিত্তিক সারাংশ';
  @override final String donationHistory = 'ডোনেশন হিস্ট্রি';
  @override final String noDonationsYet = 'এখনো কোনো ডোনেশন নেই';
  @override final String receipt = 'রিসিপ্ট';
  @override final String deleteMember = 'মেম্বার মুছুন';
  @override final String deleteMemberConfirm = 'আপনি কি নিশ্চিত এই মেম্বারকে মুছে ফেলতে চান?';
  @override final String memberDeleted = 'মেম্বার মুছে ফেলা হয়েছে';
  @override final String changeRole = 'রোল পরিবর্তন';
  @override final String changeRoleTitle = 'রোল পরিবর্তন করুন';
  @override final String changeRoleDesc = 'এর রোল পরিবর্তন করুন';
  @override final String roleChanged = 'রোল সফলভাবে পরিবর্তন করা হয়েছে';
  @override final String superAdmin = 'সুপার অ্যাডমিন';
  @override final String collector = 'কালেক্টর';
  @override final String memberRole = 'মেম্বার';
  @override final String superAdminDesc = 'সম্পূর্ণ অ্যাক্সেস - সব কিছু পরিচালনা করতে পারবেন';
  @override final String collectorDesc = 'কালেকশন রেকর্ড এবং ডেটা ম্যানেজমেন্ট';
  @override final String memberDesc = 'শুধুমাত্র দেখার অ্যাক্সেস';
  @override final String saveChanges = 'সংরক্ষণ করুন';
  @override final String addMember = 'মেম্বার যোগ করুন';
  @override final String fullName = 'পূর্ণ নাম';
  @override final String nidOptional = 'এনআইডি নং (অপশনাল)';
  @override final String nidHint = 'জাতীয় পরিচয়পত্র নম্বর';
  @override final String address = 'ঠিকানা';
  @override final String addressHint = 'গ্রাম/এলাকা, থানা, জেলা';
  @override final String role = 'রোল';
  @override final String initialPassword = 'প্রাথমিক পাসওয়ার্ড';
  @override final String activeMember = 'সক্রিয় মেম্বার';
  @override final String profileUpdated = 'প্রোফাইল আপডেট হয়েছে';
  @override final String profileEdit = 'প্রোফাইল এডিট';

  // Collections
  @override final String collectDonation = 'জমা নিন';
  @override final String collections = 'কালেকশন';
  @override final String donor = 'দাতা';
  @override final String selectDonor = 'দাতা বেছে নিন';
  @override final String selfCollection = 'নিজের জমা';
  @override final String newMemberPlus = '+ নতুন মেম্বার';
  @override final String amountTaka = 'পরিমাণ (টাকা)';
  @override final String paymentMode = 'পেমেন্ট মোড';
  @override final String cash = 'নগদ';
  @override final String bkash = 'বিকাশ';
  @override final String other = 'অন্যান্য';
  @override final String date = 'তারিখ';
  @override final String note = 'নোট';
  @override final String saveAndReceipt = 'সেভ ও রিসিপ্ট';
  @override final String donationSaved = 'ডোনেশন সংরক্ষিত';
  @override final String editDonation = 'কালেকশন এডিট';
  @override final String donationUpdated = 'কালেকশন আপডেট হয়েছে';
  @override final String receiptPdf = 'রিসিপ্ট PDF';
  @override final String collectionHistory = 'কালেকশন হিস্ট্রি';
  @override final String searchNameOrReceipt = 'নাম বা রিসিপ্ট নং';
  @override final String allMonths = 'সব মাস';
  @override final String noCollectionsFound = 'কোনো কালেকশন পাওয়া যায়নি';

  // Aid
  @override final String helpDistribution = 'সহায়তা বিতরণ';
  @override final String newHelp = 'নতুন সহায়তা';
  @override final String searchNamePhoneOrNid = 'নাম, ফোন বা এনআইডি দিয়ে খুঁজুন';
  @override final String noHelpRecords = 'কোনো সহায়তা রেকর্ড নেই';
  @override final String newHelpTitle = 'নতুন সহায়তা';
  @override final String recipientName = 'নাম *';
  @override final String nidNumber = 'এনআইডি নম্বর *';
  @override final String nidDigits = '১৩ ডিজিট';
  @override final String phoneNumber = 'ফোন নম্বর *';
  @override final String fullAddress = 'ঠিকানা *';
  @override final String reason = 'কেন (কারণ) *';
  @override final String descriptionNote = 'বিবরণ নোট';
  @override final String additionalInfo = 'অতিরিক্ত তথ্য';
  @override final String recordHelp = 'সহায়তা রেকর্ড করুন';
  @override final String helpRecordSaved = 'সহায়তা রেকর্ড সংরক্ষিত হয়েছে';
  @override final String helpDetail = 'সহায়তার বিবরণ';
  @override final String recordNotFound = 'রেকর্ড পাওয়া যায়নি';
  @override final String recordLoadError = 'রেকর্ড লোড করা যায়নি।';
  @override final String recordNotFoundMsg = 'রেকর্ড পাওয়া যায়নি';
  @override final String deleteHelpRecord = 'সহায়তা রেকর্ড মুছুন';
  @override final String deleteHelpConfirm = 'আপনি কি নিশ্চিত এই রেকর্ড মুছে ফেলতে চান?';
  @override final String recordDeleted = 'রেকর্ড মুছে ফেলা হয়েছে';

  // Aid Reasons
  @override final String medical = 'চিকিৎসা';
  @override final String education = 'শিক্ষা';
  @override final String widowHelp = 'বিধবা সহায়তা';
  @override final String others = 'অন্যান্য';

  // Reports
  @override final String customReport = 'কাস্টম রিপোর্ট';
  @override final String year = 'বছর';
  @override final String yearlySummary = 'বার্ষিক সারাংশ';
  @override final String collectionList = 'কালেকশন তালিকা';
  @override final String selectedYear = 'নির্বাচিত বছর';
  @override final String monthlyCollectionSummary = 'মাসিক কালেকশন সারাংশ';
  @override final String byMonth = 'মাস অনুযায়ী';
  @override final String helpDistributionReport = 'সহায়তা বিতরণ রিপোর্ট';

  // Profile
  @override final String myProfile = 'আমার প্রোফাইল';
  @override final String myDonationHistory = 'আমার ডোনেশন হিস্ট্রি';

  // Settings
  @override final String settings = 'সেটিংস';
  @override final String account = 'অ্যাকাউন্ট';
  @override final String myProfileSettings = 'আমার প্রোফাইল';
  @override final String changePassword = 'পাসওয়ার্ড পরিবর্তন';
  @override final String logout = 'লগআউট';
  @override final String reportSection = 'রিপোর্ট';
  @override final String customReportExport = 'কাস্টম রিপোর্ট';
  @override final String excelPdfExport = 'Excel / PDF এক্সপোর্ট';
  @override final String organization = 'সংগঠন';
  @override final String organizationName = 'সংগঠনের নাম';
  @override final String enterOrgName = 'সংগঠনের নাম লিখুন';
  @override final String saveName = 'নাম সংরক্ষণ';
  @override final String orgNameSaved = 'সংগঠনের নাম সংরক্ষিত হয়েছে';
  @override final String collectorPermission = 'কালেক্টর পারমিশন';
  @override final String collectorPermDesc = 'সুপার অ্যাডমিন থেকে কালেক্টরদের ক্ষমতা নিয়ন্ত্রণ করুন';
  @override final String memberProfileEdit = 'মেম্বার প্রোফাইল এডিট';
  @override final String memberProfileEditDesc = 'কালেক্টর মেম্বারের নাম ও তথ্য সম্পাদনা করতে পারবে';
  @override final String helpOutgoingEntry = 'সহায়তা / আউটগোয়িং এন্ট্রি';
  @override final String helpOutgoingDesc = 'কালেক্টর সহায়তা বিতরণ রেকর্ড করতে পারবে';
  @override final String appSection = 'অ্যাপ';
  @override final String darkMode = 'ডার্ক মোড';
  @override final String darkModeDesc = 'অন্ধকার থিম ব্যবহার করুন';
  @override final String aboutApp = 'অ্যাপ সম্পর্কে';
  @override final String language = 'ভাষা';
  @override final String bengali = 'বাংলা';
  @override final String english = 'English';
  @override final String onlyBengali = 'শুধু বাংলা';
  @override final String aboutDesc = 'সমাজ কল্যাণ সংগঠনের হিসাব, ডোনেশন ও সহায়তা বিতরণ ম্যানেজমেন্ট অ্যাপ।';

  // Password Change
  @override final String currentPassword = 'বর্তমান পাসওয়ার্ড';
  @override final String newPassword = 'নতুন পাসওয়ার্ড';
  @override final String confirmPassword = 'নতুন পাসওয়ার্ড নিশ্চিত করুন';
  @override final String passwordUpdated = 'পাসওয়ার্ড আপডেট হয়েছে';
  @override final String passwordMismatch = 'পাসওয়ার্ড মিলছে না';

  // Validators
  @override final String enterPhone = 'ফোন নম্বর দিন';
  @override final String phoneMustBe11 = 'ফোন নম্বর ১১ ডিজিট হতে হবে';
  @override final String phoneMustStart01 = 'ফোন নম্বর ০১ দিয়ে শুরু হতে হবে';
  @override final String enterValidPhone = 'সঠিক ফোন নম্বর দিন (01XXXXXXXXX)';
  @override final String enterAmount = 'পরিমাণ দিন';
  @override final String enterNumber = 'সংখ্যা দিন';
  @override final String amountMustBePositive = 'পরিমাণ ০ এর বেশি হতে হবে';
  @override final String minAmount10 = 'সর্বনিম্ন ১০ টাকা';
  @override final String maxAmount1Cr = 'সর্বোচ্চ ১ কোটি টাকা';
  @override final String enterName = 'নাম দিন';
  @override final String nameMin2 = 'নাম কমপক্ষে ২ অক্ষর হতে হবে';
  @override final String enterEmail = 'ইমেইল দিন';
  @override final String enterValidEmail = 'সঠিক ইমেইল দিন';
  @override final String enterPassword = 'পাসওয়ার্ড দিন';
  @override final String passwordMin6 = 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষর হতে হবে';
  @override final String nidDigitsError = 'NID ১০, ১৩ বা ১৭ ডিজিট হতে হবে';

  // Receipt / PDF
  @override final String donationReceipt = 'ডোনেশন রিসিপ্ট';
  @override final String receiptNo = 'রিসিপ্ট নং';
  @override final String amount = 'পরিমাণ';
  @override final String taka = 'টাকা';
  @override final String takaOnly = 'টাকা মাত্র';
  @override final String entryBy = 'এন্ট্রি করেছেন';
  @override final String thankYou = 'ধন্যবাদ';
  @override final String thankYouMsg = 'সমাজ কল্যাণে আপনার মূল্যবান অবদানের জন্য আন্তরিক ধন্যবাদ।';
  @override final String socialWelfareOrg = 'সমাজ কল্যাণ সংগঠন';
  @override final String receiptDownload = 'রিসিপ্ট ডাউনলোড';
  @override final String receiptFailed = 'রিসিপ্ট তৈরি ব্যর্থ';

  // Export
  @override final String memberListReport = 'মেম্বার তালিকা';
  @override final String collectionReport = 'কালেকশন রিপোর্ট';
  @override final String monthlyCollection = 'মাসিক কালেকশন';
  @override final String total = 'মোট';
  @override final String status = 'স্ট্যাটাস';
  @override final String active = 'সক্রিয়';
  @override final String inactive = 'নিষ্ক্রিয়';
  @override final String month = 'মাস';
  @override final String summary = 'সারাংশ';
  @override final String subject = 'বিষয়';
  @override final String created = 'তৈরি হয়েছে';

  // Trash
  @override final String trash = 'ট্র্যাশ';
  @override final String moveToTrash = 'ট্র্যাশে পাঠান';
  @override final String moveToTrashConfirm = 'আপনি কি নিশ্চিত এটি ট্র্যাশে পাঠাতে চান?';
  @override final String restore = 'পুনরুদ্ধার';
  @override final String restoreConfirm = 'এটি পুনরুদ্ধার করবেন?';
  @override final String permanentlyDelete = 'স্থায়ীভাবে মুছুন';
  @override final String permanentlyDeleteConfirm = 'স্থায়ীভাবে মুছে ফেলবেন? এটি আর ফেরত যাবে না।';
  @override final String itemMovedToTrash = 'ট্র্যাশে পাঠানো হয়েছে';
  @override final String itemRestored = 'সফলভাবে পুনরুদ্ধার করা হয়েছে';
  @override final String itemPermanentlyDeleted = 'স্থায়ীভাবে মুছে ফেলা হয়েছে';
  @override final String noTrashItems = 'ট্র্যাশ খালি';
  @override final String emptyTrash = 'ট্র্যাশ খালি করুন';
  @override final String emptyTrashConfirm = 'ট্র্যাশের সব আইটেম স্থায়ীভাবে মুছে ফেলবেন? এটি আর ফেরত যাবে না।';
  @override final String trashEmptied = 'ট্র্যাশ খালি করা হয়েছে';

  // Bottom Nav
  @override final String navDashboard = 'ড্যাশবোর্ড';
  @override final String navMembers = 'মেম্বার';
  @override final String navHelp = 'সহায়তা';
  @override final String navSettings = 'সেটিংস';

  // Collector Stats
  @override final String collectorCollectionSummary = 'কালেক্টর কালেকশন সারাংশ';
  @override final String collectorCollectionSummaryDesc = 'প্রতিটি কালেক্টর কতটা জমা করেছে দেখুন';
  @override final String totalCollected = 'মোট জমা';
  @override final String totalEntries = 'এন্ট্রি';
  @override final String noCollectorsYet = 'এখনো কোনো কালেক্টর ডেটা নেই';
  @override final String myCollectionHistory = 'আমার কালেকশন হিস্ট্রি';
  @override final String viewCollectionHistory = 'কালেকশন হিস্ট্রি দেখুন';
  @override final String collectedBy = 'জমা করেছে';

  // Months (short)
  @override final String jan = 'জা';
  @override final String feb = 'ফে';
  @override final String mar = 'মা';
  @override final String apr = 'এ';
  @override final String may = 'মে';
  @override final String jun = 'জু';
  @override final String jul = 'জু';
  @override final String aug = 'আ';
  @override final String sep = 'সে';
  @override final String oct = 'অ';
  @override final String nov = 'ন';
  @override final String dec = 'ডি';

  // Months (full)
  @override final String january = 'জানুয়ারি';
  @override final String february = 'ফেব্রুয়ারি';
  @override final String march = 'মার্চ';
  @override final String april = 'এপ্রিল';
  @override final String june = 'জুন';
  @override final String july = 'জুলাই';
  @override final String august = 'আগস্ট';
  @override final String september = 'সেপ্টেম্বর';
  @override final String october = 'অক্টোবর';
  @override final String november = 'নভেম্বর';
  @override final String december = 'ডিসেম্বর';

  // Number Words
  @override final String zero = 'শূন্য';
  @override final String one = 'এক';
  @override final String two = 'দুই';
  @override final String three = 'তিন';
  @override final String four = 'চার';
  @override final String five = 'পাঁচ';
  @override final String six = 'ছয়';
  @override final String seven = 'সাত';
  @override final String eight = 'আট';
  @override final String nine = 'নয়';
  @override final String ten = 'দশ';
  @override final String twenty = 'কুই';
  @override final String thirty = 'ত্রিশ';
  @override final String forty = 'চল্লিশ';
  @override final String fifty = 'পঞ্চাশ';
  @override final String sixty = 'ষাট';
  @override final String seventy = 'সত্তর';
  @override final String eighty = 'আশি';
  @override final String ninety = 'নব্বই';
  @override final String hundred = 'শত';
  @override final String thousand = 'হাজার';
  @override final String lakh = 'লাখ';
  @override final String crore = 'কোটি';

  // Dashboard chart months
  @override final String chartJan = 'জা';
  @override final String chartFeb = 'ফে';
  @override final String chartMar = 'মা';
  @override final String chartApr = 'এ';
  @override final String chartMay = 'মে';
  @override final String chartJun = 'জু';
  @override final String chartJul = 'জু';
  @override final String chartAug = 'আ';
  @override final String chartSep = 'সে';
  @override final String chartOct = 'অ';
  @override final String chartNov = 'ন';
  @override final String chartDec = 'ডি';

  @override final String person = 'জন';
  @override final String failedPrefix = 'ব্যর্থ';
  @override final String exportFailed = 'এক্সপোর্ট ব্যর্থ';
}

class _EnStrings extends AppStrings {
  // Common
  @override final String appName = 'Hilful Fuzul';
  @override final String appNameBn = 'Hilful Fuzul';
  @override final String save = 'Save';
  @override final String cancel = 'Cancel';
  @override final String delete = 'Delete';
  @override final String retry = 'Try Again';
  @override final String close = 'Close';
  @override final String error = 'Error';
  @override final String loading = 'Loading...';
  @override final String yes = 'Yes';
  @override final String no = 'No';

  // Auth
  @override final String admin = 'Admin';
  @override final String memberOrCollector = 'Member / Collector';
  @override final String email = 'Email';
  @override final String password = 'Password';
  @override final String name = 'Name';
  @override final String phone = 'Phone Number';
  @override final String login = 'Login';
  @override final String register = 'Register';
  @override final String firstAdmin = 'Create First Admin';
  @override final String loginSubtitle = 'Keshabpur Paschimpara';
  @override final String phoneOrUserId = 'Phone Number / User ID';
  @override final String userIdAuto = 'User ID (auto)';
  @override final String adminNote = 'If admin adds member, phone number is the user ID';
  @override final String alreadyAccount = 'Already have an account? Login';
  @override final String firstTime = 'First time? Admin Register';

  // Auth Errors
  @override final String userNotFound = 'User not found — register as admin first';
  @override final String wrongPassword = 'Invalid email/password';
  @override final String emailInUse = 'Email already in use';
  @override final String weakPassword = 'Password must be at least 6 characters';
  @override final String invalidEmail = 'Invalid email';
  @override final String enableAuth = 'Enable Email/Password Auth in Firebase Console → Authentication';

  // Dashboard
  @override final String dashboard = 'Dashboard';
  @override final String totalCollection = 'Total Collection';
  @override final String totalDonation = 'Total Donation';
  @override final String currentBalance = 'Current Balance';
  @override final String totalMembers = 'Total Members';
  @override final String thisMonthCollection = 'This Month Collection';
  @override final String enterCollection = 'Enter Collection';
  @override final String quickActions = 'Quick Actions';
  @override final String members = 'Members';
  @override final String help = 'Aid';
  @override final String reports = 'Reports';
  @override final String monthlyCollectionGraph = 'Monthly Collection Graph';
  @override final String recentCollections = 'Recent Collections';
  @override final String viewAll = 'View All';
  @override final String noCollectionsYet = 'No collections yet';
  @override final String welcome = 'Welcome';

  // Members
  @override final String memberList = 'Member List';
  @override final String newMember = 'New Member';
  @override final String searchNameOrPhone = 'Search by name or phone';
  @override final String memberProfile = 'Member Profile';
  @override final String totalTimes = 'Total Times';
  @override final String topDonors = 'Top Donors';
  @override final String topDonorsList = 'Top Donors List';
  @override final String top10 = 'Top 10';
  @override final String allDonors = 'All Donors';
  @override final String viewMore = 'View More';
  @override final String allTime = 'All Time';
  @override final String thisMonth = 'This Month';
  @override final String allTimeDonation = 'All-Time Collection';
  @override final String monthlyDonation = 'This Month\'s Collection';
  @override final String noTopDonorsYet = 'No data available';
  @override final String times = 'times';
  @override final String newDonationEntry = 'New Donation Entry';
  @override final String monthlySummary = 'Monthly Summary';
  @override final String donationHistory = 'Donation History';
  @override final String noDonationsYet = 'No donations yet';
  @override final String receipt = 'Receipt';
  @override final String deleteMember = 'Delete Member';
  @override final String deleteMemberConfirm = 'Are you sure you want to delete this member?';
  @override final String memberDeleted = 'Member deleted successfully';
  @override final String changeRole = 'Change Role';
  @override final String changeRoleTitle = 'Change Role';
  @override final String changeRoleDesc = 'Change role for';
  @override final String roleChanged = 'Role changed successfully';
  @override final String superAdmin = 'Super Admin';
  @override final String collector = 'Collector';
  @override final String memberRole = 'Member';
  @override final String superAdminDesc = 'Full access — can manage everything';
  @override final String collectorDesc = 'Collection records and data management';
  @override final String memberDesc = 'View-only access';
  @override final String saveChanges = 'Save';
  @override final String addMember = 'Add Member';
  @override final String fullName = 'Full Name';
  @override final String nidOptional = 'NID Number (Optional)';
  @override final String nidHint = 'National ID number';
  @override final String address = 'Address';
  @override final String addressHint = 'Village/Area, Upazila, District';
  @override final String role = 'Role';
  @override final String initialPassword = 'Initial Password';
  @override final String activeMember = 'Active Member';
  @override final String profileUpdated = 'Profile updated successfully';
  @override final String profileEdit = 'Edit Profile';

  // Collections
  @override final String collectDonation = 'Collect Donation';
  @override final String collections = 'Collections';
  @override final String donor = 'Donor';
  @override final String selectDonor = 'Select Donor';
  @override final String selfCollection = 'Self Collection';
  @override final String newMemberPlus = '+ New Member';
  @override final String amountTaka = 'Amount (Taka)';
  @override final String paymentMode = 'Payment Mode';
  @override final String cash = 'Cash';
  @override final String bkash = 'Bkash';
  @override final String other = 'Other';
  @override final String date = 'Date';
  @override final String note = 'Note';
  @override final String saveAndReceipt = 'Save & Receipt';
  @override final String donationSaved = 'Donation Saved';
  @override final String editDonation = 'Edit Collection';
  @override final String donationUpdated = 'Collection updated';
  @override final String receiptPdf = 'Receipt PDF';
  @override final String collectionHistory = 'Collection History';
  @override final String searchNameOrReceipt = 'Search by name or receipt no.';
  @override final String allMonths = 'All Months';
  @override final String noCollectionsFound = 'No collections found';

  // Aid
  @override final String helpDistribution = 'Aid Distribution';
  @override final String newHelp = 'New Aid';
  @override final String searchNamePhoneOrNid = 'Search by name, phone or NID';
  @override final String noHelpRecords = 'No aid records';
  @override final String newHelpTitle = 'New Aid';
  @override final String recipientName = 'Name *';
  @override final String nidNumber = 'NID Number *';
  @override final String nidDigits = '13 digits';
  @override final String phoneNumber = 'Phone Number *';
  @override final String fullAddress = 'Address *';
  @override final String reason = 'Reason *';
  @override final String descriptionNote = 'Description Note';
  @override final String additionalInfo = 'Additional info';
  @override final String recordHelp = 'Record Aid';
  @override final String helpRecordSaved = 'Aid record saved';
  @override final String helpDetail = 'Aid Detail';
  @override final String recordNotFound = 'Record not found';
  @override final String recordLoadError = 'Failed to load record.';
  @override final String recordNotFoundMsg = 'Record not found';
  @override final String deleteHelpRecord = 'Delete Aid Record';
  @override final String deleteHelpConfirm = 'Are you sure you want to delete this record?';
  @override final String recordDeleted = 'Record deleted successfully';

  // Aid Reasons
  @override final String medical = 'Medical';
  @override final String education = 'Education';
  @override final String widowHelp = 'Widow Aid';
  @override final String others = 'Others';

  // Reports
  @override final String customReport = 'Custom Report';
  @override final String year = 'Year';
  @override final String yearlySummary = 'Yearly Summary';
  @override final String collectionList = 'Collection List';
  @override final String selectedYear = 'Selected Year';
  @override final String monthlyCollectionSummary = 'Monthly Collection Summary';
  @override final String byMonth = 'By Month';
  @override final String helpDistributionReport = 'Aid Distribution Report';

  // Profile
  @override final String myProfile = 'My Profile';
  @override final String myDonationHistory = 'My Donation History';

  // Settings
  @override final String settings = 'Settings';
  @override final String account = 'Account';
  @override final String myProfileSettings = 'My Profile';
  @override final String changePassword = 'Change Password';
  @override final String logout = 'Logout';
  @override final String reportSection = 'Report';
  @override final String customReportExport = 'Custom Report';
  @override final String excelPdfExport = 'Excel / PDF Export';
  @override final String organization = 'Organization';
  @override final String organizationName = 'Organization Name';
  @override final String enterOrgName = 'Enter organization name';
  @override final String saveName = 'Save Name';
  @override final String orgNameSaved = 'Organization name saved';
  @override final String collectorPermission = 'Collector Permission';
  @override final String collectorPermDesc = 'Control collector permissions from Super Admin';
  @override final String memberProfileEdit = 'Member Profile Edit';
  @override final String memberProfileEditDesc = 'Collector can edit member name and info';
  @override final String helpOutgoingEntry = 'Aid / Outgoing Entry';
  @override final String helpOutgoingDesc = 'Collector can record aid distribution';
  @override final String appSection = 'App';
  @override final String darkMode = 'Dark Mode';
  @override final String darkModeDesc = 'Use dark theme';
  @override final String aboutApp = 'About App';
  @override final String language = 'Language';
  @override final String bengali = 'Bengali';
  @override final String english = 'English';
  @override final String onlyBengali = 'Bengali';
  @override final String aboutDesc = 'Organization accounting, donation and aid distribution management app.';

  // Password Change
  @override final String currentPassword = 'Current Password';
  @override final String newPassword = 'New Password';
  @override final String confirmPassword = 'Confirm New Password';
  @override final String passwordUpdated = 'Password updated';
  @override final String passwordMismatch = 'Passwords do not match';

  // Validators
  @override final String enterPhone = 'Enter phone number';
  @override final String phoneMustBe11 = 'Phone number must be 11 digits';
  @override final String phoneMustStart01 = 'Phone number must start with 01';
  @override final String enterValidPhone = 'Enter valid phone number (01XXXXXXXXX)';
  @override final String enterAmount = 'Enter amount';
  @override final String enterNumber = 'Enter a number';
  @override final String amountMustBePositive = 'Amount must be greater than 0';
  @override final String minAmount10 = 'Minimum 10 Taka';
  @override final String maxAmount1Cr = 'Maximum 1 Crore Taka';
  @override final String enterName = 'Enter name';
  @override final String nameMin2 = 'Name must be at least 2 characters';
  @override final String enterEmail = 'Enter email';
  @override final String enterValidEmail = 'Enter valid email';
  @override final String enterPassword = 'Enter password';
  @override final String passwordMin6 = 'Password must be at least 6 characters';
  @override final String nidDigitsError = 'NID must be 10, 13 or 17 digits';

  // Receipt / PDF
  @override final String donationReceipt = 'Donation Receipt';
  @override final String receiptNo = 'Receipt No.';
  @override final String amount = 'Amount';
  @override final String taka = 'Taka';
  @override final String takaOnly = 'Taka Only';
  @override final String entryBy = 'Entered by';
  @override final String thankYou = 'Thank You';
  @override final String thankYouMsg = 'Thank you for your valuable contribution to social welfare.';
  @override final String socialWelfareOrg = 'Social Welfare Organization';
  @override final String receiptDownload = 'Receipt download';
  @override final String receiptFailed = 'Receipt generation failed';

  // Export
  @override final String memberListReport = 'Member List';
  @override final String collectionReport = 'Collection Report';
  @override final String monthlyCollection = 'Monthly Collection';
  @override final String total = 'Total';
  @override final String status = 'Status';
  @override final String active = 'Active';
  @override final String inactive = 'Inactive';
  @override final String month = 'Month';
  @override final String summary = 'Summary';
  @override final String subject = 'Subject';
  @override final String created = 'created';

  // Trash
  @override final String trash = 'Trash';
  @override final String moveToTrash = 'Move to Trash';
  @override final String moveToTrashConfirm = 'Are you sure you want to move this to trash?';
  @override final String restore = 'Restore';
  @override final String restoreConfirm = 'Restore this item?';
  @override final String permanentlyDelete = 'Permanently Delete';
  @override final String permanentlyDeleteConfirm = 'Permanently delete? This cannot be undone.';
  @override final String itemMovedToTrash = 'Moved to trash';
  @override final String itemRestored = 'Restored successfully';
  @override final String itemPermanentlyDeleted = 'Permanently deleted';
  @override final String noTrashItems = 'Trash is empty';
  @override final String emptyTrash = 'Empty Trash';
  @override final String emptyTrashConfirm = 'Permanently delete all items in trash? This cannot be undone.';
  @override final String trashEmptied = 'Trash emptied';

  // Bottom Nav
  @override final String navDashboard = 'Dashboard';
  @override final String navMembers = 'Members';
  @override final String navHelp = 'Aid';
  @override final String navSettings = 'Settings';

  // Collector Stats
  @override final String collectorCollectionSummary = 'Collector Collection Summary';
  @override final String collectorCollectionSummaryDesc = 'See how much each collector collected';
  @override final String totalCollected = 'Total Collected';
  @override final String totalEntries = 'Entries';
  @override final String noCollectorsYet = 'No collector data yet';
  @override final String myCollectionHistory = 'My Collection History';
  @override final String viewCollectionHistory = 'View Collection History';
  @override final String collectedBy = 'Collected by';

  // Months (short)
  @override final String jan = 'Jan';
  @override final String feb = 'Feb';
  @override final String mar = 'Mar';
  @override final String apr = 'Apr';
  @override final String may = 'May';
  @override final String jun = 'Jun';
  @override final String jul = 'Jul';
  @override final String aug = 'Aug';
  @override final String sep = 'Sep';
  @override final String oct = 'Oct';
  @override final String nov = 'Nov';
  @override final String dec = 'Dec';

  // Months (full)
  @override final String january = 'January';
  @override final String february = 'February';
  @override final String march = 'March';
  @override final String april = 'April';
  @override final String june = 'June';
  @override final String july = 'July';
  @override final String august = 'August';
  @override final String september = 'September';
  @override final String october = 'October';
  @override final String november = 'November';
  @override final String december = 'December';

  // Number Words
  @override final String zero = 'zero';
  @override final String one = 'one';
  @override final String two = 'two';
  @override final String three = 'three';
  @override final String four = 'four';
  @override final String five = 'five';
  @override final String six = 'six';
  @override final String seven = 'seven';
  @override final String eight = 'eight';
  @override final String nine = 'nine';
  @override final String ten = 'ten';
  @override final String twenty = 'twenty';
  @override final String thirty = 'thirty';
  @override final String forty = 'forty';
  @override final String fifty = 'fifty';
  @override final String sixty = 'sixty';
  @override final String seventy = 'seventy';
  @override final String eighty = 'eighty';
  @override final String ninety = 'ninety';
  @override final String hundred = 'hundred';
  @override final String thousand = 'thousand';
  @override final String lakh = 'lakh';
  @override final String crore = 'crore';

  // Dashboard chart months
  @override final String chartJan = 'Jan';
  @override final String chartFeb = 'Feb';
  @override final String chartMar = 'Mar';
  @override final String chartApr = 'Apr';
  @override final String chartMay = 'May';
  @override final String chartJun = 'Jun';
  @override final String chartJul = 'Jul';
  @override final String chartAug = 'Aug';
  @override final String chartSep = 'Sep';
  @override final String chartOct = 'Oct';
  @override final String chartNov = 'Nov';
  @override final String chartDec = 'Dec';

  @override final String person = 'person';
  @override final String failedPrefix = 'Failed';
  @override final String exportFailed = 'Export failed';
}
