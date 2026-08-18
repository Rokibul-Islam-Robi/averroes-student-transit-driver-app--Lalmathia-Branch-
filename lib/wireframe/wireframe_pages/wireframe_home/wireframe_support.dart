import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';

import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUPPORT PAGE — modern corporate contact card
// ════════════════════════════════════════════════════════════════════════════
class WireframeSupport extends StatefulWidget {
  const WireframeSupport({super.key});

  @override
  State<WireframeSupport> createState() => _WireframeSupportState();
}

class _WireframeSupportState extends State<WireframeSupport> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());

  Future<void> _launch(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'এই অ্যাকশনটি ওপেন করা গেলো না।',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'এই অ্যাকশনটি ওপেন করা গেলো না।',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Support'.tr,
      ),
      body: PageBackground(
        category: PageCategory.general,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: height / 36),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                      color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 26, vertical: height / 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height / 40),
                        Center(
                          child: Image.asset(
                            WireframePngimage.support,
                            height: height / 6.5,
                          ),
                        ),
                        SizedBox(height: height / 46),
                        Text(
                          "Get_Support".tr,
                          style: sansproBold.copyWith(fontSize: 22),
                        ),
                        SizedBox(height: height / 90),
                        Text(
                          "For_any_support_request_regards_your_orders_or_deliveries_please_feel_free_to_speak_with_us_at_below"
                              .tr,
                          textAlign: TextAlign.center,
                          style: sansproRegular.copyWith(
                              fontSize: 14.5, color: WireframeColor.textgray),
                        ),
                        SizedBox(height: height / 34),

                        // Corporate contact card
                        _buildContactCard(),
                        SizedBox(height: height / 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    // Unused 'dark' local variable was removed here for clean compilation
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 44),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22345FB4),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: height / 16,
            width: height / 16,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                WireframePngimage.averroesLogo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.school_rounded, color: WireframeColor.appcolor, size: height / 26),
              ),
            ),
          ),
          SizedBox(height: height / 90),
          Text(
            "Averroes International School Lalmatia",
            textAlign: TextAlign.center,
            style: sansproBold.copyWith(fontSize: 16, height: 1.25, color: WireframeColor.white),
          ),
          SizedBox(height: height / 150),
          Text(
            "House No – 7/16, Block – B, Lalmatia,\nMohammadpur, Dhaka - 1207",
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
                fontSize: 12.5, height: 1.4, color: Colors.white.withAlpha(215)),
          ),
          SizedBox(height: height / 55),
          Divider(color: Colors.white.withAlpha(45), thickness: 1),
          SizedBox(height: height / 70),

          _contactActionRow(
            icon: Icons.call_rounded,
            label: "+880 1954-123 123",
            tag: "WhatsApp",
            onTap: () => _launch(Uri.parse("tel:+8801954123123")),
          ),
          SizedBox(height: height / 90),
          _contactActionRow(
            icon: Icons.call_rounded,
            label: "+880 1949-000 555",
            onTap: () => _launch(Uri.parse("tel:+8801949000555")),
          ),
          SizedBox(height: height / 90),
          _contactActionRow(
            icon: Icons.call_rounded,
            label: "+880 1714 622 211",
            onTap: () => _launch(Uri.parse("tel:+8801714622211")),
          ),
          SizedBox(height: height / 90),
          _contactActionRow(
            icon: Icons.email_rounded,
            label: "info@aisl.edu.bd",
            onTap: () => _launch(Uri.parse("mailto:info@aisl.edu.bd")),
          ),

          SizedBox(height: height / 55),
          Divider(color: Colors.white.withAlpha(45), thickness: 1),
          SizedBox(height: height / 90),
          Text(
            "Copyright © 2026 Averroes International School Lalmatia.",
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(fontSize: 10.5, color: Colors.white.withAlpha(170)),
          ),
        ],
      ),
    );
  }

  Widget _contactActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? tag,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      highlightColor: Colors.white.withAlpha(20),
      splashColor: Colors.white.withAlpha(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 60, vertical: height / 200),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: WireframeColor.white),
            ),
            SizedBox(width: width / 40),
            Expanded(
              child: Text(
                label,
                style: sansproSemibold.copyWith(fontSize: 14, color: WireframeColor.white),
              ),
            ),
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff25D366).withAlpha(210),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: sansproSemibold.copyWith(fontSize: 10, color: WireframeColor.white),
                ),
              ),
            SizedBox(width: width / 60),
            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white.withAlpha(190)),
          ],
        ),
      ),
    );
  }
}