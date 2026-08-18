import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════════════════════
// MODEL CLASSES
// ════════════════════════════════════════════════════════════════════════════

class SyllabusItem {
  final String id;
  final String title;
  final String subject;
  final String term;
  final String type;
  final String session;
  final bool hasAttachment;

  SyllabusItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.term,
    required this.type,
    required this.session,
    required this.hasAttachment,
  });

  factory SyllabusItem.fromJson(Map<String, dynamic> json) {
    return SyllabusItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      hasAttachment: json['has_attachment'] == true ||
          json['has_attachment']?.toString() == '1',
    );
  }
}

class SyllabusDetail {
  final String id;
  final String title;
  final String details;
  final String subject;
  final String term;
  final String type;
  final String session;
  final String attachmentUrl;
  final String attachmentName;

  SyllabusDetail({
    required this.id,
    required this.title,
    required this.details,
    required this.subject,
    required this.term,
    required this.type,
    required this.session,
    required this.attachmentUrl,
    required this.attachmentName,
  });

  factory SyllabusDetail.fromJson(Map<String, dynamic> json) {
    return SyllabusDetail(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      attachmentUrl: json['attachment_url']?.toString() ?? '',
      attachmentName: json['attachment_name']?.toString() ?? '',
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER (OPTIMIZED)
// ════════════════════════════════════════════════════════════════════════════

class SyllabusController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _listEndpoint = '/student/syllabus';
  static const String _detailEndpoint = '/student/syllabus';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // State Variables
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var items = <SyllabusItem>[].obs;

  var isDetailLoading = false.obs;
  var detailHasError = false.obs;
  var detailErrorMessage = ''.obs;
  var detail = Rxn<SyllabusDetail>(); // Rxn ব্যবহার করা হয়েছে নাল-সেফটির জন্য

  // Filter Variables
  var selectedSession = ''.obs;
  var selectedSubject = ''.obs;
  var selectedTerm = ''.obs;
  var selectedType = ''.obs;
  var keyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSyllabusList();

    // Debounce worker: ইউজার সার্চ কি-ওয়ার্ড টাইপ করার ৫০০ মিলি-সেকেন্ড পর অটো এপিআই কল হবে
    debounce(keyword, (_) => fetchSyllabusList(), time: const Duration(milliseconds: 500));

    // Workers: এই ফিল্টারগুলো চেঞ্জ হওয়া মাত্রই অটোমেটিক লিস্ট রিফ্রেশ হবে
    everAll([selectedSession, selectedSubject, selectedTerm, selectedType], (_) {
      fetchSyllabusList();
    });
  }

  // Syllabus List Fetch
  Future<void> fetchSyllabusList() async {
    try {
      isLoading(true);
      hasError(false);

      final queryParams = <String, String>{
        if (selectedSession.value.isNotEmpty) 'session': selectedSession.value,
        if (selectedSubject.value.isNotEmpty) 'subject': selectedSubject.value,
        if (selectedTerm.value.isNotEmpty) 'term': selectedTerm.value,
        if (selectedType.value.isNotEmpty) 'type': selectedType.value,
        if (keyword.value.isNotEmpty) 'keyword': keyword.value,
      };

      final uri = Uri.parse('$_baseUrl$_listEndpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          items.value = (decoded['data'] as List<dynamic>)
              .map((e) => SyllabusItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _setError(decoded['message']?.toString() ?? 'No syllabus entries found.');
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
  Future<void> fetchSyllabusDetail(String id) async {
    try {
      isDetailLoading(true);
      detailHasError(false);
      detail.value = null;

      final uri = Uri.parse('$_baseUrl$_detailEndpoint/$id');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          detail.value = SyllabusDetail.fromJson(decoded['data']);
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

  // Clear Filters
  void clearFilters() {
    // একবারে সব ভ্যালু আপডেট করার জন্য Workers অফ রেখে রিসেট করা ভালো, তবে এখানে নরমাল রিসেটও কাজ করবে
    selectedSession.value = '';
    selectedSubject.value = '';
    selectedTerm.value = '';
    selectedType.value = '';
    keyword.value = '';
    fetchSyllabusList();
  }

  // Helper Methods for Error Handling
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