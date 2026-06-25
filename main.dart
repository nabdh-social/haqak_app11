import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.primaryBlue,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'حقك كمواطن يمني',
            debugShowCheckedModeBanner: false,
            theme: provider.isDarkMode ? AppColors.darkTheme : AppColors.lightTheme,
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// الألوان والثيم
// ═══════════════════════════════════════════════════════════════
class AppColors {
  static const Color primaryBlue = Color(0xFF0B1F3B);
  static const Color gold = Color(0xFFB8860B);
  static const Color goldLight = Color(0xFFF4E8C1);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF6C757D);
  static const Color success = Color(0xFF28A745);
  static const Color danger = Color(0xFFDC3545);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: background,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: gold,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    ),
    cardTheme: CardTheme(color: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: gold,
    scaffoldBackgroundColor: const Color(0xFF0A0E1A),
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.dark(primary: gold, secondary: primaryBlue, surface: Color(0xFF1A1F2E)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1F2E),
      foregroundColor: gold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: gold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1F2E),
      selectedItemColor: gold,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardTheme(color: const Color(0xFF1A1F2E), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
  );
}

// ═══════════════════════════════════════════════════════════════
// مزود الحالة
// ═══════════════════════════════════════════════════════════════
class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  int _bottomNavIndex = 0;
  Map<String, dynamic>? _userData;

  bool get isDarkMode => _isDarkMode;
  int get bottomNavIndex => _bottomNavIndex;
  Map<String, dynamic>? get userData => _userData;

  AppProvider() { _loadData(); }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    final userDataStr = prefs.getString('userData');
    if (userDataStr != null) _userData = jsonDecode(userDataStr);
    notifyListeners();
  }

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    _userData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(data));
    notifyListeners();
  }

  Future<void> logout() async {
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة البداية
// ═══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0B1F3B), Color(0xFF1A3A5F), Color(0xFF0B1F3B)])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeTransition(opacity: _fadeAnimation, child: ScaleTransition(scale: _scaleAnimation, child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])),
              child: const Icon(Icons.balance, size: 90, color: AppColors.primaryBlue),
            ))),
            const SizedBox(height: 40),
            FadeTransition(opacity: _fadeAnimation, child: const Text('حقك كمواطن يمني', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.gold, fontFamily: 'Cairo'))),
            const SizedBox(height: 12),
            FadeTransition(opacity: _fadeAnimation, child: const Text('دليلك القانوني الشامل', style: TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'Tajawal'))),
            const Spacer(),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة تسجيل الدخول
// ═══════════════════════════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(width: 120, height: 120, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD4AF37), AppColors.gold]), shape: BoxShape.circle), child: const Icon(Icons.balance, color: AppColors.primaryBlue, size: 60)),
              const SizedBox(height: 30),
              const Text('حقك كمواطن يمني', style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              const SizedBox(height: 50),
              _LoginCard(icon: Icons.person, title: 'مواطن يمني', subtitle: 'الوصول إلى القوانين والاستشارات', color: AppColors.primaryBlue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CitizenLoginScreen()))),
              const SizedBox(height: 16),
              _LoginCard(icon: Icons.gavel, title: 'محامي', subtitle: 'تقديم الاستشارات القانونية', color: AppColors.gold, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LawyerLoginScreen()))),
              const SizedBox(height: 30),
              TextButton(onPressed: () => context.read<AppProvider>().saveUserData({'name': 'ضيف', 'type': 'citizen'}), child: const Text('تصفح كضيف')),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _LoginCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 35)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontFamily: 'Tajawal')),
        ])),
        const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
      ]),
    ));
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة تسجيل المواطن
// ═══════════════════════════════════════════════════════════════
class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({super.key});
  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _email.dispose(); super.dispose(); }

  void _login() {
    if (_name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الاسم والهاتف'), backgroundColor: AppColors.danger));
      return;
    }
    context.read<AppProvider>().saveUserData({'name': _name.text, 'phone': _phone.text, 'email': _email.text, 'type': 'citizen'});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل كمواطن')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مرحباً بك', style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          const SizedBox(height: 30),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 16),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone))),
          const SizedBox(height: 16),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _login, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)))),
        ],
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة تسجيل المحامي
// ═══════════════════════════════════════════════════════════════
class LawyerLoginScreen extends StatefulWidget {
  const LawyerLoginScreen({super.key});
  @override
  State<LawyerLoginScreen> createState() => _LawyerLoginScreenState();
}

class _LawyerLoginScreenState extends State<LawyerLoginScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _bar = TextEditingController();
  final _spec = TextEditingController();
  final _years = TextEditingController();
  final _fee = TextEditingController();

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _email.dispose(); _bar.dispose(); _spec.dispose(); _years.dispose(); _fee.dispose(); super.dispose(); }

  void _register() {
    if (_name.text.isEmpty || _phone.text.isEmpty || _email.text.isEmpty || _bar.text.isEmpty || _spec.text.isEmpty || _years.text.isEmpty || _fee.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل جميع الحقول'), backgroundColor: AppColors.danger));
      return;
    }
    context.read<AppProvider>().saveUserData({
      'name': _name.text, 'phone': _phone.text, 'email': _email.text,
      'barNumber': _bar.text, 'specialization': _spec.text,
      'yearsOfExperience': int.parse(_years.text),
      'consultationFee': double.parse(_fee.text),
      'type': 'lawyer',
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LawyerDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل كمحامي'), backgroundColor: AppColors.gold, foregroundColor: AppColors.primaryBlue),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('انضم كمحامي', style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          const SizedBox(height: 30),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم')),
          const SizedBox(height: 16),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'الهاتف')),
          const SizedBox(height: 16),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'البريد')),
          const SizedBox(height: 16),
          TextField(controller: _bar, decoration: const InputDecoration(labelText: 'رقم القيد')),
          const SizedBox(height: 16),
          TextField(controller: _spec, decoration: const InputDecoration(labelText: 'التخصص')),
          const SizedBox(height: 16),
          TextField(controller: _years, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سنوات الخبرة')),
          const SizedBox(height: 16),
          TextField(controller: _fee, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رسوم الاستشارة')),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _register, style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('تسجيل كمحامي', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)))),
        ],
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة التنقل الرئيسية
// ═══════════════════════════════════════════════════════════════
class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final screens = [const HomeScreen(), const LawsScreen(), const ConsultationScreen(), const ServicesScreen(), const ProfileScreen()];
      return Scaffold(
        body: screens[provider.bottomNavIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: provider.bottomNavIndex,
          onTap: (i) => provider.setBottomNavIndex(i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'القوانين'),
            BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'استشارات'),
            BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'خدماتي'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// الشاشة الرئيسية
// ═══════════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حقك كمواطن يمني')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF1A3A5F)]), borderRadius: BorderRadius.circular(16)), child: const Column(children: [Icon(Icons.balance, size: 60, color: AppColors.gold), SizedBox(height: 12), Text('مرحباً بك في دليلك القانوني', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Cairo', fontWeight: FontWeight.bold))])),
        const SizedBox(height: 24),
        const Text('الخدمات السريعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        const SizedBox(height: 12),
        _QuickCard(icon: Icons.gavel, title: 'القوانين', color: AppColors.primaryBlue, onTap: () => context.read<AppProvider>().setBottomNavIndex(1)),
        const SizedBox(height: 12),
        _QuickCard(icon: Icons.calculate, title: 'حاسبة الحقوق', color: AppColors.gold, onTap: () {}),
        const SizedBox(height: 12),
        _QuickCard(icon: Icons.support_agent, title: 'استشارة محامي', color: const Color(0xFF2C5282), onTap: () => context.read<AppProvider>().setBottomNavIndex(2)),
        const SizedBox(height: 12),
        _QuickCard(icon: Icons.file_present, title: 'نماذج عقود', color: const Color(0xFF3A6EA5), onTap: () => context.read<AppProvider>().setBottomNavIndex(3)),
      ]),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon; final String title; final Color color; final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.title, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, color: Colors.white, size: 32), const SizedBox(width: 16), Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Cairo', fontWeight: FontWeight.bold))])));
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة القوانين
// ═══════════════════════════════════════════════════════════════
class LawsScreen extends StatelessWidget {
  const LawsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final laws = [
      {'icon': '💼', 'title': 'قانون العمل', 'color': AppColors.primaryBlue},
      {'icon': '🏛️', 'title': 'الخدمة المدنية', 'color': const Color(0xFF1E3A5F)},
      {'icon': '👨‍👩‍👧', 'title': 'الأحوال الشخصية', 'color': const Color(0xFF2C5282)},
      {'icon': '📊', 'title': 'القانون التجاري', 'color': const Color(0xFF3A6EA5)},
      {'icon': '⚖️', 'title': 'قانون العقوبات', 'color': AppColors.primaryBlue},
      {'icon': '📜', 'title': 'المرافعات', 'color': const Color(0xFF1E3A5F)},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('المكتبة القانونية')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: laws.length,
        itemBuilder: (context, index) {
          final law = laws[index];
          return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
            leading: CircleAvatar(backgroundColor: law['color'], child: Text(law['icon'], style: const TextStyle(fontSize: 20))),
            title: Text(law['title'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_back_ios),
          ));
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة الاستشارات
// ═══════════════════════════════════════════════════════════════
class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final List<Map<String, dynamic>> _messages = [
    {'isBot': true, 'text': 'مرحباً بك! أنا المساعد القانوني الذكي. كيف يمكنني مساعدتك اليوم؟'},
  ];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'isBot': false, 'text': _controller.text});
    });
    final userMessage = _controller.text;
    _controller.clear();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({'isBot': true, 'text': 'شكراً لسؤالك. للحصول على استشارة قانونية مفصلة، تواصل مع المحامي مباشرة عبر واتساب.'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استشارة قانونية')),
      body: Column(
        children: [
          Container(width: double.infinity, padding: const EdgeInsets.all(12), color: AppColors.gold.withOpacity(0.1), child: const Row(children: [Icon(Icons.info_outline, color: AppColors.gold, size: 20), SizedBox(width: 8), Expanded(child: Text('المحادثة مجانية - للاستشارات المعقدة تواصل مع المحامي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: AppColors.textDark)))])),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _MessageBubble(text: message['text'], isBot: message['isBot']);
            },
          )),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white),
            child: SafeArea(child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'اكتب سؤالك القانوني...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)), onSubmitted: (_) => _sendMessage())),
                Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF1A3A5F)]), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.send, color: AppColors.gold), onPressed: _sendMessage)),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text; final bool isBot;
  const _MessageBubble({required this.text, required this.isBot});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) Container(width: 36, height: 36, decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF1A3A5F)]), shape: BoxShape.circle), child: const Icon(Icons.smart_toy, color: AppColors.gold, size: 20)),
          const SizedBox(width: 8),
          Flexible(child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isBot ? Colors.white : AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isBot ? 4 : 16),
                bottomRight: Radius.circular(isBot ? 16 : 4),
              ),
            ),
            child: Text(text, style: TextStyle(color: isBot ? AppColors.textDark : Colors.white, fontFamily: 'Tajawal', fontSize: 14, height: 1.5)),
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة الخدمات
// ═══════════════════════════════════════════════════════════════
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خدماتي')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF1A3A5F)]), borderRadius: BorderRadius.circular(16)), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('خدمات قانونية متكاملة', style: TextStyle(color: AppColors.gold, fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 6), Text('اختر الخدمة التي تناسبك', style: TextStyle(color: Colors.white70, fontFamily: 'Tajawal', fontSize: 13))])), Icon(Icons.apps, color: AppColors.gold, size: 40)])),
        const SizedBox(height: 24),
        const Text('الأدوات القانونية', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        const SizedBox(height: 12),
        _ServiceCard(icon: Icons.calculate, title: 'حاسبة الحقوق', subtitle: 'احسب مستحقاتك', color: AppColors.gold, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorScreen()))),
        const SizedBox(height: 12),
        _ServiceCard(icon: Icons.file_contract, title: 'نماذج العقود', subtitle: 'عقود جاهزة', color: AppColors.primaryBlue, onTap: () {}),
        const SizedBox(height: 12),
        _ServiceCard(icon: Icons.calendar_today, title: 'حجز موعد', subtitle: 'استشارة مباشرة', color: const Color(0xFF2C5282), onTap: () {}),
        const SizedBox(height: 12),
        _ServiceCard(icon: Icons.flight_takeoff, title: 'قسم المغتربين', subtitle: 'حقوقك في الخليج', color: const Color(0xFF3A6EA5), onTap: () {}),
      ]),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _ServiceCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: color, fontSize: 14)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontFamily: 'Tajawal', color: AppColors.textLight, fontSize: 11))])), const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textLight)])));
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة حاسبة الحقوق
// ═══════════════════════════════════════════════════════════════
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _salary = TextEditingController(text: '150000');
  final _years = TextEditingController(text: '5');
  final _months = TextEditingController(text: '6');
  final _unusedLeave = TextEditingController(text: '15');
  String? _result;

  void _calculate() {
    final salary = double.tryParse(_salary.text.replaceAll(',', '')) ?? 0;
    final years = double.tryParse(_years.text) ?? 0;
    final months = double.tryParse(_months.text) ?? 0;
    final unusedLeave = double.tryParse(_unusedLeave.text) ?? 0;

    final totalYears = years + (months / 12);
    final endOfService = salary * totalYears;
    final leaveAllowance = (salary / 26) * unusedLeave;
    final total = endOfService + leaveAllowance;

    setState(() {
      _result = '${total.toStringAsFixed(0)} ريال يمني';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة الحقوق العمالية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF1A3A5F)]), borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.info_outline, color: AppColors.gold, size: 28), SizedBox(width: 12), Expanded(child: Text('احسب مستحقاتك القانونية بدقة وفقاً لقانون العمل اليمني', style: TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontSize: 14)))])),
            const SizedBox(height: 24),
            TextField(controller: _salary, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الراتب الأساسي (ريال يمني)', prefixIcon: Icon(Icons.attach_money))),
            const SizedBox(height: 16),
            TextField(controller: _years, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سنوات الخدمة', prefixIcon: Icon(Icons.calendar_today))),
            const SizedBox(height: 16),
            TextField(controller: _months, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الأشهر الإضافية', prefixIcon: Icon(Icons.date_range))),
            const SizedBox(height: 16),
            TextField(controller: _unusedLeave, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'أيام الإجازة غير المستغلة', prefixIcon: Icon(Icons.beach_access))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculate, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('احسب مستحقاتي', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)))),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFD4AF37)]), borderRadius: BorderRadius.circular(16)), child: Column(children: [const Text('إجمالي مستحقاتك', style: TextStyle(color: AppColors.primaryBlue, fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(_result!, style: const TextStyle(color: AppColors.primaryBlue, fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.bold))])),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة الحساب الشخصي
// ═══════════════════════════════════════════════════════════════
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final userData = provider.userData;
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي'), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout())]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF1A3A5F)]), borderRadius: BorderRadius.circular(16)), child: Row(children: [Container(width: 70, height: 70, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle), child: Center(child: Text(userData?['name']?[0] ?? 'م', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontFamily: 'Cairo')))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(userData?['name'] ?? 'ضيف', style: const TextStyle(color: AppColors.gold, fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(userData?['phone'] ?? '', style: const TextStyle(color: Colors.white70, fontFamily: 'Tajawal', fontSize: 13))]))])),
        const SizedBox(height: 24),
        _MenuItem(icon: Icons.history, title: 'سجل الاستشارات', subtitle: 'جميع استشاراتك السابقة', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.favorite_border, title: 'المفضلة', subtitle: 'القوانين المحفوظة', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.notifications, title: 'الإشعارات', subtitle: 'إدارة الإشعارات', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.dark_mode, title: 'الوضع الليلي', subtitle: 'تفعيل الوضع الداكن', trailing: Switch(value: provider.isDarkMode, onChanged: (_) => provider.toggleDarkMode(), activeColor: AppColors.gold), onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.help_outline, title: 'المساعدة والدعم', subtitle: 'الأسئلة الشائعة', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.privacy_tip_outlined, title: 'سياسة الخصوصية', subtitle: 'اقرأ سياسة الخصوصية', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.info_outline, title: 'عن التطبيق', subtitle: 'الإصدار 1.0.0', onTap: () {}),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => provider.logout(), icon: const Icon(Icons.logout, color: AppColors.danger), label: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.danger, fontFamily: 'Cairo')), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger), padding: const EdgeInsets.symmetric(vertical: 14)))),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Widget? trailing; final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.title, required this.subtitle, this.trailing, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primaryBlue, size: 22)),
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppColors.textLight)),
      trailing: trailing ?? const Icon(Icons.arrow_back_ios, size: 16),
      onTap: onTap,
    ));
  }
}

// ═══════════════════════════════════════════════════════════════
// شاشة لوحة المحامي
// ═══════════════════════════════════════════════════════════════
class LawyerDashboard extends StatelessWidget {
  const LawyerDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final userData = provider.userData ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة المحامي'), backgroundColor: AppColors.gold, foregroundColor: AppColors.primaryBlue, actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout())]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFD4AF37)]), borderRadius: BorderRadius.circular(16)), child: Column(children: [const Icon(Icons.gavel, size: 60, color: AppColors.primaryBlue), const SizedBox(height: 12), Text(userData['name'] ?? '', style: const TextStyle(color: AppColors.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')), Text(userData['specialization'] ?? '', style: const TextStyle(color: AppColors.primaryBlue, fontFamily: 'Tajawal'))])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _StatCard(icon: Icons.forum, value: '${userData['consultationsCount'] ?? 0}', label: 'استشارة', color: AppColors.primaryBlue)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(icon: Icons.star, value: '${userData['rating'] ?? '0.0'}', label: 'التقييم', color: AppColors.gold)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(icon: Icons.attach_money, value: '${userData['consultationFee'] ?? 0}', label: 'ريال', color: const Color(0xFF2C5282))),
        ]),
        const SizedBox(height: 20),
        const Text('إدارة الخدمات', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        const SizedBox(height: 12),
        _MenuItem(icon: Icons.inbox, title: 'الاستشارات الواردة', subtitle: '0 استشارة جديدة', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.calendar_today, title: 'المواعيد', subtitle: 'إدارة مواعيدك', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.account_balance_wallet, title: 'المحفظة', subtitle: 'الأرباح والمدفوعات', onTap: () {}),
        const SizedBox(height: 8),
        _MenuItem(icon: Icons.analytics, title: 'الإحصائيات', subtitle: 'تقارير الأداء', onTap: () {}),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 8), Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontFamily: 'Tajawal'))])));
  }
}
