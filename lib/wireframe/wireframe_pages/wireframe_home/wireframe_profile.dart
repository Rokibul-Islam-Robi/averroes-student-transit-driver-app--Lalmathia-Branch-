import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_icons.dart';
import 'student_controller.dart';
import 'page_background.dart'; // আপনার কাস্টম ব্যাকগ্রাউন্ড ফাইল

class WireframeProfile extends StatefulWidget {
  const WireframeProfile({Key? key}) : super(key: key);

  @override
  State<WireframeProfile> createState() => _WireframeProfileState();
}

class _WireframeProfileState extends State<WireframeProfile> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  final studentCtrl = Get.put(StudentController());

  // Contact number editing-এর জন্য TextEditingController
  final TextEditingController _contactController = TextEditingController();
  bool _isEditingContact = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'My_profile'.tr, // ২য় কোডের টাইটেল অনুযায়ী লোকাল ট্র্যান্সলেশন যুক্ত করা হয়েছে
        actions: [
          Obx(() => AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isEditingContact ? 1.0 : 0.0,
            child: AbsorbPointer(
              absorbing: !_isEditingContact,
              child: InkWell(
                onTap: () => _saveContact(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: WireframeColor.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      studentCtrl.isSavingContact.value
                          ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: WireframeColor.appcolor,
                        ),
                      )
                          : Icon(Icons.check,
                          size: 18, color: WireframeColor.appcolor),
                      const SizedBox(width: 4),
                      Text(
                        "Done".tr,
                        style: sansproBold.copyWith(
                            fontSize: 13, color: WireframeColor.appcolor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
      body: PageBackground(
        category: PageCategory.profile,
        child: Obx(() {
          if (studentCtrl.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: WireframeColor.white));
          }
          if (studentCtrl.hasError.value) {
            return _ErrorState(
              message: studentCtrl.errorMessage.value,
              onRetry: studentCtrl.refreshProfile,
              height: height,
            );
          }

          final profile = studentCtrl.profile.value;
          if (profile == null) {
            return Center(
                child: Text("No profile data found".tr,
                    style: const TextStyle(color: WireframeColor.white)));
          }

          // প্রথমবার আসল ডেটা ফিল্ডে সেট করা
          if (!_isEditingContact && _contactController.text != profile.contactNumber) {
            _contactController.text = profile.contactNumber;
          }

          return RefreshIndicator(
            onRefresh: studentCtrl.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // AppBar এর নিচের স্পেসিং নিশ্চিত করা
                  SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

                  Container(
                    decoration: BoxDecoration(
                        color: themedata.isdark
                            ? WireframeColor.black
                            : WireframeColor.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 26, vertical: height / 36),
                      child: Column(
                        children: [
                          // ── Header card ──
                          _HeaderCard(
                            profile: profile,
                            studentCtrl: studentCtrl,
                            height: height,
                            width: width,
                          ),
                          SizedBox(height: height / 36),

                          // ── Rows of locked fields ──
                          Row(
                            children: [
                              _lockedField(label: "Adhar_No", value: profile.aadharNo),
                              const Spacer(),
                              _lockedField(label: "Academic_Year", value: profile.academicYear),
                            ],
                          ),
                          SizedBox(height: height / 96),

                          Row(
                            children: [
                              _lockedField(label: "Class", value: profile.className),
                              const Spacer(),
                              _lockedField(label: "Section", value: profile.section),
                            ],
                          ),
                          SizedBox(height: height / 96),

                          Row(
                            children: [
                              _lockedField(label: "Roll_No", value: profile.rollNo),
                              const Spacer(),
                              _lockedField(label: "Student_ID", value: profile.studentId),
                            ],
                          ),
                          SizedBox(height: height / 96),

                          Row(
                            children: [
                              _lockedField(label: "Admission_Class", value: profile.admissionClass),
                              const Spacer(),
                              _lockedField(label: "Old_Admission_No", value: profile.oldAdmissionNo),
                            ],
                          ),
                          SizedBox(height: height / 96),

                          // ── Blood Group — Profile section-এ নতুন যোগ করা হলো ──
                          _lockedFieldFullWidth(label: "Blood_Group", value: profile.bloodGroup),
                          SizedBox(height: height / 96),

                          Row(
                            children: [
                              _lockedField(label: "Date_of_Admission", value: profile.dateOfAdmission),
                              const Spacer(),
                              _lockedField(label: "Date_of_Birth", value: profile.dateOfBirth),
                            ],
                          ),
                          SizedBox(height: height / 96),

                          // ── Contact Number (Editable) ──
                          _EditableContactField(
                            controller: _contactController,
                            isDark: themedata.isdark,
                            height: height,
                            onTapStart: () => setState(() => _isEditingContact = true),
                          ),
                          SizedBox(height: height / 96),

                          _lockedFieldFullWidth(label: "Parent_Mail_ID", value: profile.parentMailId),
                          SizedBox(height: height / 96),

                          _lockedFieldFullWidth(label: "Mother_Name", value: profile.motherName),
                          SizedBox(height: height / 96),

                          _lockedFieldFullWidth(label: "Father_Name", value: profile.fatherName),
                          SizedBox(height: height / 96),

                          _lockedFieldFullWidth(label: "Parmanent_Add", value: profile.permanentAddress),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Contact number save করার logic ──
  Future<void> _saveContact() async {
    final newContact = _contactController.text.trim();
    if (newContact.isEmpty) return;

    final success = await studentCtrl.updateContactNumber(newContact);
    if (mounted) {
      setState(() => _isEditingContact = false);
      // কীবোর্ড ক্লোজ করার জন্য
      FocusScope.of(context).unfocus();
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed_to_update_contact_number".tr)),
      );
    }
  }

  Widget _lockedField({required String label, required String value}) {
    return SizedBox(
      width: width / 2.3,
      child: _LockedFieldContent(label: label, value: value, height: height),
    );
  }

  Widget _lockedFieldFullWidth({required String label, required String value}) {
    return _LockedFieldContent(label: label, value: value, height: height, fullWidth: true);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Header card উইজেট
// ════════════════════════════════════════════════════════════════════════════
class _HeaderCard extends StatelessWidget {
  final StudentProfile profile;
  final StudentController studentCtrl;
  final double height;
  final double width;

  const _HeaderCard({
    required this.profile,
    required this.studentCtrl,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: WireframeColor.appcolor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 66),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => InkWell(
              onTap: studentCtrl.isUploadingPhoto.value
                  ? null
                  : () => studentCtrl.pickAndUploadPhoto(),
              child: Container(
                width: height / 10,
                height: height / 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: WireframeColor.textgray,
                  image: profile.profilePhotoUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(profile.profilePhotoUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: studentCtrl.isUploadingPhoto.value
                    ? const Center(
                  child: CircularProgressIndicator(
                      color: WireframeColor.white, strokeWidth: 2),
                )
                    : (profile.profilePhotoUrl.isEmpty
                    ? Icon(Icons.person, color: WireframeColor.white, size: height / 20)
                    : null),
              ),
            )),
            SizedBox(width: width / 36),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.studentName, style: sansproBold.copyWith(fontSize: 20)),
                  SizedBox(height: height / 96),
                  Text(
                    "Class ${profile.className}-${profile.section} | Roll no: ${profile.rollNo}",
                    style: sansproRegular.copyWith(fontSize: 16, color: WireframeColor.textgray), // ২য় কোড অনুযায়ী fontSize 16 করা হয়েছে
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: studentCtrl.isUploadingPhoto.value
                  ? null
                  : () => studentCtrl.pickAndUploadPhoto(),
              child: Icon(Icons.camera_alt_outlined, size: height / 30, color: WireframeColor.appgray),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Locked Field উইজেট
// ════════════════════════════════════════════════════════════════════════════
class _LockedFieldContent extends StatelessWidget {
  final String label;
  final String value;
  final double height;
  final bool fullWidth;

  const _LockedFieldContent({
    required this.label,
    required this.value,
    required this.height,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: height / 100),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: WireframeColor.bggray)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value.isEmpty ? "—" : value,
                          style: sansproRegular.copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Image.asset(WireframePngimage.iclock, height: height / 36),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Editable Contact Field উইজেট
// ════════════════════════════════════════════════════════════════════════════
class _EditableContactField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final double height;
  final VoidCallback onTapStart;

  const _EditableContactField({
    required this.controller,
    required this.isDark,
    required this.height,
    required this.onTapStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact_Number".tr,
            style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
          ),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            onTap: onTapStart,
            style: sansproRegular.copyWith(
                fontSize: 16,
                color: isDark ? WireframeColor.white : WireframeColor.black),
            cursorColor: isDark ? WireframeColor.white : WireframeColor.black,
            decoration: InputDecoration(
              hintText: "01700000000".tr,
              suffixIcon: Icon(Icons.edit, size: height / 40, color: WireframeColor.appcolor),
              hintStyle: sansproRegular.copyWith(
                  fontSize: 16,
                  color: isDark ? WireframeColor.white : WireframeColor.black),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: WireframeColor.bggray),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: WireframeColor.appcolor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Error State উইজেট
// ════════════════════════════════════════════════════════════════════════════
class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final double height;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: height / 16, color: WireframeColor.white),
            SizedBox(height: height / 56),
            Text(
              message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.white),
            ),
            SizedBox(height: height / 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => onRetry(),
              child: Text("Retry".tr, style: sansproSemibold.copyWith(color: WireframeColor.appcolor)),
            ),
          ],
        ),
      ),
    );
  }
}