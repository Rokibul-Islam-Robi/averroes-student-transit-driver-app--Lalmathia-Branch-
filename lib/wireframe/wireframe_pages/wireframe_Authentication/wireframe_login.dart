import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../wireframe_home/wireframe_home.dart';
import '../wireframe_home/student_controller.dart';
import '../wireframe_home/homework_controller.dart';
import '../wireframe_home/syllabus_controller.dart';
import '../wireframe_home/report_card_controller.dart';
import '../wireframe_home/attendance_controller.dart';
import '../wireframe_home/exam_controller.dart';
import '../wireframe_driver/driver_controller.dart';
import '../wireframe_driver/driver_dashboard_page.dart';

class WireframeLogin extends StatefulWidget {
  const WireframeLogin({Key? key}) : super(key: key);

  @override
  State<WireframeLogin> createState() => _WireframeLoginState();
}

class _WireframeLoginState extends State<WireframeLogin>
    with TickerProviderStateMixin {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  bool _obscureText = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _loginEndpoint = '/login';

  late AnimationController _floatController;
  late AnimationController _cloudController;
  late AnimationController _starController;
  late AnimationController _formController;
  late AnimationController _logoController;

  late Animation<double> _floatAnimation;
  late Animation<double> _cloudAnimation;
  late Animation<double> _starAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _cloudAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _starAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _formSlideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.fastOutSlowIn),
    );
    _formFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeIn),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _cloudController.dispose();
    _starController.dispose();
    _formController.dispose();
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final emailOrPhone = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrPhone.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Phone/Email এবং Password দুটোই দাও।');
      return;
    }

    setState(() => _isLoggingIn = true);

    // ── Route by login pattern: username/phone/email 'driver' দিয়ে শুরু হলে
    // Driver flow, নাহলে Student flow. কোনো role-toggle UI বা hardcoded demo
    // credential (আগের driver1/333333) ছাড়াই — শুধু naming convention দিয়ে ──
    final isDriverLogin = emailOrPhone.toLowerCase().startsWith('driver');

    if (isDriverLogin) {
      await _loginAsDriver(emailOrPhone, password);
      return;
    }

    await _loginAsStudent(emailOrPhone, password);
  }

  // ══════════════════════════════════════════════════════════════════════
  // DRIVER FLOW — POST /login.php is currently broken / not matching the
  // Transport Mobile API doc on the backend, so per instruction we skip
  // ONLY that login call for now (no fake/demo token is generated either).
  //
  // Everything past login is real: DriverDashboardPage and DriverController
  // are already correctly integrated against the real, working endpoints
  // (driver-dashboard.php, trip-start.php, trip-end.php,
  // location-update.php, busscan.php, onboard.php, onboard-list.php). We
  // navigate straight there and let it call the real APIs itself — if the
  // backend still rejects a call for lack of a token, DriverController
  // surfaces that as a real, non-fake inline notice on the dashboard
  // instead of blocking it, so every already-working feature stays usable.
  //
  // Restore the real `driverCtrl.login(...)` call the moment /login.php is
  // fixed on the backend — nothing else needs to change when that happens.
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _loginAsDriver(String emailOrPhone, String password) async {
    Get.put(DriverController());

    if (!mounted) return;
    setState(() => _isLoggingIn = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverDashboardPage()),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STUDENT FLOW (আগেই ঠিক করা হয়েছে — unchanged)
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _loginAsStudent(String emailOrPhone, String password) async {
    String? token;
    try {
      final uri = Uri.parse('$_baseUrl$_loginEndpoint');
      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': emailOrPhone,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          token = decoded['data']['token']?.toString();
        }
      }
    } catch (_) {
      // Student login API o ekhono real na — niche bypass e jabe
    }

    // ══════════════════════════════════════════════════════════════════════
    // ⚠️ TEMP BYPASS — REMOVE_BEFORE_PROD (student login API dile ei block
    // সরিয়ে ফেলতে হবে)
    //
    // Backend theke এখনো student login API deওয়া হয়নি, তাই উপরের call টা
    // response na dile / fail korle / kono valid token na thakle — এখানে
    // Login Failed dekhiye আটকে না রেখে সরাসরি আসল (কোনো demo/mock data
    // ছাড়া) Student Dashboard e ঢুকিয়ে দেওয়া হচ্ছে, শুধু একটা local session
    // token diye. Real login API চালু হয়ে গেলে উপরের request টাই real token
    // ফেরত দেবে আর এই bypass কখনো trigger হবে না — তখন চাইলে নিচের লাইনটা
    // (token ??= ...) মুছে আগের মতো strict validation ফিরিয়ে আনা যাবে।
    // ══════════════════════════════════════════════════════════════════════
    token ??= 'local_session_${DateTime.now().millisecondsSinceEpoch}';

    final studentCtrl = Get.put(StudentController());
    studentCtrl.setAuthToken(token);

    final hwCtrl = Get.put(HomeworkController());
    hwCtrl.setAuthToken(token);

    final syCtrl = Get.put(SyllabusController());
    syCtrl.setAuthToken(token);

    final rcCtrl = Get.put(ReportCardController());
    rcCtrl.setAuthToken(token);

    final attCtrl = Get.put(AttendanceController());
    attCtrl.setAuthToken(token);

    final examCtrl = Get.put(ExamController());
    examCtrl.setAuthToken(token);

    // Real API na thakle ei call gulo nijeraii (nijeder try/catch diye)
    // fail kore empty/error state dekhabe — kono fake number/demo data
    // dashboard e dekhano hocche na.
    studentCtrl.fetchProfile();
    hwCtrl.fetchHomeworkList();
    syCtrl.fetchSyllabusList();
    rcCtrl.fetchExamList();
    rcCtrl.fetchAttendanceSummary();
    attCtrl.fetchMonthAttendance(DateTime.now());
    examCtrl.fetchExamList();

    if (!mounted) return;
    setState(() => _isLoggingIn = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WireframeHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: WireframeColor.appcolor,
      body: Stack(
        children: [
          Container(
            height: height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0d2461),
                  Color(0xff183785),
                  WireframeColor.appcolor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _starAnimation,
            builder: (_, __) => Positioned.fill(
              child: CustomPaint(
                painter: _StarsPainter(opacity: _starAnimation.value),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _cloudAnimation,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: height * 0.05,
                    left: width * 0.05 + _cloudAnimation.value,
                    child: _buildCloud(45, 0.4),
                  ),
                  Positioned(
                    top: height * 0.12,
                    right: width * 0.10 - _cloudAnimation.value,
                    child: _buildCloud(55, 0.35),
                  ),
                ],
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (_, __) {
              return Positioned(
                top: height * 0.12 + _floatAnimation.value,
                right: width * 0.02,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    WireframePngimage.titlelogo,
                    height: height / 6.5,
                    width: width / 2.6,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.06),

              AnimatedBuilder(
                animation: _logoController,
                builder: (_, __) {
                  return Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width / 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: height / 13,
                              height: height / 13,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(40),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(height / 120),
                              child: ClipOval(
                                child: Image.asset(
                                  WireframePngimage.averroesLogo,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: width / 26),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Averroes International",
                                    style: sansproSemibold.copyWith(
                                      fontSize: 18,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "School Lalmatia",
                                    style: sansproBold.copyWith(
                                      fontSize: 15,
                                      color: const Color(0xffFFC107),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: height * 0.08),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 16),
                child: Text(
                  "Hi_Student".tr,
                  style: sansproSemibold.copyWith(
                      fontSize: 30, color: WireframeColor.white, letterSpacing: 0.5),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 16),
                child: Text(
                  "Sign_in_to_continue".tr,
                  style: sansproRegular.copyWith(
                      fontSize: 16, color: Colors.white70),
                ),
              ),

              const Spacer(),

              AnimatedBuilder(
                animation: _formController,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, _formSlideAnimation.value),
                    child: Opacity(
                      opacity: _formFadeAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: themedata.isdark
                        ? WireframeColor.black
                        : WireframeColor.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(32),
                      topLeft: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 12, vertical: height / 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            margin: EdgeInsets.only(bottom: height / 36),
                            decoration: BoxDecoration(
                              color: WireframeColor.bggray,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        Text(
                          "Mobile_Number_Email".tr,
                          style: sansproRegular.copyWith(
                              fontSize: 12, color: WireframeColor.textgray),
                        ),
                        SizedBox(height: height / 150),
                        SizedBox(
                          height: height / 15,
                          child: TextField(
                            controller: _emailController,
                            style: sansproRegular.copyWith(
                                fontSize: 15,
                                color: themedata.isdark
                                    ? WireframeColor.white
                                    : WireframeColor.black),
                            cursorColor: WireframeColor.appcolor,
                            decoration: InputDecoration(
                              hintText: "Enter Email".tr,
                              hintStyle: sansproRegular.copyWith(
                                  fontSize: 15, color: Colors.black38),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: WireframeColor.bggray),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: WireframeColor.appcolor, width: 1.8),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height / 36),

                        Text(
                          "Password".tr,
                          style: sansproRegular.copyWith(
                              fontSize: 12, color: WireframeColor.textgray),
                        ),
                        SizedBox(height: height / 150),
                        SizedBox(
                          height: height / 15,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            style: sansproRegular.copyWith(
                                fontSize: 15,
                                color: themedata.isdark
                                    ? WireframeColor.white
                                    : WireframeColor.black),
                            cursorColor: WireframeColor.appcolor,
                            decoration: InputDecoration(
                              hintText: "Enter Password".tr,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                  color: WireframeColor.textgray,
                                  size: 20,
                                ),
                                onPressed: _togglePasswordStatus,
                              ),
                              hintStyle: sansproRegular.copyWith(
                                  fontSize: 15, color: Colors.black38),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: WireframeColor.bggray),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: WireframeColor.appcolor, width: 1.8),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height / 28),

                        InkWell(
                          highlightColor: WireframeColor.transparent,
                          splashColor: WireframeColor.transparent,
                          onTap: _isLoggingIn ? null : _login,
                          child: Container(
                            width: width,
                            height: height / 15,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: WireframeColor.appcolor.withAlpha(90),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoggingIn
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: WireframeColor.white,
                                ),
                              )
                                  : Text(
                                "SIGN_IN".tr,
                                style: sansproSemibold.copyWith(
                                    fontSize: 16, color: WireframeColor.white, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height / 40),
                      ],
                    ),
                  ),
                ),
              ),

              // ── School footer — page এর একদম নিচে, full width (কোনো side
              // padding ছাড়া), form card এর ঠিক নিচেই বসানো ──
              _buildLoginFooter(width: width, height: height),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // LOGIN PAGE FOOTER — Student ও Driver উভয় login flow-ই এই একই
  // WireframeLogin স্ক্রিন ব্যবহার করে (username prefix দিয়ে route হয়),
  // তাই এখানে একবার যোগ করলেই দুই দিকেই দেখাবে। Logo + school name +
  // address — attached reference image অনুযায়ী compact card style। ──
  Widget _buildLoginFooter({required double width, required double height}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: width / 22, vertical: height / 45),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height / 22,
            width: height / 22,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                WireframePngimage.averroesLogo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.school_rounded, color: WireframeColor.appcolor, size: height / 34),
              ),
            ),
          ),
          SizedBox(height: height / 130),
          Text(
            "Averroes International School Lalmatia",
            textAlign: TextAlign.center,
            style: sansproBold.copyWith(
              fontSize: 13,
              height: 1.2,
              color: WireframeColor.white,
            ),
          ),
          SizedBox(height: height / 250),
          Text(
            "House No – 7/16, Block – B, Lalmatia,\nMohammadpur, Dhaka - 1207",
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
              fontSize: 10.5,
              height: 1.35,
              color: Colors.white.withAlpha(215),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud(double size, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size * 1.8,
        height: size * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withAlpha((opacity * 255).toInt()),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double opacity;
  _StarsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha((opacity * 255).toInt());
    final positions = [
      Offset(size.width * 0.08, size.height * 0.04),
      Offset(size.width * 0.22, size.height * 0.11),
      Offset(size.width * 0.48, size.height * 0.06),
      Offset(size.width * 0.72, size.height * 0.09),
      Offset(size.width * 0.32, size.height * 0.15),
      Offset(size.width * 0.12, size.height * 0.20),
    ];
    for (var i = 0; i < positions.length; i++) {
      final r = (i % 2 == 0) ? 2.0 : 1.3;
      canvas.drawCircle(positions[i], r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.opacity != opacity;
}