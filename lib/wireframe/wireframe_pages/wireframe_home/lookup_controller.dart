import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// =============================================================================
// MODELS
// =============================================================================

class SchoolClass {
  final String id;
  final String className; // Nursery, PG, Pre-KG, KG etc.
  final String shift;     // Day / Morning

  SchoolClass({
    required this.id,
    required this.className,
    required this.shift,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      shift: json['shift']?.toString() ?? '',
    );
  }

  String get displayLabel => shift.isNotEmpty ? "$className ($shift)" : className;
}

class SchoolSection {
  final String id;
  final String classId;
  final String sectionName; // A, B, C etc.
  final int capacity;

  SchoolSection({
    required this.id,
    required this.classId,
    required this.sectionName,
    required this.capacity,
  });

  factory SchoolSection.fromJson(Map<String, dynamic> json) {
    return SchoolSection(
      id: json['id']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      sectionName: json['section_name']?.toString() ?? '',
      capacity: int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
    );
  }

  String get displayLabel => sectionName;
}

class SchoolSubject {
  final String id;
  final String name;
  final String code;
  final String type; // Theory / Practical
  final bool isActive;

  SchoolSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.isActive,
  });

  factory SchoolSubject.fromJson(Map<String, dynamic> json) {
    return SchoolSubject(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isActive: json['status']?.toString().toLowerCase() != 'inactive',
    );
  }

  String get displayLabel => name;
}

class AcademicSession {
  final String id;
  final String sessionName; // e.g., "2025-2026"
  final bool isCurrent;

  AcademicSession({
    required this.id,
    required this.sessionName,
    required this.isCurrent,
  });

  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    final currentVal = json['is_current'];
    return AcademicSession(
      id: json['id']?.toString() ?? '',
      sessionName: json['session_name']?.toString() ?? '',
      isCurrent: currentVal == true || currentVal == 1 || currentVal?.toString() == '1',
    );
  }

  String get displayLabel => sessionName;
}

// =============================================================================
// CONTROLLER (Singleton Lifecycle Lookup Manager)
// =============================================================================

class LookupController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _classesEndpoint = '/lookup/classes';
  static const String _sectionsEndpoint = '/lookup/sections';
  static const String _subjectsEndpoint = '/lookup/subjects';
  static const String _sessionsEndpoint = '/lookup/academic-sessions';

  String? _authToken;

  // ── Reactive States ────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final subjects = <SchoolSubject>[].obs;
  final sessions = <AcademicSession>[].obs;

  // ── Global Dropdown Selections ─────────────────────────────────────────────
  final selectedClass = Rx<SchoolClass?>(null);
  final selectedSection = Rx<SchoolSection?>(null);
  final selectedSubject = Rx<SchoolSubject?>(null);
  final selectedSession = Rx<AcademicSession?>(null);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  @override
  void onInit() {
    super.onInit();
    fetchAllLookups();
  }

  void setAuthToken(String token) => _authToken = token;

  // ── Fetch All Lookups in Parallel (Optimized Performance) ──────────────────
  Future<void> fetchAllLookups() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage.value = '';

      // Parallel API calls using Future.wait
      final results = await Future.wait([
        _fetchClasses(),
        _fetchSections(),
        _fetchSubjects(),
        _fetchSessions(),
      ]);

      // If any of the internal fetchers return false
      if (results.any((success) => !success)) {
        hasError(true);
        errorMessage.value = 'Some reference data (classes/sections/subjects/sessions) could not be loaded.';
      }

      // Auto-set Active Session with firstWhere lambda
      if (selectedSession.value == null && sessions.isNotEmpty) {
        selectedSession.value = sessions.firstWhere(
              (s) => s.isCurrent,
          orElse: () => sessions.first,
        );
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshAllLookups() async => fetchAllLookups();

  // ── Core Internal Fetchers utilizing Clean Reducer Boilerplate ──────────────
  Future<bool> _fetchClasses() async => _performFetch(_classesEndpoint, (data) {
    classes.value = data.map((e) => SchoolClass.fromJson(e)).toList();
  });

  Future<bool> _fetchSections() async => _performFetch(_sectionsEndpoint, (data) {
    sections.value = data.map((e) => SchoolSection.fromJson(e)).toList();
  });

  Future<bool> _fetchSubjects() async => _performFetch(_subjectsEndpoint, (data) {
    subjects.value = data.map((e) => SchoolSubject.fromJson(e)).toList();
  });

  Future<bool> _fetchSessions() async => _performFetch(_sessionsEndpoint, (data) {
    sessions.value = data.map((e) => AcademicSession.fromJson(e)).toList();
  });

  // Helper boilerplate reducer for standard HTTP GET requests
  Future<bool> _performFetch(String endpoint, Function(List) onSuccess) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          onSuccess(decoded['data'] as List);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Dynamic Getters & Filter Actions ────────────────────────────────────────

  // ক্লাসের ভিত্তিতে সেকশন ফিল্টার করার জন্য রিয়্যাক্টিভ গেটার
  List<SchoolSection> sectionsForClass(String classId) {
    return sections.where((s) => s.classId == classId).toList();
  }

  // স্টুডেন্টের ক্লাস/সেকশন ভেদে গ্রুপ স্পেসিফিক সাবজেক্ট আনবার এক্সটার্নাল এপিআই
  Future<List<SchoolSubject>> fetchSubjectsForClassSection(String classId, String sectionId) async {
    try {
      final uri = Uri.parse('$_baseUrl$_subjectsEndpoint?class_id=$classId&section_id=$sectionId');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List rows = decoded['data'];
          return rows.map((e) => SchoolSubject.fromJson(e)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── Setters ────────────────────────────────────────────────────────────────
  void selectClass(SchoolClass? value) {
    selectedClass.value = value;
    selectedSection.value = null; // Reset section if class changes
  }

  void selectSection(SchoolSection? value) => selectedSection.value = value;
  void selectSubject(SchoolSubject? value) => selectedSubject.value = value;
  void selectSession(AcademicSession? value) => selectedSession.value = value;
}