import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// 2nd code theke correct app package import kora hoyeche
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import '../../wireframe_gloabelclass/wireframe_color.dart';

import 'page_background.dart'; // 1st code er custom background import thik rakha hoyeche
import 'student_controller.dart'; // logged-in student er className/section ana hoy ekhan theke
import 'class_routine_data.dart'; // class+section wise routine data source

// ════════════════════════════════════════════════════════════════════════════
// CLASS ROUTINE PAGE
//
// Student tar own credential diye login korar por, tar profile (StudentController)
// theke className + section niye shudhu tar nijer class-section er routine
// dekhano hoy — RoutineRepository.forClassSection() diye day-wise data ana hoy.
// ════════════════════════════════════════════════════════════════════════════
class WireframeTimetable extends StatefulWidget {
  const WireframeTimetable({Key? key}) : super(key: key);

  @override
  State<WireframeTimetable> createState() => _WireframeTimetableState();
}

class _WireframeTimetableState extends State<WireframeTimetable> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  int isselected1 = 0;
  final themedata = Get.put(WireframeThemecontroler());

  // logged-in student er profile (className/section) — home/profile page-er
  // moto same pattern e Get.put kora hoyeche jate singleton controller share hoy
  final studentCtrl = Get.put(StudentController());

  final List<String> day = RoutineRepository.days;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      // 1st code er Custom PageAppBar e 2nd code er .tr translation merge kora hoyeche
      appBar: PageAppBar(
        title: "Class_Routine".tr,
      ),
      // 1st code er custom background layout intact rakha hoyeche
      body: PageBackground(
        category: PageCategory.syllabus,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AppBar er niche proper spacing thik rakha hoyeche
              SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

              Padding(
                padding: EdgeInsets.only(top: height / 36),
                child: Container(
                  decoration: BoxDecoration(
                    color: themedata.isdark
                        ? WireframeColor.black
                        : WireframeColor.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width / 26,
                      vertical: height / 56,
                    ),
                    child: Obx(() {
                      final profile = studentCtrl.profile.value;

                      // ── Profile load hocche — chhoto loading indicator ──
                      if (studentCtrl.isLoading.value && profile == null) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: height / 12),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      final className = profile?.className ?? '';
                      final section = profile?.section ?? '';
                      final routine = RoutineRepository.forClassSection(className, section);
                      final selectedDayKey = day[isselected1];
                      final periods = routine[selectedDayKey] ?? const [];

                      return Column(
                        children: [
                          // ── Class + Section header chip — student clearly
                          // dekhte pay se konta routine dekhche ──
                          if (className.isNotEmpty || section.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: height / 56),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / 26, vertical: height / 130),
                                  decoration: BoxDecoration(
                                    color: WireframeColor.lightappcolor.withAlpha(28),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    section.isNotEmpty
                                        ? 'Class $className - $section'
                                        : 'Class $className',
                                    style: sansproSemibold.copyWith(
                                      fontSize: 13,
                                      color: WireframeColor.appcolor,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Day Selection Horizontal List
                          Container(
                            height: height / 22,
                            decoration: BoxDecoration(
                              border: Border.all(color: WireframeColor.textgray),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ListView.builder(
                              itemCount: day.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  splashColor: WireframeColor.transparent,
                                  highlightColor: WireframeColor.transparent,
                                  onTap: () {
                                    setState(() {
                                      isselected1 = index;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: width / 56),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isselected1 == index
                                            ? WireframeColor.lightappcolor
                                            : WireframeColor.transparent,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: isselected1 == index
                                              ? EdgeInsets.symmetric(horizontal: width / 16)
                                              : EdgeInsets.symmetric(horizontal: width / 36),
                                          child: Text(
                                            day[index],
                                            style: sansproSemibold.copyWith(
                                              fontSize: 13,
                                              color: isselected1 == index
                                                  ? WireframeColor.white
                                                  : themedata.isdark
                                                  ? WireframeColor.white
                                                  : WireframeColor.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: height / 36),

                          // ── Selected day er class routine list ──
                          if (periods.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: height / 20),
                              child: Text(
                                'No_Class_Scheduled_Today'.tr,
                                style: sansproRegular.copyWith(
                                  fontSize: 14,
                                  color: WireframeColor.appgray,
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              itemCount: periods.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final period = periods[index];
                                if (period.isBreak) {
                                  // Lunch Break Card
                                  return Container(
                                    margin: EdgeInsets.only(bottom: height / 36),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: WireframeColor.bggray),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / 36,
                                        vertical: height / 56,
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                period.subject,
                                                style: sansproSemibold.copyWith(fontSize: 14),
                                              ),
                                              SizedBox(height: height / 70),
                                              Text(
                                                period.time,
                                                style: sansproRegular.copyWith(
                                                  fontSize: 14,
                                                  color: WireframeColor.appgray,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Image.asset(
                                            WireframePngimage.lunchbreak,
                                            height: height / 20,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  // Regular Class Card
                                  return Container(
                                    margin: EdgeInsets.only(bottom: height / 36),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: WireframeColor.bggray),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / 36,
                                        vertical: height / 56,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            period.subject,
                                            style: sansproSemibold.copyWith(fontSize: 14),
                                          ),
                                          SizedBox(height: height / 70),
                                          Text(
                                            period.time,
                                            style: sansproRegular.copyWith(
                                              fontSize: 14,
                                              color: WireframeColor.appgray,
                                            ),
                                          ),
                                          SizedBox(height: height / 96),
                                          const Divider(color: WireframeColor.textgray),
                                          Row(
                                            children: [
                                              Text(
                                                period.teacher,
                                                style: sansproRegular.copyWith(
                                                  fontSize: 14,
                                                  color: WireframeColor.appgray,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                period.periodLabel,
                                                style: sansproSemibold.copyWith(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
