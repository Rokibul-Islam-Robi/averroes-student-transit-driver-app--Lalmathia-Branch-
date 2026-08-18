import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'live_now_card.dart';

// ── Live Now menu item এর জন্য পেজ। মূল card widget (LiveNowCard) আগে থেকেই
// আছে, এখানে শুধু সেটাকে একটা Scaffold/AppBar দিয়ে wrap করা হলো যাতে
// dashboard এর "Live Now" মেনু থেকে Navigator.push কাজ করে। আসল লাইভ ক্লাস
// লিস্ট API আসার পর এই পেজে যোগ করা যাবে। ──
class LiveNowPage extends StatelessWidget {
  const LiveNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF3F5FB),
      appBar: AppBar(
        backgroundColor: WireframeColor.appcolor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Live Now",
          style: sansproSemibold.copyWith(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width / 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LiveNowCard(width: width - (width / 13), height: height / 8),
            SizedBox(height: height / 40),
            Expanded(
              child: Center(
                child: Text(
                  "লাইভ ক্লাসের তালিকা শীঘ্রই যুক্ত হবে",
                  textAlign: TextAlign.center,
                  style: sansproRegular.copyWith(
                    fontSize: 14,
                    color: WireframeColor.textgray,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
