import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'notification_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════════════════════
//
// নোট: Notification-এর নিজের model (NotificationModel) আলাদা ফাইলে আছে
// (notification_model.dart) — এটা প্রজেক্টে আগে থেকেই বানানো ছিল, তাই
// controller-টা সেটার সাথেই মিলিয়ে লেখা হয়েছে। এখানে শুধু Dashboard
// Summary-এর model রাখা হয়েছে, কারণ এটার জন্য আলাদা কোনো ফাইল ছিল না।

// ── Dashboard Summary — home screen-এর জন্য একটাই combined API call ────────
// Attendance %, pending assignment count, upcoming exam, next holiday —
// সব একসাথে আনা হয়, যাতে app চালু হওয়ার সময় আলাদা আলাদা call না করতে হয়।
// (Fees Due-এর নিজের আলাদা FeesController আগে থেকেই আছে এবং সেটা বেশি
// বিস্তারিত — তাই dashboard card-এ এখনো FeesController-ই ব্যবহার হবে।)
class DashboardSummary {
  final double attendancePercentage;
  final int pendingAssignmentsCount;
  final String upcomingExamName;
  final String upcomingExamDate;
  final String nextHolidayName;
  final String nextHolidayDate;

  DashboardSummary({
    required this.attendancePercentage,
    required this.pendingAssignmentsCount,
    required this.upcomingExamName,
    required this.upcomingExamDate,
    required this.nextHolidayName,
    required this.nextHolidayDate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      attendancePercentage:
      double.tryParse(json['attendance_percentage'].toString()) ?? 0.0,
      pendingAssignmentsCount:
      int.tryParse(json['pending_assignments_count'].toString()) ?? 0,
      upcomingExamName: json['upcoming_exam_name']?.toString() ?? '',
      upcomingExamDate: json['upcoming_exam_date']?.toString() ?? '',
      nextHolidayName: json['next_holiday_name']?.toString() ?? '',
      nextHolidayDate: json['next_holiday_date']?.toString() ?? '',
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
//
// ⚠️ এই module-এ পুশ নোটিফিকেশন (Firebase/FCM) নেই — শুধু in-app notification
// list আর dashboard summary আছে, যেমনটা ঠিক করা হয়েছিল।
class NotificationController extends GetxController {
  static const String _baseUrl =
      'https://averroesint.com/averroes_school_erp/api';
  static const String _summaryEndpoint = '/dashboard/summary';
  static const String _notificationsEndpoint = '/notifications';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ── Dashboard Summary state ─────────────────────────────────────────────
  var isSummaryLoading = true.obs;
  var summaryHasError = false.obs;
  Rx<DashboardSummary?> summary = Rx<DashboardSummary?>(null);

  // ── Notifications list state ────────────────────────────────────────────
  // নাম গুলো notification_page.dart-এর সাথে exact মিলিয়ে রাখা হয়েছে:
  // isLoading (isNotificationsLoading না), notifications (List<NotificationModel>)
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var notifications = <NotificationModel>[].obs;

  // ── Unread count — bell আইকনের পাশে ছোট red badge দেখানোর জন্য ──────────
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
    fetchNotifications();
  }

  // ────────────────────────────────────────────────────────────────────────
  // DASHBOARD SUMMARY
  // ────────────────────────────────────────────────────────────────────────
  //
  // প্রত্যাশিত JSON response shape:
  // {
  //   "status": "success",
  //   "data": {
  //     "attendance_percentage": 80.39,
  //     "pending_assignments_count": 3,
  //     "upcoming_exam_name": "Half Yearly Examination",
  //     "upcoming_exam_date": "2026-07-15",
  //     "next_holiday_name": "Eid-ul-Adha Vacation",
  //     "next_holiday_date": "2026-07-20"
  //   }
  // }
  Future<void> fetchDashboardSummary() async {
    try {
      isSummaryLoading(true);
      summaryHasError(false);

      final uri = Uri.parse('$_baseUrl$_summaryEndpoint');
      final response =
      await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          summary.value = DashboardSummary.fromJson(decoded['data']);
        } else {
          summaryHasError(true);
        }
      } else {
        summaryHasError(true);
      }
    } catch (e) {
      summaryHasError(true);
    } finally {
      isSummaryLoading(false);
    }
  }

  Future<void> refreshDashboardSummary() async => fetchDashboardSummary();

  // ────────────────────────────────────────────────────────────────────────
  // NOTIFICATIONS LIST
  // ────────────────────────────────────────────────────────────────────────
  //
  // প্রত্যাশিত JSON response shape (NotificationModel.fromJson-এর সাথে মিলিয়ে):
  // {
  //   "status": "success",
  //   "data": [
  //     {
  //       "id": "101",
  //       "title": "New Homework Posted",
  //       "message": "Mathematics homework has been posted for Class IX-A.",
  //       "type": "homework",
  //       "time": "2 hours ago",
  //       "is_read": false
  //     },
  //     {
  //       "id": "102",
  //       "title": "Fee Reminder",
  //       "message": "Your June tuition fee is due on 30th June.",
  //       "type": "fee",
  //       "time": "1 day ago",
  //       "is_read": true
  //     }
  //   ]
  // }
  //
  // ⚠️ লক্ষ্য করো: ERP team "time" ফিল্ডে already-formatted relative time
  // ("2 hours ago") পাঠাবে, অথবা raw timestamp পাঠালে app-side এ format
  // করতে হবে — এই মুহূর্তে NotificationModel raw string হিসেবেই রাখে,
  // ERP team-কে এই ব্যাপারে confirm করে নিও।
  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      hasError(false);

      final uri = Uri.parse('$_baseUrl$_notificationsEndpoint');
      final response =
      await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List rows = decoded['data'];
          notifications.value =
              rows.map((e) => NotificationModel.fromJson(e)).toList();
        } else {
          hasError(true);
          errorMessage.value =
              decoded['message']?.toString() ?? 'Failed to load notifications.';
        }
      } else if (response.statusCode == 401) {
        hasError(true);
        errorMessage.value = 'Session expired. Please log in again.';
      } else {
        hasError(true);
        errorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      hasError(true);
      errorMessage.value =
      'Could not connect to server. Please check your internet connection.';
    } finally {
      isLoading(false);
    }
  }

  // notification_page.dart-এ RefreshIndicator.onRefresh: nCtrl.refresh
  // এভাবে কল হয়। GetxController-এর নিজস্ব refresh() member override
  // হচ্ছে বলেই analyzer @override চাচ্ছিল — সেটা যোগ করা হলো।
  @override
  Future<void> refresh() async {
    await fetchNotifications();
    await fetchDashboardSummary();
  }

  // ── নির্দিষ্ট একটা notification read হিসেবে mark করা ────────────────────
  // optimistic update: আগে local list-এ সাথে সাথে read দেখিয়ে দেওয়া হয়,
  // backend call ব্যাকগ্রাউন্ডে হয় — UI instant মনে হবে।
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || notifications[index].isRead) return;

    notifications[index].isRead = true;
    notifications.refresh();

    try {
      final uri = Uri.parse('$_baseUrl$_notificationsEndpoint/$notificationId/read');
      await http.put(uri, headers: _headers).timeout(const Duration(seconds: 10));
    } catch (e) {
      // network ব্যর্থ হলেও local UI read-ই থাকবে; পরের fetchNotifications()
      // এ backend-এর real status আবার sync হয়ে যাবে।
    }
  }

  // ── সব notification একসাথে read করার জন্য ("Mark all read" বাটনের জন্য) ──
  Future<void> markAllAsRead() async {
    for (final n in notifications.where((n) => !n.isRead).toList()) {
      await markAsRead(n.id);
    }
  }
}
