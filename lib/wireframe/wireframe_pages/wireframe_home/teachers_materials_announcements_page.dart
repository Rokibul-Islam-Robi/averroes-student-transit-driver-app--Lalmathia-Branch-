import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// TEACHERS MATERIALS → ANNOUNCEMENTS — important notices from teachers
// ════════════════════════════════════════════════════════════════════════════
//
// static placeholder ডেটা — পরে API যুক্ত হলে `_buildAnnouncements()` এর
// জায়গায় controller থেকে আসা লিস্ট বসিয়ে দিলেই চলবে, UI অপরিবর্তিত থাকবে।
// ════════════════════════════════════════════════════════════════════════════

class TeacherAnnouncement {
  final String title;
  final String message;
  final String teacherName;
  final String className;
  final String sectionName;
  final DateTime postedOn;
  final bool important;

  const TeacherAnnouncement({
    required this.title,
    required this.message,
    required this.teacherName,
    required this.className,
    required this.sectionName,
    required this.postedOn,
    this.important = false,
  });
}

List<TeacherAnnouncement> _buildAnnouncements() {
  final now = DateTime.now();
  DateTime d(int daysAgo) => now.subtract(Duration(days: daysAgo));

  return [
    TeacherAnnouncement(
      title: "Unit Test Postponed",
      message:
      "Friday's Mathematics Unit Test has been rescheduled to next Monday. The syllabus remains unchanged — please prepare accordingly.",
      teacherName: "Mr. Rakibul Islam",
      className: "Class 4",
      sectionName: "Morning",
      postedOn: d(0),
      important: true,
    ),
    TeacherAnnouncement(
      title: "Homework Submission Reminder",
      message: "The deadline to submit English Grammar Worksheet 5 is tomorrow. If you haven't submitted yet, please do so soon.",
      teacherName: "Ms. Farzana Akter",
      className: "Class 4",
      sectionName: "Morning",
      postedOn: d(1),
    ),
    TeacherAnnouncement(
      title: "Science Fair Registration Open",
      message: "Registration for this year's Science Fair is now open. Interested students should contact their class teacher.",
      teacherName: "Mr. Shahriar Kabir",
      className: "Class 4",
      sectionName: "Day",
      postedOn: d(2),
    ),
    TeacherAnnouncement(
      title: "Extra Class on Saturday",
      message: "An extra class for Biology Chapter 7 will be held this Saturday at 9:00 AM.",
      teacherName: "Ms. Sultana Rajia",
      className: "Class 5",
      sectionName: "Morning",
      postedOn: d(3),
      important: true,
    ),
  ];
}

class TeachersMaterialsAnnouncementsPage extends StatelessWidget {
  const TeachersMaterialsAnnouncementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final announcements = _buildAnnouncements()
      ..sort((a, b) => b.postedOn.compareTo(a.postedOn));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(title: 'Announcements'),
      body: PageBackground(
        category: PageCategory.teachersMaterials,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "Important notices and announcements shared by your teachers.",
                style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.white.withAlpha(230)),
              ),
            ),
            SizedBox(height: height / 46),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: WireframeColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: announcements.isEmpty
                    ? Center(
                  child: Text(
                    "No announcements yet.".tr,
                    style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                  ),
                )
                    : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 40),
                  itemCount: announcements.length,
                  separatorBuilder: (_, __) => SizedBox(height: height / 60),
                  itemBuilder: (context, index) =>
                      _AnnouncementCard(item: announcements[index], width: width, height: height),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatefulWidget {
  final TeacherAnnouncement item;
  final double width;
  final double height;
  const _AnnouncementCard({required this.item, required this.width, required this.height});

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final width = widget.width;
    final height = widget.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 60),
      decoration: BoxDecoration(
        color: WireframeColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.important ? const Color(0xffFCD34D) : WireframeColor.bggray,
        ),
        boxShadow: [
          BoxShadow(color: WireframeColor.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: sansproSemibold.copyWith(fontSize: 14.5, color: WireframeColor.black),
                ),
              ),
              if (item.important)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Important".tr,
                    style: sansproSemibold.copyWith(fontSize: 10, color: const Color(0xffB45309)),
                  ),
                ),
            ],
          ),
          SizedBox(height: height / 220),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 12, color: WireframeColor.appgray),
              const SizedBox(width: 4),
              Text(
                item.teacherName,
                style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.appgray),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: WireframeColor.lightgray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${item.className} \u00b7 ${item.sectionName}",
                  style: sansproRegular.copyWith(fontSize: 10, color: WireframeColor.textgray),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM, h:mm a').format(item.postedOn),
                style: sansproRegular.copyWith(fontSize: 10, color: WireframeColor.textgray),
              ),
            ],
          ),
          SizedBox(height: height / 160),
          Text(
            item.message,
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: sansproRegular.copyWith(fontSize: 12.5, color: WireframeColor.lightblack, height: 1.4),
          ),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.only(top: height / 250),
              child: Text(
                _expanded ? "See less".tr : "See more".tr,
                style: sansproSemibold.copyWith(fontSize: 11.5, color: WireframeColor.appcolor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
