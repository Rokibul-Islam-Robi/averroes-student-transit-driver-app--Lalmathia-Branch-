import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';

class SmartClassRoomPage extends StatefulWidget {
  const SmartClassRoomPage({super.key});

  @override
  State<SmartClassRoomPage> createState() => _SmartClassRoomPageState();
}

class _SmartClassRoomPageState extends State<SmartClassRoomPage> {
  final themedata = Get.put(WireframeThemecontroler());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(
        title: 'Smart Class Room',
      ),
      body: PageBackground(
        category: PageCategory.smartClassRoom,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 26, vertical: height / 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(width, height),
                      SizedBox(height: height / 30),
                      Text(
                        "Available Smart Classes",
                        style: sansproBold.copyWith(
                          fontSize: 18,
                          color: themedata.isdark
                              ? WireframeColor.white
                              : WireframeColor.black,
                        ),
                      ),
                      SizedBox(height: height / 50),
                      _buildClassCard(
                        subject: "Chemistry Interactive Session",
                        code: "CH-102",
                        time: "10:00 AM - 11:00 AM",
                        status: "Active",
                        height: height,
                        width: width,
                      ),
                      SizedBox(height: height / 60),
                      _buildClassCard(
                        subject: "Biology Virtual Lab",
                        code: "BIO-201",
                        time: "02:00 PM - 03:00 PM",
                        status: "Upcoming",
                        height: height,
                        width: width,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(double width, double height) {
    return Container(
      width: width,
      padding: EdgeInsets.all(width / 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff4F46E5), Color(0xff7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.meeting_room_rounded, color: Colors.white, size: 28),
              SizedBox(width: width / 30),
              Text(
                "Digital Classroom",
                style: sansproBold.copyWith(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Access live interactive Google Meet sessions and section-wise class discussions.",
            style: sansproRegular.copyWith(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard({
    required String subject,
    required String code,
    required String time,
    required String status,
    required double height,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width / 26),
      decoration: BoxDecoration(
        color: themedata.isdark ? WireframeColor.lightblack : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WireframeColor.bggray.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code,
                style: sansproBold.copyWith(
                  fontSize: 12,
                  color: WireframeColor.appcolor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == "Active"
                      ? Colors.green.withAlpha(30)
                      : Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: sansproSemibold.copyWith(
                    fontSize: 11,
                    color: status == "Active" ? Colors.green[800] : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subject,
            style: sansproBold.copyWith(
              fontSize: 16,
              color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: sansproRegular.copyWith(
              fontSize: 13,
              color: WireframeColor.textgray,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.appcolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Enter Classroom",
                style: sansproBold.copyWith(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}