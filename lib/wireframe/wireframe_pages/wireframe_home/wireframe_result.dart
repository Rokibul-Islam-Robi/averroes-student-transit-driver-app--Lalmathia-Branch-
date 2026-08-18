import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_support.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import '../../wireframe_gloabelclass/wireframe_icons.dart';
import 'page_background.dart';
import 'report_card_controller.dart';
import 'report_card_page.dart';

// ══════════════════════════════════════════════════════════════════════════
// Result পেজ — আগের static/demo UI সরিয়ে এখন এখানেই আসল Report Card
// (exam list + GPA + subject-wise marks + PDF download) দেখানো হচ্ছে।
// আলাদা কোনো "Report Card" পেজ/মেনু আর নেই — dashboard থেকে সরাসরি এই
// Result পেজেই সব রেজাল্ট সংক্রান্ত তথ্য পাওয়া যাবে।
// ══════════════════════════════════════════════════════════════════════════
class WireframeResult extends StatelessWidget {
  const WireframeResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReportCardController ctrl = Get.put(ReportCardController());
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.lightappcolor,
      appBar: PageAppBar(
        title: 'Result',
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              highlightColor: WireframeColor.transparent,
              splashColor: WireframeColor.transparent,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const WireframeSupport();
                  },
                ));
              },
              child: Image.asset(
                WireframePngimage.icshare,
                height: height / 36,
              ),
            ),
          ),
        ],
      ),
      body: PageBackground(
        category: PageCategory.result,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Obx(() {
                if (ctrl.isExamListLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.examListHasError.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        ctrl.examListErrorMessage.value,
                        textAlign: TextAlign.center,
                        style: sansproRegular.copyWith(fontSize: 14),
                      ),
                    ),
                  );
                }
                if (ctrl.exams.isEmpty) {
                  return Center(
                    child: Text(
                      'এখনো কোনো exam result প্রকাশিত হয়নি।',
                      style: sansproRegular.copyWith(fontSize: 14),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: ctrl.fetchExamList,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: ctrl.exams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final e = ctrl.exams[i];
                      final isPublished = e.resultStatus.toLowerCase() == 'published';
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Icon(Icons.fact_check_outlined, color: Colors.white),
                          ),
                          title: Text(
                            e.examName,
                            style: sansproSemibold.copyWith(fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'সেশন: ${e.session}   |   স্ট্যাটাস: ${e.resultStatus}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          trailing: isPublished
                              ? Chip(
                            label: Text(
                              'GPA ${e.gpa}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide.none,
                          )
                              : const Icon(Icons.hourglass_empty, color: Colors.orange),
                          onTap: isPublished
                              ? () => Get.to(() => ReportCardDetailPage(examId: e.examId))
                              : null,
                        ),
                      );
                    },
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
