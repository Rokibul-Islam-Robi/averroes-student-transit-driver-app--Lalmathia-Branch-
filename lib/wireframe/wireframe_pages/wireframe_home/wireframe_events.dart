import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// 2nd code er central package name call kora hoyeche
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_eventdetails.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import '../../wireframe_gloabelclass/wireframe_color.dart';

// 1st code er unique backgrounds logic rakha holo
import 'page_background.dart';

class WireframeEvents extends StatefulWidget {
  const WireframeEvents({super.key});

  @override
  State<WireframeEvents> createState() => _WireframeEventsState();
}

class _WireframeEventsState extends State<WireframeEvents> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());

  // client-er deya event image o info diye update kora holo (age generic
  // sample event chilo, ekhon actual "Upcoming Events" dashboard-er sathe
  // consistent titles + real cover image use kora hocche).
  List title = ["Victory Day Activities", "STEM Week 2026", "Annual Field Trip"];
  List time = [" 16 Dec 26, 09:00 AM", " 12 Jan 27, 09:00 AM", " 02 Feb 27, 09:00 AM"];
  List subtitle = [
    "Join the school-wide Victory Day celebration with patriotic activities, flag hoisting and cultural programs for every class.",
    "A full week of hands-on Science, Technology, Engineering and Maths activities, experiments and project showcases.",
    "An exciting day out for students with guided exploration, group activities and fun learning outside the classroom.",
  ];
  List<String> eventImage = [
    WireframePngimage.eventVictoryDay,
    WireframePngimage.eventStemWeek,
    WireframePngimage.eventFieldTrip,
  ];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      // 1st code er custom PageAppBar rakha hoyeche kintu title a 2nd code er dynamic translation (Localization) string ti bano hoyeche
      appBar: PageAppBar(
        title: "Events_Programs".tr,
      ),
      // 1st code er sundor UI structure (PageBackground) ti perfectly maintain kora holo
      body: PageBackground(
        category: PageCategory.holiday,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: height / 36),
                child: Container(
                  decoration: BoxDecoration(
                      color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 26, vertical: height / 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: title.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: height / 56),
                              child: InkWell(
                                highlightColor: WireframeColor.transparent,
                                splashColor: WireframeColor.transparent,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return const WireframeEventDetails();
                                  },));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: WireframeColor.bggray),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width / 36, vertical: height / 96),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title[index],
                                          style: sansproSemibold.copyWith(fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: height / 96,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              height: height / 10,
                                              width: height / 10,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                  color: WireframeColor.textgray,
                                                  borderRadius: BorderRadius.circular(20)),
                                              child: Image.asset(
                                                eventImage[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width / 46,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      WireframePngimage.ictime,
                                                      height: height / 46,
                                                    ),
                                                    Text(
                                                      time[index],
                                                      style: sansproSemibold.copyWith(
                                                          fontSize: 13,
                                                          color: WireframeColor.appcolor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height / 200,
                                                ),
                                                SizedBox(
                                                  width: width / 1.6,
                                                  child: Text(
                                                    subtitle[index],
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: sansproRegular.copyWith(
                                                        fontSize: 13,
                                                        color: WireframeColor.textgray),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
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
}