import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'bus_controller.dart';
import 'bus_live_tracking_page.dart';
import 'page_background.dart';

class WireframeBus extends StatefulWidget {
  const WireframeBus({Key? key}) : super(key: key);

  @override
  State<WireframeBus> createState() => _WireframeBusState();
}

class _WireframeBusState extends State<WireframeBus>
    with SingleTickerProviderStateMixin {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  final busCtrl = Get.put(BusController());

  late TabController _tabController;

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
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Bus_Service'.tr,
        actions: [
          InkWell(
            highlightColor: WireframeColor.transparent,
            splashColor: WireframeColor.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusLiveTrackingPage()),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: width / 26),
              child: Icon(
                Icons.location_on,
                size: height / 36,
                color: WireframeColor.white,
              ),
            ),
          ),
        ],
      ),
      body: PageBackground(
        category: PageCategory.bus,
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight +
                    MediaQuery.of(context).padding.top +
                    10),

            TabBar(
              controller: _tabController,
              indicatorColor: WireframeColor.white,
              labelColor: WireframeColor.white,
              unselectedLabelColor: WireframeColor.lightwhite,
              labelStyle: sansproSemibold.copyWith(fontSize: 14),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: "Schedule".tr),
                Tab(text: "Entry_Out_Log".tr),
              ],
            ),
            SizedBox(height: height / 56),

            Expanded(
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
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ScheduleTab(
                        busCtrl: busCtrl,
                        height: height,
                        width: width,
                        isDark: themedata.isdark),
                    _EntryOutLogTab(
                        busCtrl: busCtrl,
                        height: height,
                        width: width,
                        isDark: themedata.isdark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final BusController busCtrl;
  final double height;
  final double width;
  final bool isDark;

  const _ScheduleTab({
    required this.busCtrl,
    required this.height,
    required this.width,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (busCtrl.scheduleLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (busCtrl.scheduleHasError.value) {
        return _ErrorState(
          message: busCtrl.scheduleErrorMessage.value,
          onRetry: busCtrl.refreshSchedule,
          height: height,
        );
      }

      final schedule = busCtrl.schedule.value;
      if (schedule == null) {
        return Center(child: Text("No schedule found".tr));
      }

      return RefreshIndicator(
        onRefresh: busCtrl.refreshSchedule,
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: width / 26, vertical: height / 36),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(width / 26),
              decoration: BoxDecoration(
                color: WireframeColor.appcolor.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WireframeColor.appcolor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_bus_filled,
                          color: WireframeColor.appcolor, size: height / 28),
                      SizedBox(width: width / 36),
                      Expanded(
                        child: Text(
                          schedule.routeName,
                          style: sansproSemibold.copyWith(
                              fontSize: 17,
                              color: isDark
                                  ? WireframeColor.white
                                  : WireframeColor.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height / 70),
                  Text("${'Bus_No'.tr}: ${schedule.busNumber}",
                      style: sansproRegular.copyWith(
                          fontSize: 13, color: WireframeColor.textgray)),
                  SizedBox(height: height / 120),
                  Text("${'Driver'.tr}: ${schedule.driverName}  (${schedule.driverPhone})",
                      style: sansproRegular.copyWith(
                          fontSize: 13, color: WireframeColor.textgray)),
                  if (schedule.helperPhone.isNotEmpty) ...[
                    SizedBox(height: height / 120),
                    Text("${'Helper'.tr}: ${schedule.helperPhone}",
                        style: sansproRegular.copyWith(
                            fontSize: 13, color: WireframeColor.textgray)),
                  ],
                ],
              ),
            ),
            SizedBox(height: height / 36),
            Text(
              "Stops".tr,
              style: sansproSemibold.copyWith(
                  fontSize: 16,
                  color: isDark ? WireframeColor.white : WireframeColor.black),
            ),
            SizedBox(height: height / 56),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedule.stops.length,
              separatorBuilder: (_, __) => SizedBox(height: height / 70),
              itemBuilder: (context, index) {
                final stop = schedule.stops[index];
                final isLast = index == schedule.stops.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: WireframeColor.appcolor,
                          child: Text(
                            "${stop.stopOrder}",
                            style: sansproBold.copyWith(
                                fontSize: 10, color: WireframeColor.white),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: height / 36,
                            color: WireframeColor.bggray,
                          ),
                      ],
                    ),
                    SizedBox(width: width / 36),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: height / 56),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.stopName,
                              style: sansproSemibold.copyWith(
                                  fontSize: 14,
                                  color: isDark
                                      ? WireframeColor.white
                                      : WireframeColor.black),
                            ),
                            SizedBox(height: height / 200),
                            Text(
                              "${'Pickup'.tr}: ${stop.pickupTime}   •   ${'Drop'.tr}: ${stop.dropTime}",
                              style: sansproRegular.copyWith(
                                  fontSize: 12,
                                  color: WireframeColor.textgray),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _EntryOutLogTab extends StatelessWidget {
  final BusController busCtrl;
  final double height;
  final double width;
  final bool isDark;

  const _EntryOutLogTab({
    required this.busCtrl,
    required this.height,
    required this.width,
    required this.isDark,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return WireframeColor.green;
      case 'late':
        return const Color(0xffE8A400);
      case 'missed':
        return WireframeColor.red;
      default:
        return WireframeColor.textgray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (busCtrl.logLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (busCtrl.logHasError.value) {
        return _ErrorState(
          message: busCtrl.logErrorMessage.value,
          onRetry: busCtrl.refreshBusLog,
          height: height,
        );
      }
      if (busCtrl.busLogs.isEmpty) {
        return Center(child: Text("No bus log entries found".tr));
      }

      return RefreshIndicator(
        onRefresh: busCtrl.refreshBusLog,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: width / 26, vertical: height / 36),
          itemCount: busCtrl.busLogs.length,
          separatorBuilder: (_, __) => SizedBox(height: height / 56),
          itemBuilder: (context, index) {
            final log = busCtrl.busLogs[index];
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: width / 26, vertical: height / 56),
              decoration: BoxDecoration(
                color: isDark ? WireframeColor.lightblack : WireframeColor.lightgray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: WireframeColor.appcolor.withAlpha(30),
                    child: Icon(Icons.directions_bus,
                        color: WireframeColor.appcolor, size: 20),
                  ),
                  SizedBox(width: width / 36),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.date,
                          style: sansproSemibold.copyWith(
                              fontSize: 14,
                              color: isDark
                                  ? WireframeColor.white
                                  : WireframeColor.black),
                        ),
                        SizedBox(height: height / 200),
                        Text(
                          "${'Entry'.tr}: ${log.entryTime}   •   ${'Exit'.tr}: ${log.exitTime}",
                          style: sansproRegular.copyWith(
                              fontSize: 12, color: WireframeColor.textgray),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 56, vertical: height / 200),
                    decoration: BoxDecoration(
                      color: _statusColor(log.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      log.status,
                      style: sansproSemibold.copyWith(
                          fontSize: 11, color: _statusColor(log.status)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final double height;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: height / 16, color: WireframeColor.textgray),
            SizedBox(height: height / 56),
            Text(
              message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(
                  fontSize: 14, color: WireframeColor.textgray),
            ),
            SizedBox(height: height / 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.appcolor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => onRetry(),
              child: Text("Retry".tr,
                  style: sansproSemibold.copyWith(color: WireframeColor.white)),
            ),
          ],
        ),
      ),
    );
  }
}