import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'driver_controller.dart';
import 'driver_qr_scan_page.dart';
import 'driver_trip_history_page.dart';
import 'driver_live_bus_map_page.dart';

// ════════════════════════════════════════════════════════════════════════════
// Driver Dashboard — redesigned corporate/modern, closely following the
// "Driver Bus Portal" admin web page screenshot the user shared:
//   • Top stat row: Trip Status / Bus / Students Currently on Bus / Started At
//   • Bus select + Trip Type select + Start Trip (only these — driver can't
//     add anything else himself)
//   • Trip History button → dedicated Transport Trip History page
//   • Live Bus Map option → Google Maps live location page
//   • Onboarded Students section with Time / Student ID / Name / Class /
//     Boarding Location, matching the "Selected Trip Details" table style
//
// All data is real — no demo/mock values anywhere. Driver only has the
// actions the API supports: select bus, select trip type, start trip,
// end trip, scan QR to onboard a real student.
// ════════════════════════════════════════════════════════════════════════════
class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({Key? key}) : super(key: key);

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  final themedata = Get.put(WireframeThemecontroler());
  late final DriverController driverCtrl;

  DriverBus? _selectedBus;
  String _selectedTripType = 'morning'; // morning | afternoon | other

  @override
  void initState() {
    super.initState();
    driverCtrl = Get.isRegistered<DriverController>()
        ? Get.find<DriverController>()
        : Get.put(DriverController());
    driverCtrl.fetchDashboard();
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'.tr),
        content: Text('Are you sure you want to logout from the Driver account?'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Logout'.tr)),
        ],
      ),
    );
    if (confirm == true) {
      await driverCtrl.logout();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _startTrip() async {
    if (_selectedBus == null) {
      Get.snackbar('Error', 'Please select a bus first.'.tr);
      return;
    }
    await driverCtrl.startTrip(busId: _selectedBus!.id, tripType: _selectedTripType);
  }

  Future<void> _endTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('End Trip'.tr),
        content: Text('Are you sure you want to end this trip?'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('End Trip'.tr)),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await driverCtrl.endTrip();
    if (!mounted) return;
    if (result['success'] == true) {
      final Duration? duration = result['duration'];
      final durationText = duration != null ? _formatDuration(duration) : null;
      Get.snackbar(
        'Trip Ended'.tr,
        durationText != null
            ? '${'Trip duration'.tr}: $durationText'
            : 'Trip ended successfully.'.tr,
      );
    } else {
      Get.snackbar('Error', result['message']?.toString() ?? 'Failed to end trip.'.tr);
    }
  }

  Future<void> _openQrScan() async {
    final trip = driverCtrl.activeTrip.value;
    if (trip == null || trip.status != 'running') {
      Get.snackbar('No Active Trip', 'Please start a trip before scanning QR code.'.tr);
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverQrScanPage()),
    );
    driverCtrl.fetchDashboard();
  }

  void _openTripHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverTripHistoryPage()),
    );
  }

  void _openLiveMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverLiveBusMapPage()),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isDark = themedata.isdark;

    return Scaffold(
      backgroundColor: isDark ? WireframeColor.black : WireframeColor.lightgray,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0d2461), WireframeColor.appcolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: WireframeColor.white),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Image.asset(
                  'Assets/wireframe_assets/wireframe_pngimage/averroes_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: width / 40),
            Expanded(
              child: Obx(
                    () => Text(
                  driverCtrl.driverUser.value?.name.isNotEmpty == true
                      ? driverCtrl.driverUser.value!.name
                      : 'Driver Bus Portal'.tr,
                  overflow: TextOverflow.ellipsis,
                  style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Trip History'.tr,
            icon: const Icon(Icons.history, color: WireframeColor.white),
            onPressed: _openTripHistory,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: WireframeColor.white),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Obx(() {
        try {
          return _buildBody(context, height, width, isDark);
        } catch (e, st) {
          // ── Defensive fallback: যদি কোনো অপ্রত্যাশিত রানটাইম এরর হয়,
          // পুরো স্ক্রিন ফাঁকা না রেখে সরাসরি error টা on-screen দেখানো
          // হচ্ছে — যাতে debug করা সহজ হয় (blank screen guess করার
          // চেয়ে অনেক ভালো) ────────────────────────────────────────────
          debugPrint('DriverDashboardPage build error: $e\n$st');
          return _buildErrorFallback(height, width, isDark, e);
        }
      }),
    );
  }

  // ── Actual dashboard body — pulled out of the Obx closure above so it can
  // be wrapped in try/catch cleanly ──────────────────────────────────────
  Widget _buildBody(BuildContext context, double height, double width, bool isDark) {
    if (driverCtrl.dashboardLoading.value &&
        driverCtrl.buses.isEmpty &&
        !driverCtrl.dashboardHasError.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeTrip = driverCtrl.activeTrip.value;
    final isTripRunning = activeTrip != null && activeTrip.status == 'running';
    DriverBus? selectedBusForStats;
    if (isTripRunning && activeTrip != null) {
      final runningBusId = activeTrip.busId;
      selectedBusForStats = driverCtrl.buses.firstWhereOrNullSafe((b) => b.id == runningBusId);
    } else {
      selectedBusForStats = _selectedBus;
    }

    return RefreshIndicator(
      onRefresh: driverCtrl.fetchDashboard,
      child: ListView(
        padding: EdgeInsets.all(width / 24),
        children: [
          if (driverCtrl.dashboardHasError.value) ...[
            _dashboardErrorBanner(height, width, isDark),
            SizedBox(height: height / 40),
          ],

          // ── Top stat cards row (Trip Status / Bus / Students / Started At) ──
          _statCardsGrid(height, width, isDark, isTripRunning, activeTrip, selectedBusForStats),
          SizedBox(height: height / 40),

          // ── Bus + Trip Type + Start Trip  /  or Active Trip card ─────────
          if (activeTrip != null && activeTrip.status == 'running')
            _activeTripCard(height, width, isDark, activeTrip)
          else
            _startTripCard(height, width, isDark),
          SizedBox(height: height / 40),

          // ── Quick actions: Scan QR + Live Bus Map ─────────────────────────
          Row(
            children: [
              Expanded(
                child: _quickActionButton(
                  height, width,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan Student QR'.tr,
                  onTap: _openQrScan,
                ),
              ),
              SizedBox(width: width / 30),
              Expanded(
                child: _quickActionButton(
                  height, width,
                  icon: Icons.map_outlined,
                  label: 'Live Bus Map'.tr,
                  onTap: _openLiveMap,
                  filled: false,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: height / 40),

          // ── Trip History link row ─────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _openTripHistory,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 55),
              decoration: BoxDecoration(
                color: isDark ? WireframeColor.lightblack : WireframeColor.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: WireframeColor.appcolor, size: 20),
                  SizedBox(width: width / 40),
                  Expanded(
                    child: Text('Trip History'.tr,
                        style: sansproSemibold.copyWith(
                            fontSize: 14, color: isDark ? WireframeColor.white : WireframeColor.black)),
                  ),
                  const Icon(Icons.chevron_right, color: WireframeColor.textgray),
                ],
              ),
            ),
          ),
          SizedBox(height: height / 40),

          if (isTripRunning) ...[
            // ── Live location status ──────────────────────────────────────
            Obx(
                  () => Row(
                children: [
                  Icon(
                    driverCtrl.isSendingLocation.value ? Icons.gps_fixed : Icons.gps_off,
                    size: 16,
                    color: driverCtrl.isSendingLocation.value ? WireframeColor.green : WireframeColor.textgray,
                  ),
                  SizedBox(width: width / 80),
                  Expanded(
                    child: Text(
                      driverCtrl.isSendingLocation.value
                          ? 'Sending live location (every 10 seconds)'.tr
                          : 'Live location sending is off'.tr,
                      style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 36),

            // ── Onboarded Students table ────────────────────────────────────
            Text(
              'Onboarded Students'.tr,
              style: sansproSemibold.copyWith(
                  fontSize: 15, color: isDark ? WireframeColor.white : WireframeColor.black),
            ),
            SizedBox(height: height / 70),
            if (driverCtrl.onboardedStudents.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: height / 40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? WireframeColor.lightblack : WireframeColor.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Start a trip to see onboarded students.'.tr,
                    style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: driverCtrl.onboardedStudents.length,
                separatorBuilder: (_, __) => SizedBox(height: height / 100),
                itemBuilder: (context, index) {
                  final s = driverCtrl.onboardedStudents[index];
                  return _onboardedStudentTile(height, width, isDark, s);
                },
              ),
          ],
        ],
      ),
    );
  }

  // ── Visible on-screen error fallback (instead of a silent blank page) ────
  Widget _buildErrorFallback(double height, double width, bool isDark, Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(width / 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: WireframeColor.red, size: 42),
            SizedBox(height: height / 60),
            Text('Something went wrong loading the dashboard.'.tr,
                textAlign: TextAlign.center,
                style: sansproSemibold.copyWith(
                    fontSize: 14, color: isDark ? WireframeColor.white : WireframeColor.black)),
            SizedBox(height: height / 100),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(width / 26),
              decoration: BoxDecoration(
                color: WireframeColor.red.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: WireframeColor.red.withAlpha(50)),
              ),
              child: Text(
                error.toString(),
                style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.red),
              ),
            ),
            SizedBox(height: height / 50),
            ElevatedButton(
              onPressed: driverCtrl.fetchDashboard,
              style: ElevatedButton.styleFrom(backgroundColor: WireframeColor.appcolor),
              child: Text('Retry'.tr, style: sansproSemibold.copyWith(color: WireframeColor.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  Widget _dashboardErrorBanner(double height, double width, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width / 26),
      decoration: BoxDecoration(
        color: WireframeColor.red.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WireframeColor.red.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: WireframeColor.red, size: 20),
          SizedBox(width: width / 40),
          Expanded(
            child: Text(
              driverCtrl.dashboardErrorMessage.value,
              style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.red),
            ),
          ),
          SizedBox(width: width / 60),
          TextButton(
            onPressed: driverCtrl.fetchDashboard,
            style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: width / 40)),
            child: Text('Retry'.tr,
                style: sansproSemibold.copyWith(color: WireframeColor.appcolor, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── Top 2x2 stat cards: Trip Status / Bus / Students Currently on Bus / Started At ──
  Widget _statCardsGrid(
      double height,
      double width,
      bool isDark,
      bool isTripRunning,
      DriverActiveTrip? activeTrip,
      DriverBus? busForStats,
      ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _statCard(
              height, width, isDark,
              label: 'Trip Status'.tr,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isTripRunning ? WireframeColor.green : WireframeColor.red).withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isTripRunning ? 'Running'.tr : 'No Running Trip'.tr,
                  style: sansproSemibold.copyWith(
                    fontSize: 11,
                    color: isTripRunning ? WireframeColor.green : WireframeColor.red,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: width / 40),
          Expanded(
            child: _statCard(
              height, width, isDark,
              label: 'Bus'.tr,
              child: Text(
                busForStats != null ? busForStats.vehicleNo : '-',
                style: sansproBold.copyWith(
                    fontSize: 15, color: isDark ? WireframeColor.white : WireframeColor.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    ).let((row) => Column(
      children: [
        row,
        SizedBox(height: height / 40),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _statCard(
                  height, width, isDark,
                  label: 'Students Currently on Bus'.tr,
                  child: Obx(
                        () => Text(
                      '${driverCtrl.onboardedCount.value}',
                      style: sansproBold.copyWith(
                          fontSize: 20, color: isDark ? WireframeColor.white : WireframeColor.black),
                    ),
                  ),
                ),
              ),
              SizedBox(width: width / 40),
              Expanded(
                child: _statCard(
                  height, width, isDark,
                  label: 'Started At'.tr,
                  child: Obx(() {
                    final start = driverCtrl.effectiveTripStartTime;
                    if (!isTripRunning || start == null) {
                      return Text('-',
                          style: sansproBold.copyWith(
                              fontSize: 15, color: isDark ? WireframeColor.white : WireframeColor.black));
                    }
                    // touch tripElapsedSeconds so this rebuilds every second
                    driverCtrl.tripElapsedSeconds.value;
                    return Text(
                      DateFormat('hh:mm a').format(start),
                      style: sansproBold.copyWith(
                          fontSize: 15, color: isDark ? WireframeColor.white : WireframeColor.black),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _statCard(double height, double width, bool isDark, {required String label, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(width / 28),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : WireframeColor.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
              overflow: TextOverflow.ellipsis),
          SizedBox(height: height / 160),
          child,
        ],
      ),
    );
  }

  Widget _quickActionButton(
      double height,
      double width, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        bool filled = true,
        bool isDark = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height / 60),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: [WireframeColor.appcolor, WireframeColor.lightappcolor])
              : null,
          color: filled ? null : (isDark ? WireframeColor.lightblack : WireframeColor.white),
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: WireframeColor.appcolor.withAlpha(80)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? WireframeColor.white : WireframeColor.appcolor, size: 18),
            SizedBox(width: width / 56),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: sansproSemibold.copyWith(
                    color: filled ? WireframeColor.white : WireframeColor.appcolor, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  Widget _activeTripCard(double height, double width, bool isDark, DriverActiveTrip trip) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width / 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus_filled, color: WireframeColor.white),
              SizedBox(width: width / 40),
              Text(
                'Trip Running'.tr,
                style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 16),
              ),
              const Spacer(),
              Obx(() {
                driverCtrl.tripElapsedSeconds.value; // rebuild every second
                final secs = driverCtrl.tripElapsedSeconds.value;
                final h = secs ~/ 3600;
                final m = (secs % 3600) ~/ 60;
                final s = secs % 60;
                final text = h > 0
                    ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
                    : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: WireframeColor.white.withAlpha(35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(text,
                      style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 12)),
                );
              }),
            ],
          ),
          SizedBox(height: height / 80),
          Text(
            'Trip ID: ${trip.id}${trip.tripType != null ? '  •  ${trip.tripType}' : ''}',
            style: sansproRegular.copyWith(color: WireframeColor.lightwhite, fontSize: 12),
          ),
          SizedBox(height: height / 40),
          Obx(
                () => SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: WireframeColor.white,
                  padding: EdgeInsets.symmetric(vertical: height / 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: driverCtrl.tripActionLoading.value ? null : _endTrip,
                child: driverCtrl.tripActionLoading.value
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: WireframeColor.appcolor),
                )
                    : Text('End Trip'.tr,
                    style: sansproSemibold.copyWith(color: WireframeColor.appcolor, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _startTripCard(double height, double width, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width / 22),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : WireframeColor.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(
            () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start a Trip'.tr,
              style: sansproSemibold.copyWith(
                  fontSize: 16, color: isDark ? WireframeColor.white : WireframeColor.black),
            ),
            SizedBox(height: height / 60),

            Text('Select Bus'.tr, style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray)),
            SizedBox(height: height / 150),
            if (driverCtrl.buses.isEmpty)
              Text('No bus assigned.'.tr,
                  style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray))
            else
              DropdownButtonFormField<DriverBus>(
                initialValue: _selectedBus,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: width / 40, vertical: height / 100),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: WireframeColor.bggray),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: driverCtrl.buses
                    .map((bus) => DropdownMenuItem(
                  value: bus,
                  child: Text('${bus.busName} (${bus.vehicleNo})',
                      style: sansproRegular.copyWith(fontSize: 13)),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBus = value),
              ),
            SizedBox(height: height / 40),

            Text('Trip Type'.tr, style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray)),
            SizedBox(height: height / 150),
            Row(
              children: ['morning', 'afternoon', 'other'].map((type) {
                final selected = _selectedTripType == type;
                return Padding(
                  padding: EdgeInsets.only(right: width / 40),
                  child: ChoiceChip(
                    label: Text(type.tr, style: sansproRegular.copyWith(fontSize: 12)),
                    selected: selected,
                    selectedColor: WireframeColor.appcolor.withAlpha(40),
                    onSelected: (_) => setState(() => _selectedTripType = type),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: height / 36),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: WireframeColor.appcolor,
                  padding: EdgeInsets.symmetric(vertical: height / 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: driverCtrl.tripActionLoading.value ? null : _startTrip,
                child: driverCtrl.tripActionLoading.value
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: WireframeColor.white),
                )
                    : Text('Start Trip'.tr,
                    style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Onboarded student tile: Time / Student ID / Name / Class / Boarding ──
  Widget _onboardedStudentTile(double height, double width, bool isDark, OnboardedStudent s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 60),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : WireframeColor.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: WireframeColor.appcolor.withAlpha(30),
            child: const Icon(Icons.person, color: WireframeColor.appcolor, size: 18),
          ),
          SizedBox(width: width / 36),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.studentName.isNotEmpty ? s.studentName : s.studentUid,
                  style: sansproSemibold.copyWith(
                      fontSize: 13, color: isDark ? WireframeColor.white : WireframeColor.black),
                ),
                SizedBox(height: height / 300),
                Text(
                  'ID: ${s.studentId ?? s.studentUid}${s.className != null ? '  •  ${s.className}' : ''}',
                  style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
                ),
                if (s.boardingLocation != null)
                  Text(
                    '${'Boarding'.tr}: ${s.boardingLocation}',
                    style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
                  ),
              ],
            ),
          ),
          Text(
            s.onboardedAt ?? '-',
            style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
          ),
        ],
      ),
    );
  }
}

// ── small local extensions so this file doesn't depend on the
// `collection` package just for a couple of one-off lookups ───────────────
extension _FirstWhereOrNullSafe<T> on List<T> {
  T? firstWhereOrNullSafe(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
