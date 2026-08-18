import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p; // পাথ জয়েনিং এর জন্য নিরাপদ
import 'package:path_provider/path_provider.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════════════════════

class SubjectResult {
  final String subject;
  final String marksObtained;
  final String fullMarks;
  final String grade;

  SubjectResult({
    required this.subject,
    required this.marksObtained,
    required this.fullMarks,
    required this.grade,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      subject: json['subject']?.toString() ?? '',
      marksObtained: json['marks_obtained']?.toString() ?? '',
      fullMarks: json['full_marks']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
    );
  }
}

class ExamSummaryItem {
  final String examId;
  final String examName;
  final String session;
  final String resultStatus;
  final String gpa;
  final String result;

  ExamSummaryItem({
    required this.examId,
    required this.examName,
    required this.session,
    required this.resultStatus,
    required this.gpa,
    required this.result,
  });

  factory ExamSummaryItem.fromJson(Map<String, dynamic> json) {
    return ExamSummaryItem(
      examId: json['exam_id']?.toString() ?? '',
      examName: json['exam_name']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      resultStatus: json['result_status']?.toString() ?? '',
      gpa: json['gpa']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
    );
  }
}

class ReportCard {
  final String examId;
  final String examName;
  final String studentName;
  final String className;
  final String section;
  final List<SubjectResult> subjects;
  final String totalMarks;
  final String fullTotalMarks;
  final String gpa;
  final String result;
  final String remarks;
  final String pdfUrl;

  ReportCard({
    required this.examId,
    required this.examName,
    required this.studentName,
    required this.className,
    required this.section,
    required this.subjects,
    required this.totalMarks,
    required this.fullTotalMarks,
    required this.gpa,
    required this.result,
    required this.remarks,
    required this.pdfUrl,
  });

  factory ReportCard.fromJson(Map<String, dynamic> json) {
    return ReportCard(
      examId: json['exam_id']?.toString() ?? '',
      examName: json['exam_name']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => SubjectResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalMarks: json['total_marks']?.toString() ?? '',
      fullTotalMarks: json['full_total_marks']?.toString() ?? '',
      gpa: json['gpa']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      pdfUrl: json['pdf_url']?.toString() ?? '',
    );
  }
}

class AttendanceSummary {
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final int totalDays;
  final double percentage;

  AttendanceSummary({
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.totalDays,
    required this.percentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      presentDays: int.tryParse(json['present_days']?.toString() ?? '0') ?? 0,
      absentDays: int.tryParse(json['absent_days']?.toString() ?? '0') ?? 0,
      leaveDays: int.tryParse(json['leave_days']?.toString() ?? '0') ?? 0,
      totalDays: int.tryParse(json['total_days']?.toString() ?? '0') ?? 0,
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════

class ReportCardController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _examListEndpoint = '/student/exams';
  static const String _reportCardEndpoint = '/student/report-card';
  static const String _attendanceEndpoint = '/student/attendance/summary';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // States
  var isExamListLoading = true.obs;
  var examListHasError = false.obs;
  var examListErrorMessage = ''.obs;
  var exams = <ExamSummaryItem>[].obs;

  var selectedClass = ''.obs;
  var selectedSection = ''.obs;

  var isReportLoading = false.obs;
  var reportHasError = false.obs;
  var reportErrorMessage = ''.obs;
  var reportCard = Rxn<ReportCard>(); // Rxn ব্যবহার করা নাল-সেফটির জন্য বেস্ট

  var isAttendanceLoading = true.obs;
  var attendanceHasError = false.obs;
  var attendanceErrorMessage = ''.obs;
  var attendance = Rxn<AttendanceSummary>();

  var isDownloadingPdf = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExamList();
    fetchAttendanceSummary();
  }

  // 1. Fetch Exam List
  Future<void> fetchExamList() async {
    try {
      isExamListLoading(true);
      examListHasError(false);

      final queryParams = <String, String>{
        if (selectedClass.value.isNotEmpty) 'class': selectedClass.value,
        if (selectedSection.value.isNotEmpty) 'section': selectedSection.value,
      };

      final uri = Uri.parse('$_baseUrl$_examListEndpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          exams.value = (decoded['data'] as List<dynamic>)
              .map((e) => ExamSummaryItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          examListHasError(true);
          examListErrorMessage.value = decoded['message']?.toString() ?? 'কোনো exam পাওয়া যায়নি।';
        }
      } else {
        examListHasError(true);
        examListErrorMessage.value = 'সার্ভার ত্রুটি: ${response.statusCode}';
      }
    } catch (e) {
      examListHasError(true);
      examListErrorMessage.value = 'ইন্টারনেট সংযোগ চেক করো।';
    } finally {
      isExamListLoading(false);
    }
  }

  // 2. Fetch Report Card
  Future<void> fetchReportCard(String examId) async {
    try {
      isReportLoading(true);
      reportHasError(false);
      reportCard.value = null;

      final queryParams = <String, String>{
        if (selectedClass.value.isNotEmpty) 'class': selectedClass.value,
        if (selectedSection.value.isNotEmpty) 'section': selectedSection.value,
      };

      final uri = Uri.parse('$_baseUrl$_reportCardEndpoint/$examId').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          reportCard.value = ReportCard.fromJson(decoded['data']);
        } else {
          reportHasError(true);
          reportErrorMessage.value = decoded['message']?.toString() ?? 'Report card লোড করা যায়নি।';
        }
      } else {
        reportHasError(true);
        reportErrorMessage.value = 'সার্ভার ত্রুটি: ${response.statusCode}';
      }
    } catch (e) {
      reportHasError(true);
      reportErrorMessage.value = 'ইন্টারনেট সংযোগ চেক করো।';
    } finally {
      isReportLoading(false);
    }
  }

  // 3. Download Report Card PDF
  Future<String?> downloadReportCardPdf(ReportCard card) async {
    if (card.pdfUrl.isEmpty) {
      Get.snackbar('Error', 'এই exam-এর জন্য PDF পাওয়া যায়নি।');
      return null;
    }
    try {
      isDownloadingPdf(true);

      final uri = Uri.parse(card.pdfUrl);
      // ডাউনলোডের সময়ও একই অথেন্টিকেশন এবং সিকিউরিটি হেডার ব্যবহার করা নিরাপদ
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        Get.snackbar('Error', 'PDF ডাউনলোড ব্যর্থ (${response.statusCode}).');
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'report_card_${card.examId}_${card.studentName.replaceAll(' ', '_')}.pdf';

      // path.join ব্যবহার করে iOS/Android দুই প্ল্যাটফর্মেই সেফলি পাথ হ্যান্ডেল করা হয়েছে
      final filePath = p.join(dir.path, fileName);
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) {
      Get.snackbar('Error', 'PDF ডাউনলোড করা যায়নি। ইন্টারনেট চেক করো।');
      return null;
    } finally {
      isDownloadingPdf(false);
    }
  }

  // 4. Fetch Attendance Summary
  Future<void> fetchAttendanceSummary() async {
    try {
      isAttendanceLoading(true);
      attendanceHasError(false);

      final uri = Uri.parse('$_baseUrl$_attendanceEndpoint');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          attendance.value = AttendanceSummary.fromJson(decoded['data']);
        } else {
          attendanceHasError(true);
          attendanceErrorMessage.value = decoded['message']?.toString() ?? 'Attendance তথ্য পাওয়া যায়নি।';
        }
      } else {
        attendanceHasError(true);
        attendanceErrorMessage.value = 'সার্ভার ত্রুটি: ${response.statusCode}';
      }
    } catch (e) {
      attendanceHasError(true);
      attendanceErrorMessage.value = 'ইন্টারনেট সংযোগ চেক করো।';
    } finally {
      isAttendanceLoading(false);
    }
  }
}