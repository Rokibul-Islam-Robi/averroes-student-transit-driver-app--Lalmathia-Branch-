import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'report_card_controller.dart';
import 'page_background.dart';

// ══════════════════════════════════════════════════════════════════════════
// পুরোনো ReportCardListPage এখান থেকে সরিয়ে ফেলা হয়েছে — Report Card এর জন্য
// আলাদা কোনো পেজ আর নেই, এই তালিকা এখন সরাসরি Result পেজেই
// (wireframe_result.dart) দেখানো হয়। ReportCardDetailPage এখনো এখানে আছে,
// Result পেজ থেকে exam-এর বিস্তারিত রেজাল্ট দেখানোর জন্য এটা ব্যবহার হয়।
// ══════════════════════════════════════════════════════════════════════════
class ReportCardDetailPage extends StatefulWidget {
  final String examId;
  const ReportCardDetailPage({super.key, required this.examId});

  @override
  State<ReportCardDetailPage> createState() => _ReportCardDetailPageState();
}

class _ReportCardDetailPageState extends State<ReportCardDetailPage> {
  final ReportCardController ctrl = Get.find<ReportCardController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchReportCard(widget.examId);
  }

  Future<void> _downloadAndOpenPdf(ReportCard card) async {
    final path = await ctrl.downloadReportCardPdf(card);
    if (path != null) {
      await OpenFilex.open(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(
        title: 'Report Card Details',
      ),
      body: PageBackground(
        category: PageCategory.result,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Obx(() {
                if (ctrl.isReportLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.reportHasError.value) {
                  return Center(child: Text(ctrl.reportErrorMessage.value));
                }
                final card = ctrl.reportCard.value;
                if (card == null) return const SizedBox.shrink();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.examName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${card.studentName}   |   ${card.className}-${card.section}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey.shade200, width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
                              children: [
                                Padding(padding: EdgeInsets.all(12), child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(12), child: Text('Marks', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                Padding(padding: EdgeInsets.all(12), child: Text('Full', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                Padding(padding: EdgeInsets.all(12), child: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                              ],
                            ),
                            ...card.subjects.map(
                                  (s) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(12), child: Text(s.subject)),
                                  Padding(padding: const EdgeInsets.all(12), child: Text(s.marksObtained, textAlign: TextAlign.center)),
                                  Padding(padding: const EdgeInsets.all(12), child: Text(s.fullMarks, textAlign: TextAlign.center)),
                                  Padding(padding: const EdgeInsets.all(12), child: Text(s.grade, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            Text('Total: ${card.totalMarks}/${card.fullTotalMarks}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('GPA: ${card.gpa}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            Text('Result: ${card.result}', style: TextStyle(fontWeight: FontWeight.bold, color: card.result.toLowerCase() == 'passed' ? Colors.green : Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    if (card.remarks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('মন্তব্য: ${card.remarks}', style: TextStyle(color: Colors.amber.shade900)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Obx(() => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: ctrl.isDownloadingPdf.value
                          ? null
                          : () => _downloadAndOpenPdf(card),
                      icon: ctrl.isDownloadingPdf.value
                          ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        ctrl.isDownloadingPdf.value
                            ? 'ডাউনলোড হচ্ছে...'
                            : 'PDF হিসেবে ডাউনলোড করো',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportCardController ctrl = Get.find<ReportCardController>();

    return Obx(() {
      if (ctrl.isAttendanceLoading.value) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      if (ctrl.attendanceHasError.value) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(ctrl.attendanceErrorMessage.value),
          ),
        );
      }
      final a = ctrl.attendance.value;
      if (a == null) return const SizedBox.shrink();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${a.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Present: ${a.presentDays}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                      Text('Absent: ${a.absentDays}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                      Text('Leave: ${a.leaveDays}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: a.percentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(a.percentage > 75 ? Colors.green : Colors.orange),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}