import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════════════════════
// MODEL CLASSES
// ════════════════════════════════════════════════════════════════════════════

class HomeworkItem {
  final String id;
  final String title;
  final String subject;
  final String className;
  final String section;
  final String dueDate;
  final String type;
  final bool hasAttachment;

  HomeworkItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    required this.section,
    required this.dueDate,
    required this.type,
    required this.hasAttachment,
  });

  factory HomeworkItem.fromJson(Map<String, dynamic> json) {
    return HomeworkItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      className: json['class']?.toString() ?? json['class_name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      hasAttachment: json['has_attachment'] == true ||
          json['has_attachment']?.toString() == '1',
    );
  }
}

class HomeworkAttachment {
  final String fileName;
  final String fileType;
  final String fileUrl;

  HomeworkAttachment({
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
  });

  factory HomeworkAttachment.fromJson(Map<String, dynamic> json) {
    return HomeworkAttachment(
      fileName: json['file_name']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
    );
  }
}

class HomeworkDetail {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String className;
  final String section;
  final String type;
  final String assignDate;
  final String dueDate;
  final List<HomeworkAttachment> attachments;

  HomeworkDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className,
    required this.section,
    required this.type,
    required this.assignDate,
    required this.dueDate,
    required this.attachments,
  });

  factory HomeworkDetail.fromJson(Map<String, dynamic> json) {
    return HomeworkDetail(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      className: json['class']?.toString() ?? json['class_name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      assignDate: json['assign_date']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => HomeworkAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════

class HomeworkController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _listEndpoint = '/student/homework';
  static const String _detailEndpoint = '/student/homework';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // List State
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var items = <HomeworkItem>[].obs;

  // Detail State
  var isDetailLoading = false.obs;
  var detailHasError = false.obs;
  var detailErrorMessage = ''.obs;
  var detail = Rxn<HomeworkDetail>();

  // Filter State
  var keyword = ''.obs;
  var selectedType = ''.obs;
  var selectedSession = ''.obs;
  var selectedClass = ''.obs;
  var selectedSection = ''.obs;
  var selectedSubject = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // ইউজার সার্চ কি-ওয়ার্ড টাইপ করার ৫০০ মিলি-সেকেন্ড পর অটো এপিআই কল হবে
    debounce(keyword, (_) => fetchHomeworkList(), time: const Duration(milliseconds: 500));

    // এই ফিল্টারগুলো চেঞ্জ হওয়া মাত্রই অটোমেটিক লিস্ট রিফ্রেশ হবে
    everAll([
      selectedType,
      selectedSession,
      selectedClass,
      selectedSection,
      selectedSubject,
    ], (_) => fetchHomeworkList());
  }

  // List Fetch
  Future<void> fetchHomeworkList() async {
    try {
      isLoading(true);
      hasError(false);

      final queryParams = <String, String>{
        if (selectedType.value.isNotEmpty) 'type': selectedType.value,
        if (selectedSession.value.isNotEmpty) 'session': selectedSession.value,
        if (selectedClass.value.isNotEmpty) 'class': selectedClass.value,
        if (selectedSection.value.isNotEmpty) 'section': selectedSection.value,
        if (selectedSubject.value.isNotEmpty) 'subject': selectedSubject.value,
        if (keyword.value.isNotEmpty) 'keyword': keyword.value,
      };

      final uri = Uri.parse('$_baseUrl$_listEndpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          items.value = (decoded['data'] as List<dynamic>)
              .map((e) => HomeworkItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _setError(decoded['message']?.toString() ?? 'No homework or classwork found.');
        }
      } else if (response.statusCode == 401) {
        _setError('Session expired. Please log in again.');
      } else {
        _setError('Server error (${response.statusCode}).');
      }
    } catch (e) {
      _setError('Please check your internet connection.');
    } finally {
      isLoading(false);
    }
  }

  // Detail Fetch
  Future<void> fetchHomeworkDetail(String id) async {
    try {
      isDetailLoading(true);
      detailHasError(false);
      detail.value = null;

      final uri = Uri.parse('$_baseUrl$_detailEndpoint/$id');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          detail.value = HomeworkDetail.fromJson(decoded['data']);
        } else {
          _setDetailError(decoded['message']?.toString() ?? 'Could not load details.');
        }
      } else {
        _setDetailError('Server error (${response.statusCode}).');
      }
    } catch (e) {
      _setDetailError('Please check your internet connection.');
    } finally {
      isDetailLoading(false);
    }
  }

  // Resolve a downloadable/openable URL for an attachment
  String? resolveAttachmentUrl(HomeworkAttachment attachment) {
    if (attachment.fileUrl.isEmpty) return null;
    if (attachment.fileUrl.startsWith('http://') || attachment.fileUrl.startsWith('https://')) {
      return attachment.fileUrl;
    }
    return '$_baseUrl/${attachment.fileUrl}';
  }

  // Clear Filters
  void clearFilters() {
    keyword.value = '';
    selectedType.value = '';
    selectedSession.value = '';
    selectedClass.value = '';
    selectedSection.value = '';
    selectedSubject.value = '';
    fetchHomeworkList();
  }

  // Called by UI after manually changing a filter value
  void applyFiltersAndReload() {
    fetchHomeworkList();
  }

  void _setError(String msg) {
    hasError(true);
    errorMessage.value = msg;
    items.clear();
  }

  void _setDetailError(String msg) {
    detailHasError(true);
    detailErrorMessage.value = msg;
  }
}
