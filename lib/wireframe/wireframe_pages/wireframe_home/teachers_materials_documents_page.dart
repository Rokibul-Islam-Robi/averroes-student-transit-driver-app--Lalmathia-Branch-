import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// TEACHERS MATERIALS → OFFICIAL DOCUMENTS
//   Academic official documents, class materials, and student performance
//   reports shared by teachers.
// ════════════════════════════════════════════════════════════════════════════
//
// static placeholder ডেটা — পরে API যুক্ত হলে `_buildDocuments()` এর
// জায়গায় controller থেকে আসা লিস্ট বসিয়ে দিলেই চলবে, UI অপরিবর্তিত থাকবে।
// ════════════════════════════════════════════════════════════════════════════

enum DocumentCategory { official, material, performance }

extension DocumentCategoryX on DocumentCategory {
  String get label {
    switch (this) {
      case DocumentCategory.official:
        return "Official Document";
      case DocumentCategory.material:
        return "Class Material";
      case DocumentCategory.performance:
        return "Performance Report";
    }
  }

  Color get color {
    switch (this) {
      case DocumentCategory.official:
        return const Color(0xff4F46E5);
      case DocumentCategory.material:
        return const Color(0xff0D9488);
      case DocumentCategory.performance:
        return const Color(0xffDB2777);
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentCategory.official:
        return Icons.badge_outlined;
      case DocumentCategory.material:
        return Icons.menu_book_outlined;
      case DocumentCategory.performance:
        return Icons.query_stats_rounded;
    }
  }
}

class TeacherDocument {
  final String title;
  final DocumentCategory category;
  final String teacherName;
  final String className;
  final String sectionName;
  final String fileUrl;
  final String fileSize;
  final DateTime uploadedOn;

  const TeacherDocument({
    required this.title,
    required this.category,
    required this.teacherName,
    required this.className,
    required this.sectionName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedOn,
  });
}

List<TeacherDocument> _buildDocuments() {
  final now = DateTime.now();
  DateTime d(int daysAgo) => now.subtract(Duration(days: daysAgo));

  return [
    TeacherDocument(
      title: "Admit Card - Term Final Exam",
      category: DocumentCategory.official,
      teacherName: "Academic Office",
      className: "Class 4",
      sectionName: "Morning",
      fileUrl: "https://averroesint.com/documents/class4-admit-card.pdf",
      fileSize: "212 KB",
      uploadedOn: d(1),
    ),
    TeacherDocument(
      title: "Mathematics - Chapter 5 Notes",
      category: DocumentCategory.material,
      teacherName: "Mr. Rakibul Islam",
      className: "Class 4",
      sectionName: "Morning",
      fileUrl: "https://averroesint.com/materials/class4-math-ch5.pdf",
      fileSize: "1.1 MB",
      uploadedOn: d(2),
    ),
    TeacherDocument(
      title: "Mid-Term Performance Report",
      category: DocumentCategory.performance,
      teacherName: "Ms. Farzana Akter",
      className: "Class 4",
      sectionName: "Morning",
      fileUrl: "https://averroesint.com/reports/class4-midterm-report.pdf",
      fileSize: "340 KB",
      uploadedOn: d(4),
    ),
    TeacherDocument(
      title: "School Circular - Winter Vacation",
      category: DocumentCategory.official,
      teacherName: "Academic Office",
      className: "All Classes",
      sectionName: "-",
      fileUrl: "https://averroesint.com/documents/winter-vacation-circular.pdf",
      fileSize: "180 KB",
      uploadedOn: d(6),
    ),
    TeacherDocument(
      title: "Biology - Cell Structure Notes",
      category: DocumentCategory.material,
      teacherName: "Ms. Sultana Rajia",
      className: "Class 5",
      sectionName: "Morning",
      fileUrl: "https://averroesint.com/materials/class5-biology-cell.pdf",
      fileSize: "980 KB",
      uploadedOn: d(3),
    ),
    TeacherDocument(
      title: "Monthly Attendance & Progress Report",
      category: DocumentCategory.performance,
      teacherName: "Mr. Abdullah Al Mamun",
      className: "Class 5",
      sectionName: "Morning",
      fileUrl: "https://averroesint.com/reports/class5-monthly-report.pdf",
      fileSize: "290 KB",
      uploadedOn: d(7),
    ),
  ];
}

class TeachersMaterialsDocumentsPage extends StatefulWidget {
  const TeachersMaterialsDocumentsPage({Key? key}) : super(key: key);

  @override
  State<TeachersMaterialsDocumentsPage> createState() => _TeachersMaterialsDocumentsPageState();
}

class _TeachersMaterialsDocumentsPageState extends State<TeachersMaterialsDocumentsPage> {
  final List<TeacherDocument> _documents = _buildDocuments();
  DocumentCategory? _filter;

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open the document.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final filtered =
    _filter == null ? _documents : _documents.where((d) => d.category == _filter).toList();
    final sorted = [...filtered]..sort((a, b) => b.uploadedOn.compareTo(a.uploadedOn));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(title: 'Official Documents'),
      body: PageBackground(
        category: PageCategory.teachersMaterials,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "Academic documents, class materials & performance reports.",
                style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.white.withAlpha(230)),
              ),
            ),
            SizedBox(height: height / 55),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: width / 20),
                children: [
                  _FilterChip(label: "All".tr, selected: _filter == null, onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  for (final c in DocumentCategory.values) ...[
                    _FilterChip(
                      label: c.label.tr,
                      selected: _filter == c,
                      onTap: () => setState(() => _filter = c),
                      color: c.color,
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            SizedBox(height: height / 55),
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
                child: sorted.isEmpty
                    ? Center(
                  child: Text(
                    "No documents yet.".tr,
                    style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                  ),
                )
                    : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 40),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => SizedBox(height: height / 80),
                  itemBuilder: (context, index) => _DocumentTile(
                    doc: sorted[index],
                    width: width,
                    height: height,
                    onTap: () => _openDocument(sorted[index].fileUrl),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final base = color ?? WireframeColor.appcolor;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? base : Colors.white.withAlpha(45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? base : Colors.white.withAlpha(80)),
        ),
        child: Text(
          label,
          style: sansproSemibold.copyWith(
            fontSize: 11.5,
            color: selected ? WireframeColor.white : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final TeacherDocument doc;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _DocumentTile({required this.doc, required this.width, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 65),
        decoration: BoxDecoration(
          color: WireframeColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WireframeColor.bggray),
          boxShadow: [
            BoxShadow(color: WireframeColor.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: height / 20,
              width: height / 20,
              decoration: BoxDecoration(
                color: doc.category.color.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(doc.category.icon, color: doc.category.color),
            ),
            SizedBox(width: width / 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sansproSemibold.copyWith(fontSize: 13.5, color: WireframeColor.black),
                  ),
                  SizedBox(height: height / 400),
                  Text(
                    "${doc.className} \u00b7 ${doc.sectionName} \u00b7 ${doc.teacherName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
                  ),
                  SizedBox(height: height / 300),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: doc.category.color.withAlpha(24),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          doc.category.label.tr,
                          style: sansproSemibold.copyWith(fontSize: 9.5, color: doc.category.color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${doc.fileSize} \u00b7 ${DateFormat('d MMM').format(doc.uploadedOn)}",
                        style: sansproRegular.copyWith(fontSize: 10, color: WireframeColor.textgray),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, size: 18, color: WireframeColor.appgray),
          ],
        ),
      ),
    );
  }
}
