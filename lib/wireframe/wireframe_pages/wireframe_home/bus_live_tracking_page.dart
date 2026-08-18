import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'bus_controller.dart';
import 'page_background.dart'; // ১ম কোডের কাস্টম ব্যাকগ্রাউন্ড ইমপোর্ট

// ════════════════════════════════════════════════════════════════════════════
// LIVE LOCATION + LIVE TRACKING (PERFECTED VERSION - UPDATED)
// ════════════════════════════════════════════════════════════════════════════
class BusLiveTrackingPage extends StatefulWidget {
  const BusLiveTrackingPage({Key? key}) : super(key: key);

  @override
  State<BusLiveTrackingPage> createState() => _BusLiveTrackingPageState();
}

class _BusLiveTrackingPageState extends State<BusLiveTrackingPage> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  final busCtrl = Get.put(BusController());

  GoogleMapController? _mapController;
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(23.7553, 90.3735), // Dhaka fallback center
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    // Live Tracking মোড চালু — এখন থেকে নিয়মিত পোলিং শুরু হবে
    busCtrl.startLiveTracking();
  }

  @override
  void dispose() {
    // স্ক্রিন থেকে বের হওয়ার সাথে সাথেই পোলিং বন্ধ — ব্যাটারি/ডেটা বাঁচাতে জরুরি
    busCtrl.stopLiveTracking();
    super.dispose();
  }

  void _moveCameraTo(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
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
        title: 'Live_Tracking'.tr, // ২য় কোড অনুযায়ী লোকালাইজড টাইটেল
      ),
      body: PageBackground(
        category: PageCategory.bus,
        child: Column(
          children: [
            // কাস্টম অ্যাপবারের জন্য পারফেক্ট টপ স্পেসিং
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Stack(
                children: [
                  // ── ১. গুগল ম্যাপ ─────────────────────────────────────────────
                  Obx(() {
                    final loc = busCtrl.liveLocation.value;

                    // প্রথমবার বা প্রতি আপডেটে ক্যামেরা বাসের আসল পজিশনে চলে যাবে
                    if (loc != null && _mapController != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _moveCameraTo(loc.latitude, loc.longitude);
                      });
                    }

                    return GoogleMap(
                      initialCameraPosition: _initialCamera,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (loc != null) {
                          _moveCameraTo(loc.latitude, loc.longitude);
                        }
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      markers: loc == null
                          ? {}
                          : {
                        Marker(
                          markerId: const MarkerId('school_bus'),
                          position: LatLng(loc.latitude, loc.longitude),
                          rotation: loc.heading ?? 0,
                          anchor: const Offset(0.5, 0.5),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue),
                          infoWindow: InfoWindow(
                            title: "School Bus".tr,
                            snippet: loc.speedKmh != null
                                ? "${loc.speedKmh!.toStringAsFixed(0)} km/h"
                                : null,
                          ),
                        ),
                      },
                    );
                  }),

                  // ── ২. লাইভ স্ট্যাটাস ইন্ডিকেটর (টপ-রাইট কর্নারে ভাসমান) ─────────
                  Positioned(
                    top: height / 70,
                    right: width / 26,
                    child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: WireframeColor.black.withAlpha(150),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: busCtrl.isLiveTrackingActive.value
                                  ? WireframeColor.green
                                  : WireframeColor.textgray,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            busCtrl.isLiveTrackingActive.value
                                ? "Live".tr
                                : "Paused".tr,
                            style: sansproRegular.copyWith(
                                fontSize: 12, color: WireframeColor.white),
                          ),
                        ],
                      ),
                    )),
                  ),

                  // ── ৩. লোডিং ওভারলে (শুধুমাত্র প্রথম লোডের জন্য) ─────────────────
                  Obx(() {
                    if (busCtrl.liveLoading.value && busCtrl.liveLocation.value == null) {
                      return Container(
                        color: WireframeColor.black.withAlpha(60),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // ── ৪. এরর ব্যানার (ইন্ডিকেটরের নিচে পজিশনড) ─────────────────────
                  Obx(() {
                    if (!busCtrl.liveHasError.value) return const SizedBox.shrink();
                    return Positioned(
                      top: height / 14,
                      left: width / 26,
                      right: width / 26,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 26, vertical: height / 70),
                        decoration: BoxDecoration(
                          color: WireframeColor.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: WireframeColor.white, size: 18),
                            SizedBox(width: width / 56),
                            Expanded(
                              child: Text(
                                busCtrl.liveErrorMessage.value,
                                style: sansproRegular.copyWith(
                                    fontSize: 12, color: WireframeColor.white),
                              ),
                            ),
                            InkWell(
                              onTap: () => busCtrl.refreshLiveLocation(),
                              child: Text("Retry".tr,
                                  style: sansproSemibold.copyWith(
                                      fontSize: 12, color: WireframeColor.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // ── ৫. বটম ইনফো কার্ড (স্পীড ও লাস্ট আপডেট) ────────────────────
                  Obx(() {
                    final loc = busCtrl.liveLocation.value;
                    if (loc == null) return const SizedBox.shrink();
                    return Positioned(
                      bottom: height / 36,
                      left: width / 26,
                      right: width / 26,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 26, vertical: height / 56),
                        decoration: BoxDecoration(
                          color: themedata.isdark
                              ? WireframeColor.lightblack
                              : WireframeColor.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: WireframeColor.black.withAlpha(20),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: WireframeColor.appcolor.withAlpha(25),
                              child: const Icon(Icons.directions_bus_filled,
                                  color: WireframeColor.appcolor),
                            ),
                            SizedBox(width: width / 36),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "School_Bus".tr,
                                    style: sansproSemibold.copyWith(
                                        fontSize: 14,
                                        color: themedata.isdark
                                            ? WireframeColor.white
                                            : WireframeColor.black),
                                  ),
                                  SizedBox(height: height / 200),
                                  Text(
                                    "${"Last_Updated".tr}: ${loc.lastUpdated}",
                                    style: sansproRegular.copyWith(
                                        fontSize: 11, color: WireframeColor.textgray),
                                  ),
                                ],
                              ),
                            ),
                            if (loc.speedKmh != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    loc.speedKmh!.toStringAsFixed(0),
                                    style: sansproBold.copyWith(
                                        fontSize: 20, color: WireframeColor.appcolor),
                                  ),
                                  Text(
                                    "km/h",
                                    style: sansproRegular.copyWith(
                                        fontSize: 11, color: WireframeColor.textgray),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}