import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════════════════════
// TASK H — Attendance
// Powers two views:
//  1. Calendar view   — day-by-day status for a given month
//  2. Range report    — detailed report for a custom date range
// ════════════════════════════════════════════════════════════════════════════

// Possible status values returned by the ERP
enum AttendanceStatus { present, absent, leave, holiday, none }

class DayAttendance {
  final DateTime date;
  final AttendanceStatus status;
  final String note; // e.g. holiday name

  DayAttendance({
    required this.date,
    required this.status,
    this.note = '',
  });

  factory DayAttendance.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date']?.toString() ?? '';
    final statusStr = json['status']?.toString().toLowerCase() ?? '';

    return DayAttendance(
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      status: _parseStatus(statusStr),
      note: json['note']?.toString() ?? '',
    );
  }

  static AttendanceStatus _parseStatus(String s) {
    switch (s) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'leave':
        return AttendanceStatus.leave;
      case 'holiday':
      case 'festival':
        return AttendanceStatus.holiday;
      default:
        return AttendanceStatus.none;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// REPOSITORY (API Layer)
// ════════════════════════════════════════════════════════════════════════════

class AttendanceRepository {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _monthEndpoint = '/student/attendance/month';
  static const String _rangeEndpoint = '/student/attendance/range';

  final http.Client _client;
  AttendanceRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<http.Response> getMonthAttendance({
    required DateTime month,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$_monthEndpoint').replace(
      queryParameters: {
        'year': month.year.toString(),
        'month': month.month.toString().padLeft(2, '0'),
      },
    );
    return await _client.get(uri, headers: _buildHeaders(token)).timeout(const Duration(seconds: 15));
  }

  Future<http.Response> getRangeAttendance({
    required String from,
    required String to,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$_rangeEndpoint').replace(
      queryParameters: {'from': from, 'to': to},
    );
    return await _client.get(uri, headers: _buildHeaders(token)).timeout(const Duration(seconds: 15));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER (State Management Layer)
// ════════════════════════════════════════════════════════════════════════════

class AttendanceController extends GetxController {
  final AttendanceRepository _repository = AttendanceRepository();
  String? _authToken;

  void setAuthToken(String token) => _authToken = token;

  // ── Calendar (month) state ────────────────────────────────────────────────
  final isCalendarLoading = true.obs;
  final calendarHasError = false.obs;
  final calendarErrorMessage = ''.obs;

  // keyed by yyyy-MM-dd for O(1) lookup
  final calendarData = <String, DayAttendance>{}.obs;

  // currently displayed month (default: this month)
  final focusedMonth = DateTime.now().obs;

  // ── Range report state ────────────────────────────────────────────────────
  final isRangeLoading = false.obs;
  final rangeHasError = false.obs;
  final rangeErrorMessage = ''.obs;
  final rangeData = <DayAttendance>[].obs;

  final rangeFrom = ''.obs; // yyyy-MM-dd
  final rangeTo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMonthAttendance(DateTime.now());
  }

  // Helper to format date keys uniformly
  String _formatKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ────────────────────────────────────────────────────────────────────────
  // 1. MONTH VIEW — powers the calendar markers (Present/Absent/Leave/Holiday)
  // ────────────────────────────────────────────────────────────────────────
  //
  // Expected JSON:
  // { "status": "success", "data": [
  //     { "date": "2026-07-01", "status": "present", "note": "" },
  //     { "date": "2026-07-04", "status": "holiday", "note": "Eid-ul-Adha" },
  //     { "date": "2026-07-06", "status": "absent",  "note": "" }
  //   ]
  // }
  Future<void> fetchMonthAttendance(DateTime month) async {
    try {
      isCalendarLoading(true);
      calendarHasError(false);
      calendarData.clear();
      focusedMonth.value = month;

      final response = await _repository.getMonthAttendance(month: month, token: _authToken);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final map = <String, DayAttendance>{};
          for (final e in (decoded['data'] as List)) {
            final d = DayAttendance.fromJson(e as Map<String, dynamic>);
            map[_formatKey(d.date)] = d;
          }
          calendarData.value = map;
        } else {
          calendarHasError(true);
          calendarErrorMessage.value = decoded['message']?.toString() ?? 'No attendance data found.';
        }
      } else if (response.statusCode == 401) {
        calendarHasError(true);
        calendarErrorMessage.value = 'Session expired. Please log in again.';
      } else {
        calendarHasError(true);
        calendarErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      calendarHasError(true);
      calendarErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isCalendarLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 2. RANGE REPORT — detailed day-by-day list for a custom date range
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchRangeReport() async {
    if (rangeFrom.value.isEmpty || rangeTo.value.isEmpty) {
      Get.snackbar('Select dates', 'Please choose both a from and to date.');
      return;
    }
    try {
      isRangeLoading(true);
      rangeHasError(false);
      rangeData.clear();

      final response = await _repository.getRangeAttendance(
        from: rangeFrom.value,
        to: rangeTo.value,
        token: _authToken,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          rangeData.value = (decoded['data'] as List)
              .map((e) => DayAttendance.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          rangeHasError(true);
          rangeErrorMessage.value = decoded['message']?.toString() ?? 'No data for this range.';
        }
      } else {
        rangeHasError(true);
        rangeErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      rangeHasError(true);
      rangeErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isRangeLoading(false);
    }
  }

  // Helper — counts for a loaded month/range
  int countByStatus(List<DayAttendance> list, AttendanceStatus s) =>
      list.where((d) => d.status == s).length;

  // Convenience for calendar page — get status for a specific day
  AttendanceStatus statusForDay(DateTime day) {
    return calendarData[_formatKey(day)]?.status ?? AttendanceStatus.none;
  }

  String noteForDay(DateTime day) {
    return calendarData[_formatKey(day)]?.note ?? '';
  }
}