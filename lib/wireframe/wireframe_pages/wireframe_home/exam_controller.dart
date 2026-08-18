import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// ════════════════════════════════════════════════════════════════════════════
// TASK I — Examination
// Covers: exam list, routine/schedule, admit card (PDF), results,
//         promotion status
// ════════════════════════════════════════════════════════════════════════════

// ── Exam list item ────────────────────────────────────────────────────────
class ExamItem {
  final String examId;
  final String name;     // "Half Yearly 2026"
  final String type;     // "Terminal", "Monthly", "Annual"
  final String session;
  final String status;   // "Upcoming", "Ongoing", "Completed"

  ExamItem({
    required this.examId,
    required this.name,
    required this.type,
    required this.session,
    required this.status,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      examId: json['exam_id']?.toString() ?? '',
      name: json['exam_name']?.toString() ?? '',
      type: json['exam_type']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

// ── Exam routine / schedule row ───────────────────────────────────────────
class RoutineItem {
  final String subject;
  final String date;   // e.g. "15 Jul 2026"
  final String day;    // e.g. "Tuesday"
  final String startTime;
  final String endTime;
  final String venue;  // room/hall

  RoutineItem({
    required this.subject,
    required this.date,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.venue,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      subject: json['subject']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
    );
  }
}

// ── Subject-wise result row ───────────────────────────────────────────────
class SubjectMark {
  final String subject;
  final String marksObtained;
  final String fullMarks;
  final String grade;
  final String status; // Pass / Fail

  SubjectMark({
    required this.subject,
    required this.marksObtained,
    required this.fullMarks,
    required this.grade,
    required this.status,
  });

  factory SubjectMark.fromJson(Map<String, dynamic> json) {
    return SubjectMark(
      subject: json['subject']?.toString() ?? '',
      marksObtained: json['marks_obtained']?.toString() ?? '',
      fullMarks: json['full_marks']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

// ── Full exam result ──────────────────────────────────────────────────────
class ExamResult {
  final String examId;
  final String examName;
  final List<SubjectMark> subjects;
  final String totalObtained;
  final String totalFull;
  final String gpa;
  final String overallResult; // Pass / Fail

  ExamResult({
    required this.examId,
    required this.examName,
    required this.subjects,
    required this.totalObtained,
    required this.totalFull,
    required this.gpa,
    required this.overallResult,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      examId: json['exam_id']?.toString() ?? '',
      examName: json['exam_name']?.toString() ?? '',
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => SubjectMark.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalObtained: json['total_obtained']?.toString() ?? '',
      totalFull: json['total_full']?.toString() ?? '',
      gpa: json['gpa']?.toString() ?? '',
      overallResult: json['result']?.toString() ?? '',
    );
  }
}

// ── Promotion status ──────────────────────────────────────────────────────
class PromotionStatus {
  final bool isPromoted;
  final String promotedToClass;
  final String promotedToSection;
  final String session;
  final String remarks;

  PromotionStatus({
    required this.isPromoted,
    required this.promotedToClass,
    required this.promotedToSection,
    required this.session,
    required this.remarks,
  });

  factory PromotionStatus.fromJson(Map<String, dynamic> json) {
    return PromotionStatus(
      isPromoted: json['is_promoted'] == true || json['is_promoted'] == 1,
      promotedToClass: json['promoted_to_class']?.toString() ?? '',
      promotedToSection: json['promoted_to_section']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
class ExamController extends GetxController {
  static const String _baseUrl =
      'https://averroesint.com/averroes_school_erp/api';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ── 1. Exam list ─────────────────────────────────────────────────────────
  // Expected JSON:
  // { "status":"success", "data": [ { "exam_id":"5", "exam_name":"Half Yearly",
  //   "exam_type":"Terminal", "session":"2025-2026", "status":"Completed" } ] }
  var isExamListLoading = true.obs;
  var examListHasError = false.obs;
  var examListErrorMessage = ''.obs;
  var exams = <ExamItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchExamList();
  }

  Future<void> fetchExamList() async {
    try {
      isExamListLoading(true);
      examListHasError(false);
      final uri = Uri.parse('$_baseUrl/student/exams');
      final response =
      await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          exams.value = (decoded['data'] as List)
              .map((e) => ExamItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          examListHasError(true);
          examListErrorMessage.value =
              decoded['message']?.toString() ?? 'No exams found.';
        }
      } else {
        examListHasError(true);
        examListErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      examListHasError(true);
      examListErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isExamListLoading(false);
    }
  }

  // ── 2. Exam Routine ──────────────────────────────────────────────────────
  // Expected JSON:
  // { "status":"success", "data": [ { "subject":"Math", "date":"15 Jul 2026",
  //   "day":"Tuesday", "start_time":"10:00 AM", "end_time":"12:00 PM",
  //   "venue":"Room 101" } ] }
  var isRoutineLoading = false.obs;
  var routineHasError = false.obs;
  var routineErrorMessage = ''.obs;
  var routine = <RoutineItem>[].obs;
  var routineExamName = ''.obs;

  Future<void> fetchRoutine(String examId, String examName) async {
    try {
      isRoutineLoading(true);
      routineHasError(false);
      routine.clear();
      routineExamName.value = examName;

      final uri = Uri.parse('$_baseUrl/student/exam-routine/$examId');
      final response =
      await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          routine.value = (decoded['data'] as List)
              .map((e) => RoutineItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          routineHasError(true);
          routineErrorMessage.value =
              decoded['message']?.toString() ?? 'Routine not available yet.';
        }
      } else {
        routineHasError(true);
        routineErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      routineHasError(true);
      routineErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isRoutineLoading(false);
    }
  }

  // ── 3. Admit Card PDF ────────────────────────────────────────────────────
  var isDownloadingAdmit = false.obs;

  Future<String?> downloadAdmitCard(String examId) async {
    try {
      isDownloadingAdmit(true);
      final uri = Uri.parse('$_baseUrl/student/admit-card/$examId/pdf');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/admit_card_$examId.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
      Get.snackbar('Error', 'Admit card not available (${response.statusCode}).');
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Could not download. Check your internet.');
      return null;
    } finally {
      isDownloadingAdmit(false);
    }
  }

  // ── 4. Exam Results ──────────────────────────────────────────────────────
  // Expected JSON:
  // { "status":"success", "data": { "exam_id":"5", "exam_name":"Half Yearly",
  //   "subjects": [ { "subject":"Math", "marks_obtained":"78", "full_marks":"100",
  //   "grade":"A", "status":"Pass" } ],
  //   "total_obtained":"385", "total_full":"500", "gpa":"4.50", "result":"Pass" } }
  var isResultLoading = false.obs;
  var resultHasError = false.obs;
  var resultErrorMessage = ''.obs;
  Rx<ExamResult?> examResult = Rx<ExamResult?>(null);

  Future<void> fetchResult(String examId) async {
    try {
      isResultLoading(true);
      resultHasError(false);
      examResult.value = null;

      final uri = Uri.parse('$_baseUrl/student/exam-result/$examId');
      final response =
      await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          examResult.value = ExamResult.fromJson(decoded['data']);
        } else {
          resultHasError(true);
          resultErrorMessage.value =
              decoded['message']?.toString() ?? 'Result not published yet.';
        }
      } else {
        resultHasError(true);
        resultErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      resultHasError(true);
      resultErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isResultLoading(false);
    }
  }

  // ── 5. Promotion status ──────────────────────────────────────────────────
  // Expected JSON:
  // { "status":"success", "data": { "is_promoted": true,
  //   "promoted_to_class":"Class IX", "promoted_to_section":"B",
  //   "session":"2026-2027", "remarks":"Well done!" } }
  var isPromotionLoading = false.obs;
  var promotionHasError = false.obs;
  var promotionErrorMessage = ''.obs;
  Rx<PromotionStatus?> promotion = Rx<PromotionStatus?>(null);

  Future<void> fetchPromotion() async {
    try {
      isPromotionLoading(true);
      promotionHasError(false);
      promotion.value = null;

      final uri = Uri.parse('$_baseUrl/student/promotion');
      final response =
      await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          promotion.value = PromotionStatus.fromJson(decoded['data']);
        } else {
          promotionHasError(true);
          promotionErrorMessage.value =
              decoded['message']?.toString() ?? 'Promotion result not available.';
        }
      } else {
        promotionHasError(true);
        promotionErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      promotionHasError(true);
      promotionErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isPromotionLoading(false);
    }
  }
}
