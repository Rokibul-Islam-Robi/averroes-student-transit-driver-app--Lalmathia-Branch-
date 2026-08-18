import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';
import 'live_now_card.dart';

class LiveClassPage extends StatefulWidget {
  const LiveClassPage({super.key});

  @override
  State<LiveClassPage> createState() => _LiveClassPageState();
}

class _LiveClassPageState extends State<LiveClassPage> {
  final themedata = Get.put(WireframeThemecontroler());
  bool _showHistory = false;

  final List<Map<String, String>> _liveClassHistory = const [
    {
      "subject": "Higher Mathematics - Chapter 3",
      "teacher": "Mr. Rafiqul Islam",
      "date": "04 Aug 2026",
      "time": "10:00 AM - 11:00 AM",
      "status": "Completed"
    },
    {
      "subject": "Physics - Chapter 3",
      "teacher": "Mr. Tanvir Rahman",
      "date": "03 Aug 2026",
      "time": "11:30 AM - 12:30 PM",
      "status": "Completed"
    },
    {
      "subject": "Chemistry - Chapter 2",
      "teacher": "Dr. Ahsan Habib",
      "date": "02 Aug 2026",
      "time": "09:00 AM - 10:00 AM",
      "status": "Completed"
    },
    {
      "subject": "English Grammar - Unit 5",
      "teacher": "Ms. Nazia Hasan",
      "date": "01 Aug 2026",
      "time": "12:00 PM - 01:00 PM",
      "status": "Completed"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Live Now'.tr,
      ),
      body: PageBackground(
        category: PageCategory.liveClass,
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
                      // Active Live Class Card
                      LiveNowCard(width: width, height: height),

                      SizedBox(height: height / 30),

                      // Section Header & View History Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Live Classes".tr,
                            style: sansproBold.copyWith(
                              fontSize: 18,
                              color: themedata.isdark
                                  ? WireframeColor.white
                                  : WireframeColor.black,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _showHistory = !_showHistory;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _showHistory ? Icons.visibility_off : Icons.history_rounded,
                                  size: 18,
                                  color: WireframeColor.appcolor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _showHistory ? 'Hide History'.tr : 'View History'.tr,
                                  style: sansproSemibold.copyWith(
                                    fontSize: 13,
                                    color: WireframeColor.appcolor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height / 50),

                      if (_showHistory) ...[
                        Text(
                          "Live Class History (Completed)".tr,
                          style: sansproBold.copyWith(
                            fontSize: 15,
                            color: WireframeColor.appcolor,
                          ),
                        ),
                        SizedBox(height: height / 60),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _liveClassHistory.length,
                          itemBuilder: (context, index) {
                            final item = _liveClassHistory[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(width / 26),
                              decoration: BoxDecoration(
                                color: themedata.isdark ? WireframeColor.lightblack : const Color(0xffF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: WireframeColor.bggray.withAlpha(100)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                                  ),
                                  SizedBox(width: width / 30),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['subject'] ?? '',
                                          style: sansproBold.copyWith(
                                            fontSize: 15,
                                            color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${item['teacher']} • ${item['date']}",
                                          style: sansproRegular.copyWith(
                                            fontSize: 12,
                                            color: WireframeColor.textgray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Completed",
                                      style: sansproSemibold.copyWith(
                                        fontSize: 11,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        Text(
                          "Upcoming Classes".tr,
                          style: sansproBold.copyWith(
                            fontSize: 16,
                            color: themedata.isdark
                                ? WireframeColor.white
                                : WireframeColor.black,
                          ),
                        ),
                        SizedBox(height: height / 50),
                        _buildUpcomingClassItem(
                          subject: "Mathematics",
                          teacher: "Mr. Rahman",
                          time: "11:30 AM - 12:15 PM",
                          status: "Scheduled",
                          height: height,
                          width: width,
                        ),
                        SizedBox(height: height / 60),
                        _buildUpcomingClassItem(
                          subject: "Physics",
                          teacher: "Dr. Karim",
                          time: "01:00 PM - 01:45 PM",
                          status: "Scheduled",
                          height: height,
                          width: width,
                        ),
                      ],
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

  Widget _buildUpcomingClassItem({
    required String subject,
    required String teacher,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WireframeColor.appcolor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.videocam_outlined, color: WireframeColor.appcolor),
          ),
          SizedBox(width: width / 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: sansproBold.copyWith(
                    fontSize: 16,
                    color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$teacher • $time",
                  style: sansproRegular.copyWith(
                    fontSize: 13,
                    color: WireframeColor.textgray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: sansproSemibold.copyWith(
                fontSize: 11,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}