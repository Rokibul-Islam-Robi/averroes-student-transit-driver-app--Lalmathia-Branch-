import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// TEACHERS MATERIALS → CLASSES — every section/class-wise subject materials
// ════════════════════════════════════════════════════════════════════════════
//
// static placeholder ডেটা — পরে API যুক্ত হলে `_buildClassMaterials()` এর
// জায়গায় controller থেকে আসা লিস্ট বসিয়ে দিলেই চলবে, UI অপরিবর্তিত থাকবে।
// ════════════════════════════════════════════════════════════════════════════

class ClassMaterialFile {
  final String fileName;
  final String type; // PDF, DOCX, IMAGE, PPT, LINK
  final String fileUrl;
  final String uploadedBy;
  final DateTime uploadedOn;

  const ClassMaterialFile({
    required this.fileName,
    required this.type,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadedOn,
  });
}

class ClassMaterialSubject {
  final String subjectName;
  final List<ClassMaterialFile> files;
  const ClassMaterialSubject({required this.subjectName, required this.files});
}

class ClassMaterialGroup {
  final String className;
  final String sectionName;
  final List<ClassMaterialSubject> subjects;
  const ClassMaterialGroup({
    required this.className,
    required this.sectionName,
    required this.subjects,
  });

  int get totalFiles => subjects.fold(0, (sum, s) => sum + s.files.length);
}

List<ClassMaterialGroup> _buildClassMaterials() {
  final now = DateTime.now();
  DateTime d(int daysAgo) => now.subtract(Duration(days: daysAgo));

  return [
    ClassMaterialGroup(
      className: "Class 4",
      sectionName: "Morning",
      subjects: [
        ClassMaterialSubject(subjectName: "Mathematics", files: [
          ClassMaterialFile(
              fileName: "Chapter 5 - Fractions Notes.pdf",
              type: "PDF",
              fileUrl: "https://averroesint.com/materials/class4-math-ch5.pdf",
              uploadedBy: "Mr. Rakibul Islam",
              uploadedOn: d(1)),
          ClassMaterialFile(
              fileName: "Practice Worksheet 5.docx",
              type: "DOCX",
              fileUrl: "https://averroesint.com/materials/class4-math-worksheet5.docx",
              uploadedBy: "Mr. Rakibul Islam",
              uploadedOn: d(3)),
        ]),
        ClassMaterialSubject(subjectName: "English Language", files: [
          ClassMaterialFile(
              fileName: "Grammar Guide - Tenses.pdf",
              type: "PDF",
              fileUrl: "https://averroesint.com/materials/class4-english-tenses.pdf",
              uploadedBy: "Ms. Farzana Akter",
              uploadedOn: d(2)),
        ]),
        ClassMaterialSubject(subjectName: "Science", files: [
          ClassMaterialFile(
              fileName: "Water Cycle Diagram.png",
              type: "IMAGE",
              fileUrl: "https://averroesint.com/materials/class4-science-watercycle.png",
              uploadedBy: "Mr. Shahriar Kabir",
              uploadedOn: d(5)),
        ]),
      ],
    ),
    ClassMaterialGroup(
      className: "Class 4",
      sectionName: "Day",
      subjects: [
        ClassMaterialSubject(subjectName: "Bangla", files: [
          ClassMaterialFile(
              fileName: "Poem - First Lesson.pdf",
              type: "PDF",
              fileUrl: "https://averroesint.com/materials/class4-bangla-kobita.pdf",
              uploadedBy: "Ms. Nusrat Jahan",
              uploadedOn: d(4)),
        ]),
        ClassMaterialSubject(subjectName: "ICT", files: [
          ClassMaterialFile(
              fileName: "Intro to Computers - Slides.pptx",
              type: "PPT",
              fileUrl: "https://averroesint.com/materials/class4-ict-intro.pptx",
              uploadedBy: "Mr. Tanvir Ahmed",
              uploadedOn: d(6)),
        ]),
      ],
    ),
    ClassMaterialGroup(
      className: "Class 5",
      sectionName: "Morning",
      subjects: [
        ClassMaterialSubject(subjectName: "Biology", files: [
          ClassMaterialFile(
              fileName: "Cell Structure Notes.pdf",
              type: "PDF",
              fileUrl: "https://averroesint.com/materials/class5-biology-cell.pdf",
              uploadedBy: "Ms. Sultana Rajia",
              uploadedOn: d(1)),
        ]),
        ClassMaterialSubject(subjectName: "Al-Quran", files: []),
      ],
    ),
  ];
}

class TeachersMaterialsClassesPage extends StatefulWidget {
  const TeachersMaterialsClassesPage({Key? key}) : super(key: key);

  @override
  State<TeachersMaterialsClassesPage> createState() => _TeachersMaterialsClassesPageState();
}

class _TeachersMaterialsClassesPageState extends State<TeachersMaterialsClassesPage> {
  final List<ClassMaterialGroup> _groups = _buildClassMaterials();
  int? _expandedIndex = 0;

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open the file.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(title: 'Classes'),
      body: PageBackground(
        category: PageCategory.teachersMaterials,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "Subject-wise class materials, organized by class & section.",
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
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 40),
                  itemCount: _groups.length,
                  separatorBuilder: (_, __) => SizedBox(height: height / 70),
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    final isOpen = _expandedIndex == index;
                    return _ClassGroupCard(
                      group: group,
                      isOpen: isOpen,
                      width: width,
                      height: height,
                      onToggle: () => setState(() => _expandedIndex = isOpen ? null : index),
                      onOpenFile: _openFile,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassGroupCard extends StatelessWidget {
  final ClassMaterialGroup group;
  final bool isOpen;
  final double width;
  final double height;
  final VoidCallback onToggle;
  final ValueChanged<String> onOpenFile;

  const _ClassGroupCard({
    required this.group,
    required this.isOpen,
    required this.width,
    required this.height,
    required this.onToggle,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: WireframeColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WireframeColor.bggray),
        boxShadow: [
          BoxShadow(color: WireframeColor.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 60),
              child: Row(
                children: [
                  Container(
                    height: height / 20,
                    width: height / 20,
                    decoration: const BoxDecoration(
                      color: WireframeColor.subjectsBadgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.class_outlined, color: WireframeColor.subjectsBadgeIcon),
                  ),
                  SizedBox(width: width / 30),
                  Expanded(
                    child: Text(
                      "${group.className} \u00b7 ${group.sectionName}",
                      style: sansproSemibold.copyWith(fontSize: 15, color: WireframeColor.black),
                    ),
                  ),
                  Text(
                    "${group.totalFiles} Files".tr,
                    style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                  ),
                  SizedBox(width: width / 60),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: WireframeColor.appgray),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.fromLTRB(width / 26, 0, width / 26, height / 60),
              child: Column(
                children: group.subjects
                    .map((s) => _SubjectMaterialTile(
                  subject: s,
                  width: width,
                  height: height,
                  onOpenFile: onOpenFile,
                ))
                    .toList(),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SubjectMaterialTile extends StatelessWidget {
  final ClassMaterialSubject subject;
  final double width;
  final double height;
  final ValueChanged<String> onOpenFile;

  const _SubjectMaterialTile({
    required this.subject,
    required this.width,
    required this.height,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: height / 90),
      padding: EdgeInsets.symmetric(horizontal: width / 30, vertical: height / 80),
      decoration: BoxDecoration(
        color: WireframeColor.lightgray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.subjectName,
            style: sansproSemibold.copyWith(fontSize: 13.5, color: WireframeColor.black),
          ),
          if (subject.files.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: height / 200),
              child: Text(
                "No materials added yet.".tr,
                style: sansproRegular.copyWith(fontSize: 11.5, color: WireframeColor.textgray),
              ),
            )
          else
            ...subject.files.map((f) => _FileRow(file: f, onTap: () => onOpenFile(f.fileUrl))),
        ],
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final ClassMaterialFile file;
  final VoidCallback onTap;
  const _FileRow({required this.file, required this.onTap});

  IconData get _icon {
    switch (file.type) {
      case "PDF":
        return Icons.picture_as_pdf_outlined;
      case "DOCX":
        return Icons.description_outlined;
      case "PPT":
        return Icons.slideshow_outlined;
      case "IMAGE":
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: WireframeColor.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(_icon, size: 18, color: WireframeColor.subjectsBadgeIcon),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sansproSemibold.copyWith(fontSize: 12, color: WireframeColor.black),
                  ),
                  Text(
                    "${file.uploadedBy} \u00b7 ${DateFormat('d MMM').format(file.uploadedOn)}",
                    style: sansproRegular.copyWith(fontSize: 10, color: WireframeColor.textgray),
                  ),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, size: 16, color: WireframeColor.appgray),
          ],
        ),
      ),
    );
  }
}
