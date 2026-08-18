import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODEL
// ════════════════════════════════════════════════════════════════════════════
class StudentProfile {
  final String studentName;
  final String studentId;
  final String className;
  final String section;
  final String rollNo;
  final String academicYear;
  final String profilePhotoUrl;
  final String contactNumber;
  final String bloodGroup;

  final String aadharNo;
  final String admissionClass;
  final String oldAdmissionNo;
  final String dateOfAdmission;
  final String dateOfBirth;

  final String parentMailId;
  final String motherName;
  final String fatherName;
  final String permanentAddress;

  StudentProfile({
    required this.studentName,
    required this.studentId,
    required this.className,
    required this.section,
    required this.rollNo,
    required this.academicYear,
    required this.profilePhotoUrl,
    required this.contactNumber,
    required this.bloodGroup,
    required this.aadharNo,
    required this.admissionClass,
    required this.oldAdmissionNo,
    required this.dateOfAdmission,
    required this.dateOfBirth,
    required this.parentMailId,
    required this.motherName,
    required this.fatherName,
    required this.permanentAddress,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentName: json['student_name']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      academicYear: json['academic_year']?.toString() ?? '',
      profilePhotoUrl: json['profile_photo_url']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      aadharNo: json['aadhar_no']?.toString() ?? '',
      admissionClass: json['admission_class']?.toString() ?? '',
      oldAdmissionNo: json['old_admission_no']?.toString() ?? '',
      dateOfAdmission: json['date_of_admission']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      parentMailId: json['parent_mail_id']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      permanentAddress: json['permanent_address']?.toString() ?? '',
    );
  }

  StudentProfile copyWith({
    String? contactNumber,
    String? profilePhotoUrl,
  }) {
    return StudentProfile(
      studentName: studentName,
      studentId: studentId,
      className: className,
      section: section,
      rollNo: rollNo,
      academicYear: academicYear,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      contactNumber: contactNumber ?? this.contactNumber,
      bloodGroup: bloodGroup,
      aadharNo: aadharNo,
      admissionClass: admissionClass,
      oldAdmissionNo: oldAdmissionNo,
      dateOfAdmission: dateOfAdmission,
      dateOfBirth: dateOfBirth,
      parentMailId: parentMailId,
      motherName: motherName,
      fatherName: fatherName,
      permanentAddress: permanentAddress,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
class StudentController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _profileEndpoint = '/student/profile';
  static const String _updateContactEndpoint = '/student/profile/contact';
  static const String _uploadPhotoEndpoint = '/student/profile/photo';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  Rx<StudentProfile?> profile = Rx<StudentProfile?>(null);

  var isSavingContact = false.obs;
  var isUploadingPhoto = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      hasError(false);

      final uri = Uri.parse('$_baseUrl$_profileEndpoint');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          profile.value = StudentProfile.fromJson(decoded['data']);
        } else {
          _showError(decoded['message']?.toString() ?? 'Failed to load profile.');
        }
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please log in again.');
      } else {
        _showError('Server error (${response.statusCode}).');
      }
    } catch (e) {
      _showError('Could not connect to server. Please check your internet connection.');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshProfile() async => fetchProfile();

  Future<bool> updateContactNumber(String newContact) async {
    if (newContact.trim().isEmpty) return false;

    try {
      isSavingContact(true);

      final uri = Uri.parse('$_baseUrl$_updateContactEndpoint');
      final response = await http
          .put(uri, headers: _headers, body: json.encode({'contact_number': newContact}))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          if (profile.value != null) {
            profile.value = profile.value!.copyWith(contactNumber: newContact);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isSavingContact(false);
    }
  }

  Future<bool> pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return false;

      return await _uploadPhoto(File(picked.path));
    } catch (e) {
      return false;
    }
  }

  Future<bool> _uploadPhoto(File imageFile) async {
    try {
      isUploadingPhoto(true);

      final uri = Uri.parse('$_baseUrl$_uploadPhotoEndpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final newPhotoUrl = decoded['data']['profile_photo_url']?.toString() ?? '';

          if (profile.value != null && newPhotoUrl.isNotEmpty) {
            profile.value = profile.value!.copyWith(profilePhotoUrl: newPhotoUrl);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isUploadingPhoto(false);
    }
  }

  void _showError(String message) {
    hasError(true);
    errorMessage.value = message;
  }
}