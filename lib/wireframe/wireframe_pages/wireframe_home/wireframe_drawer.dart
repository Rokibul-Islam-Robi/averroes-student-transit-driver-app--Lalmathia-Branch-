import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_academic_info.dart';
import 'student_controller.dart';
import 'fees_overview_page.dart';
import 'wireframe_about.dart';
import 'wireframe_facilities.dart';
import 'wireframe_profile.dart';
import 'wireframe_scholarship.dart';
import 'wireframe_settings.dart';
import 'wireframe_support.dart';

// ════════════════════════════════════════════════════════════════════════════
// APP SIDE DRAWER (আগের 3-dot PopupMenuButton-এর জায়গায় এখন modern corporate
// sidebar/drawer)।
//
// গঠন:
//   1) Header — "E-Student" brand badge + student photo/name/class (tap করলে
//      Profile page-এ যায়)
//   2) Menu list — Profile, About, School Facilities, School Fees,
//      Scholarship, Help & Support, Settings
//   3) নিচে Logout — আগের মতোই confirmation dialog দেখিয়ে
//      WireframeAcademicInfo (login flow) এ পাঠায়।
// ════════════════════════════════════════════════════════════════════════════
class WireframeAppDrawer extends StatelessWidget {
  const WireframeAppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final studentCtrl = Get.put(StudentController());

    return Drawer(
      backgroundColor: WireframeColor.white,
      width: width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(studentCtrl: studentCtrl, height: height, width: width),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: height / 56),
                children: [
                  _drawerItem(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    label: "Profile".tr,
                    onTap: () => _navigate(context, const WireframeProfile()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    label: "About".tr,
                    onTap: () => _navigate(context, const WireframeAbout()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.apartment_rounded,
                    label: "School_Facilities".tr,
                    onTap: () => _navigate(context, const WireframeFacilities()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.payments_outlined,
                    label: "School_Fees".tr,
                    onTap: () => _navigate(context, const FeesOverviewPage()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.school_outlined,
                    label: "Scholarship".tr,
                    onTap: () => _navigate(context, const WireframeScholarship()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 70),
                    child: Divider(color: WireframeColor.bggray),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    label: "Help_Support".tr,
                    onTap: () => _navigate(context, const WireframeSupport()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    label: "Settings".tr,
                    onTap: () => _navigate(context, const WireframeSettings()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 90),
              child: Divider(color: WireframeColor.bggray),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: height / 46, top: height / 150),
              child: _drawerItem(
                context: context,
                icon: Icons.logout_rounded,
                label: "Logout".tr,
                accent: WireframeColor.red,
                onTap: () {
                  Navigator.pop(context); // আগে drawer বন্ধ করা হচ্ছে
                  _confirmLogout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── drawer বন্ধ করে পেজে navigate করার helper ──
  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Logout confirmation — আগে wireframe_home.dart এর onbackpressed()-এ যেমন ছিল ঠিক সেভাবেই ──
  Future<void> _confirmLogout(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Center(
          child: Text(
            "Averroes International School",
            textAlign: TextAlign.end,
            style: sansproSemibold.copyWith(fontSize: 18),
          ),
        ),
        content: Text(
          "Are_You_sure_to_logout_from_this_app".tr,
          style: sansproRegular.copyWith(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WireframeColor.appcolor),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("No", style: sansproSemibold.copyWith(color: WireframeColor.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                dialogContext,
                MaterialPageRoute(builder: (_) => const WireframeAcademicInfo()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: WireframeColor.appcolor),
            child: Text("Yes", style: sansproSemibold.copyWith(color: WireframeColor.white)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color accent = WireframeColor.appcolor,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap,
      highlightColor: accent.withAlpha(18),
      splashColor: accent.withAlpha(18),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 90),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accent.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: height / 42, color: accent),
            ),
            SizedBox(width: width / 26),
            Expanded(
              child: Text(
                label,
                style: sansproSemibold.copyWith(fontSize: 15, color: WireframeColor.black),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: height / 42, color: WireframeColor.textgray),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Drawer header — "E-Student" brand badge + student identity card, ট্যাপ
// করলে সরাসরি Profile page-এ নিয়ে যায়।
// ════════════════════════════════════════════════════════════════════════════
class _DrawerHeader extends StatelessWidget {
  final StudentController studentCtrl;
  final double height;
  final double width;

  const _DrawerHeader({
    required this.studentCtrl,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WireframeProfile()));
      },
      child: Container(
        width: width,
        padding: EdgeInsets.fromLTRB(width / 22, height / 56, width / 22, height / 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0B1E4D), WireframeColor.appcolor, WireframeColor.lightappcolor],
            stops: [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── School brand badge — logo + official school name, সাইডবারের
            // সবচেয়ে উপরে (আগে এখানে শুধু "E-Student" লেখা ছিলো, স্কুলের নাম
            // ছিলো না — এখন logo-র পাশে পুরো official name দেখানো হচ্ছে) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(235),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      WireframePngimage.averroesLogo,
                      height: height / 36,
                      width: height / 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.school_rounded,
                        color: WireframeColor.appcolor,
                        size: height / 36,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width / 45),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Averroes International School",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sansproBold.copyWith(
                          fontSize: 12.5,
                          height: 1.2,
                          letterSpacing: 0.2,
                          color: Colors.white.withAlpha(235),
                        ),
                      ),
                      Text(
                        "Lalmatia",
                        style: sansproBold.copyWith(
                          fontSize: 12.5,
                          height: 1.2,
                          letterSpacing: 0.6,
                          color: const Color(0xffFFC94D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 40),

            // ── Student identity card ──
            Row(
              children: [
                Obx(() {
                  final profile = studentCtrl.profile.value;
                  return Container(
                    height: height / 14,
                    width: height / 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(90), width: 1.4),
                      image: (profile != null && profile.profilePhotoUrl.isNotEmpty)
                          ? DecorationImage(
                          image: NetworkImage(profile.profilePhotoUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: (profile == null || profile.profilePhotoUrl.isEmpty)
                        ? Icon(Icons.person, color: WireframeColor.white, size: height / 24)
                        : null,
                  );
                }),
                SizedBox(width: width / 32),
                Expanded(
                  child: Obx(() {
                    final profile = studentCtrl.profile.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.studentName ?? "Hi Student".tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sansproBold.copyWith(fontSize: 16, color: WireframeColor.white),
                        ),
                        SizedBox(height: height / 250),
                        Text(
                          profile != null
                              ? "Class ${profile.className}-${profile.section}  •  Roll ${profile.rollNo}"
                              : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sansproRegular.copyWith(
                              fontSize: 12, color: Colors.white.withAlpha(210)),
                        ),
                      ],
                    );
                  }),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withAlpha(200), size: height / 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
