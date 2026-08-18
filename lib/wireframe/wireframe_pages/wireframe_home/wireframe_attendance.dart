import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
// আপনার প্রজেক্টের সঠিক পাথ অনুযায়ী থিম কন্ট্রোলার ইম্পোর্ট রাখা হলো
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart'; // কাস্টম ব্যাকগ্রাউন্ড ইম্পোর্ট ঠিক রাখা হলো

class WireframeAttendance extends StatefulWidget {
  const WireframeAttendance({Key? key}) : super(key: key);

  @override
  State<WireframeAttendance> createState() => _WireframeAttendanceState();
}

class _WireframeAttendanceState extends State<WireframeAttendance> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());

  DateTime? _selectedDay;
  String? selectdate;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      // কাস্টম PageAppBar ঠিক রাখা হলো এবং টাইটেলে ২য় কোডের মতো ট্রান্সলেশন (.tr) যোগ করা হলো
      appBar: PageAppBar(
        title: 'Attendance'.tr,
      ),
      body: PageBackground(
        category: PageCategory.attendance,
        child: Column(
          children: [
            // অ্যাপবারের নিচে স্পেসিং ঠিক রাখা হলো যেন কন্টেন্ট কেটে না যায়
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: height / 36),
                child: Container(
                  decoration: BoxDecoration(
                    color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width / 26,
                      vertical: height / 36,
                    ),
                    child: Column(
                      children: [
                        // ক্যালেন্ডার উইজেট
                        TableCalendar(
                          firstDay: DateTime.now(),
                          focusedDay: DateTime.now(),
                          lastDay: DateTime.utc(2050, 3, 14),
                          headerVisible: true,
                          daysOfWeekVisible: true,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                                color: WireframeColor.red,
                                borderRadius: BorderRadius.circular(10)),
                            todayTextStyle: const TextStyle(
                              color: WireframeColor.white,
                            ),
                            selectedDecoration: BoxDecoration(
                                color: WireframeColor.red,
                                borderRadius: BorderRadius.circular(10)),
                            selectedTextStyle: const TextStyle(
                              color: WireframeColor.white,
                            ),
                          ),
                          shouldFillViewport: false,
                          currentDay: _selectedDay,
                          calendarFormat: CalendarFormat.month,
                          pageAnimationEnabled: false,
                          headerStyle: HeaderStyle(
                            leftChevronIcon: SizedBox(
                              height: height / 26,
                              width: height / 26,
                              child: Icon(
                                Icons.chevron_left,
                                color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                              ),
                            ),
                            rightChevronIcon: SizedBox(
                              height: height / 26,
                              width: height / 26,
                              child: Icon(
                                Icons.chevron_right,
                                color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                              ),
                            ),
                            formatButtonVisible: false,
                            decoration: const BoxDecoration(
                              color: WireframeColor.transparent,
                            ),
                            titleCentered: true,
                            titleTextStyle: sansproRegular.copyWith(
                              fontSize: 15,
                              color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                            ),
                          ),
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              String convertdate = (_selectedDay.toString());
                              selectdate = convertdate;
                            });
                          },
                        ),

                        SizedBox(height: height / 26),

                        // Absent Container
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: WireframeColor.red),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 26,
                              vertical: height / 70,
                            ),
                            child: Row(
                              children: [
                                Text("Absent".tr, style: sansproRegular.copyWith(fontSize: 14)),
                                const Spacer(),
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: const Color(0xffFFB1B1),
                                  child: Text(
                                    "02".tr,
                                    style: sansproBold.copyWith(fontSize: 13, color: WireframeColor.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: height / 36),

                        // Festival & Holidays Container
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: WireframeColor.green),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 26,
                              vertical: height / 70,
                            ),
                            child: Row(
                              children: [
                                Text("Festival & Holidays".tr, style: sansproRegular.copyWith(fontSize: 14)),
                                const Spacer(),
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: const Color(0xffA9F2A4),
                                  child: Text(
                                    "01".tr,
                                    style: sansproBold.copyWith(fontSize: 13, color: WireframeColor.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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