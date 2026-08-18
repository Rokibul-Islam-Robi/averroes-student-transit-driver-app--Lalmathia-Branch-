import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'page_hero_header.dart';
import 'live_now_card.dart';

class TodayLiveClassesPage extends StatefulWidget {
  const TodayLiveClassesPage({Key? key}) : super(key: key);

  @override
  State<TodayLiveClassesPage> createState() => _TodayLiveClassesPageState();
}

class _TodayLiveClassesPageState extends State<TodayLiveClassesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> scheduledClasses = const [
    {
      "subject": "Mathematics",
      "topic": "Algebra & Equation Solving",
      "teacher": "Mr. Rafiqul Islam",
      "time": "11:48 AM - 12:48 PM",
      "room": "Room-102",
      "status": "Scheduled",
    },
    {
      "subject": "Chemistry",
      "topic": "Chemical Bonding",
      "teacher": "Dr. Ahsan Habib",
      "time": "02:00 PM - 03:00 PM",
      "room": "Lab-2",
      "status": "Scheduled",
    },
    {
      "subject": "Bangla 1st Paper",
      "topic": "Poetry Analysis",
      "teacher": "Mrs. Sharmin Sultana",
      "time": "04:15 PM - 05:15 PM",
      "room": "Room-204",
      "status": "Scheduled",
    },
  ];

  final List<Map<String, String>> myLiveClasses = const [
    {
      "subject": "Physics - Chapter 4",
      "topic": "Thermodynamics & Motion",
      "teacher": "Mr. Tanvir Rahman",
      "time": "10:30 AM - 11:30 AM",
      "status": "Live Now",
    },
    {
      "subject": "Mathematics - Chapter 3",
      "topic": "Quadratic Equations",
      "teacher": "Mr. Rafiqul Islam",
      "time": "11:48 AM - 12:48 PM",
      "status": "Upcoming Today",
    },
    {
      "subject": "English Grammar",
      "topic": "Voice & Narration",
      "teacher": "Ms. Nazia Hasan",
      "time": "03:30 PM - 04:30 PM",
      "status": "Upcoming Today",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          PageHeroHeader(
            theme: PageHeroTheme.homework,
            title: 'Today Live Classes',
            subtitle: 'আজকের সব Live Class-এর তালিকা',
            onBack: () => Navigator.pop(context),
          ),
          Container(
            color: WireframeColor.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: WireframeColor.appcolor,
              labelColor: WireframeColor.appcolor,
              unselectedLabelColor: WireframeColor.textgray,
              labelStyle: sansproBold.copyWith(fontSize: 14),
              unselectedLabelStyle: sansproRegular.copyWith(fontSize: 14),
              tabs: const [
                Tab(
                  icon: Icon(Icons.calendar_today_rounded, size: 18),
                  text: "Schedule Classes",
                ),
                Tab(
                  icon: Icon(Icons.video_camera_front_rounded, size: 18),
                  text: "My Live Classes",
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Schedule Classes
                _buildScheduledClassesList(),

                // Tab 2: My Live Classes
                _buildMyLiveClassesList(width: width, height: height),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledClassesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scheduledClasses.length,
      itemBuilder: (context, index) {
        final item = scheduledClasses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: WireframeColor.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WireframeColor.bggray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: WireframeColor.appcolor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['subject'] ?? '',
                      style: sansproBold.copyWith(color: WireframeColor.appcolor, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['status'] ?? '',
                      style: sansproBold.copyWith(color: Colors.orange, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['topic'] ?? '',
                style: sansproBold.copyWith(fontSize: 15, color: WireframeColor.black),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 16, color: WireframeColor.textgray),
                  const SizedBox(width: 4),
                  Text(
                    'Instructor: ${item['teacher']}',
                    style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                  ),
                ],
              ),
              const Divider(height: 20, color: WireframeColor.bggray),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: WireframeColor.textgray),
                      const SizedBox(width: 4),
                      Text(
                        item['time'] ?? '',
                        style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 14, color: WireframeColor.textgray),
                      const SizedBox(width: 4),
                      Text(
                        item['room'] ?? '',
                        style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyLiveClassesList({required double width, required double height}) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your assigned live classes for today are listed below. Click "Join Now" for ongoing sessions.',
                  style: sansproRegular.copyWith(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Embedded Live Now Card
        LiveNowCard(width: width, height: height),

        const SizedBox(height: 16),
        Text(
          'Upcoming Live Classes Today',
          style: sansproBold.copyWith(fontSize: 15, color: WireframeColor.black),
        ),
        const SizedBox(height: 10),

        ...myLiveClasses.skip(1).map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WireframeColor.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WireframeColor.bggray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['subject'] ?? '',
                      style: sansproBold.copyWith(fontSize: 15, color: WireframeColor.black),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: WireframeColor.appcolor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['status'] ?? '',
                        style: sansproBold.copyWith(color: WireframeColor.appcolor, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['topic'] ?? '',
                  style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: WireframeColor.textgray),
                        const SizedBox(width: 4),
                        Text(
                          item['teacher'] ?? '',
                          style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: WireframeColor.textgray),
                        const SizedBox(width: 4),
                        Text(
                          item['time'] ?? '',
                          style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}