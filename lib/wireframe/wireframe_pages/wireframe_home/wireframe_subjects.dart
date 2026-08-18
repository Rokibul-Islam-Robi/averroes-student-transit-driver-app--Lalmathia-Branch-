import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// ২য় কোড অনুযায়ী প্রোজেক্টের নতুন থিম কন্ট্রোলার পাথ আপডেট করা হয়েছে
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'lookup_controller.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUBJECTS DIRECTORY
// ════════════════════════════════════════════════════════════════════════════
class WireframeSubjects extends StatelessWidget {
  const WireframeSubjects({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final themedata = Get.put(WireframeThemecontroler());
    final lookupCtrl = Get.put(LookupController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(
        title: 'Subjects',
      ),
      body: PageBackground(
        category: PageCategory.syllabus,
        child: Column(
          children: [
            // AppBar এবং Status Bar এর জন্য সঠিক স্পেসিং টপ মার্জিন
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

            Expanded(
              child: Obx(() {
                if (lookupCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: WireframeColor.white),
                  );
                }

                if (lookupCtrl.hasError.value && lookupCtrl.subjects.isEmpty) {
                  return _ErrorState(
                    message: lookupCtrl.errorMessage.value,
                    onRetry: lookupCtrl.refreshAllLookups,
                    height: height,
                  );
                }

                if (lookupCtrl.subjects.isEmpty) {
                  return Center(
                    child: Text(
                      "No_subjects_found".tr,
                      style: const TextStyle(color: WireframeColor.white),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: lookupCtrl.refreshAllLookups,
                  color: WireframeColor.appcolor,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    // ১ম কোডের অপ্টিমাইজড ফ্ল্যাট ListView ব্যবহার করা হয়েছে (Memory Management এর জন্য সেরা)
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 26,
                        vertical: height / 36,
                      ),
                      itemCount: lookupCtrl.subjects.length + 1,
                      separatorBuilder: (context, index) {
                        if (index == 0) return SizedBox(height: height / 56); // কাউন্টারের পরের গ্যাপ
                        return SizedBox(height: height / 70); // কার্ডগুলোর মাঝের গ্যাপ
                      },
                      itemBuilder: (context, index) {
                        // ── Index 0: Total Subjects Counter ──
                        if (index == 0) {
                          return Text(
                            "${"Total_Subjects".tr}: ${lookupCtrl.subjects.length}",
                            style: sansproSemibold.copyWith(
                              fontSize: 15,
                              color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                            ),
                          );
                        }

                        // Subject Data (Index শিফট করা হয়েছে কাউন্টারের কারণে)
                        final subject = lookupCtrl.subjects[index - 1];

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width / 26,
                            vertical: height / 60,
                          ),
                          decoration: BoxDecoration(
                            color: themedata.isdark
                                ? WireframeColor.lightblack
                                : WireframeColor.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: WireframeColor.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // ── duotone badge: subject-এর প্রথম অক্ষর ────────
                              Container(
                                height: height / 18,
                                width: height / 18,
                                decoration: const BoxDecoration(
                                  color: WireframeColor.subjectsBadgeBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    subject.name.isNotEmpty
                                        ? subject.name[0].toUpperCase()
                                        : "?",
                                    style: sansproBold.copyWith(
                                      fontSize: 18,
                                      color: WireframeColor.subjectsBadgeIcon,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: width / 36),

                              // ── Subject Name & Code/Type ────────
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.name,
                                      style: sansproSemibold.copyWith(
                                        fontSize: 15,
                                        color: themedata.isdark
                                            ? WireframeColor.white
                                            : WireframeColor.black,
                                      ),
                                    ),
                                    SizedBox(height: height / 250),
                                    Text(
                                      "${"Code".tr}: ${subject.code.isEmpty ? "—" : subject.code}"
                                          "${subject.type.isEmpty ? "" : "   •   ${subject.type}"}",
                                      style: sansproRegular.copyWith(
                                        fontSize: 12,
                                        color: WireframeColor.textgray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ── Status badge (Active/Inactive) ────────────────
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width / 56,
                                  vertical: height / 200,
                                ),
                                decoration: BoxDecoration(
                                  color: (subject.isActive
                                      ? WireframeColor.green
                                      : WireframeColor.red)
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  subject.isActive ? "Active".tr : "Inactive".tr,
                                  style: sansproSemibold.copyWith(
                                    fontSize: 11,
                                    color: subject.isActive
                                        ? WireframeColor.green
                                        : WireframeColor.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Shared error-state widget
// ════════════════════════════════════════════════════════════════════════════
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
            Icon(Icons.wifi_off, size: height / 16, color: WireframeColor.white),
            SizedBox(height: height / 56),
            Text(
              message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.white),
            ),
            SizedBox(height: height / 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => onRetry(),
              child: Text(
                "Retry".tr,
                style: sansproSemibold.copyWith(color: WireframeColor.appcolor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}