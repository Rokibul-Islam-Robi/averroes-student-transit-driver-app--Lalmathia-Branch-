import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'attendance_controller.dart';
import 'page_hero_header.dart';

// ════════════════════════════════════════════════════════════════════════════
// H. Attendance — Calendar Page + Range Report Page
// ════════════════════════════════════════════════════════════════════════════

const Color _kPresent  = Color(0xFF4CAF50);
const Color _kAbsent   = Color(0xFFE53935);
const Color _kLeave    = Color(0xFFFFA726);
const Color _kHoliday  = Color(0xFF7B61FF);
const Color _kNone     = Color(0xFFE0E0E0);
const Color _kAccent   = Color(0xFF1E6FFF); // আপনার নতুন রয়্যাল ব্লু অ্যাকসেন্ট

// ── Calendar Page ─────────────────────────────────────────────────────────
class AttendanceCalendarPage extends StatelessWidget {
  const AttendanceCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController ctrl = Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB), // নতুন ব্যাকগ্রাউন্ড টোন
      body: Column(
        children: [
          // ── Themed Hero Header ─────────────────────────────────────────
          PageHeroHeader(
            theme: PageHeroTheme.attendance,
            title: 'Attendance',
            subtitle: 'Track your daily presence',
            onBack: () => Navigator.pop(context),
            actions: [
              TextButton(
                onPressed: () => Get.to(() => const AttendanceRangeReportPage()),
                child: const Text(
                  'Report',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Month Navigator Card ───────────────────────────────────────
          Obx(() {
            final month = ctrl.focusedMonth.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.black87),
                        onPressed: () {
                          final prev = DateTime(month.year, month.month - 1);
                          ctrl.fetchMonthAttendance(prev);
                        },
                      ),
                      Text(
                        _monthLabel(month),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.black87),
                        onPressed: () {
                          final next = DateTime(month.year, month.month + 1);
                          ctrl.fetchMonthAttendance(next);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // ── Legend ─────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: _kPresent, label: 'Present'),
                SizedBox(width: 12),
                _LegendDot(color: _kAbsent,  label: 'Absent'),
                SizedBox(width: 12),
                _LegendDot(color: _kLeave,   label: 'Leave'),
                SizedBox(width: 12),
                _LegendDot(color: _kHoliday, label: 'Holiday'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Calendar Content Card ──────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Obx(() {
                if (ctrl.isCalendarLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: _kAccent));
                }
                if (ctrl.calendarHasError.value) {
                  return _ErrorPanel(
                    message: ctrl.calendarErrorMessage.value,
                    onRetry: () => ctrl.fetchMonthAttendance(ctrl.focusedMonth.value),
                  );
                }
                return Column(
                  children: [
                    const SizedBox(height: 18),
                    Expanded(
                      child: _CalendarGrid(
                        ctrl: ctrl,
                        month: ctrl.focusedMonth.value,
                      ),
                    ),
                    // Summary Bottom Strip
                    Obx(() {
                      if (ctrl.calendarData.isEmpty) return const SizedBox.shrink();
                      final days = ctrl.calendarData.values.toList();
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          border: Border(
                            top: BorderSide(color: _kAccent.withValues(alpha: 0.08)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SummaryPill(
                                count: ctrl.countByStatus(days, AttendanceStatus.present),
                                label: 'Present',
                                color: _kPresent),
                            _SummaryPill(
                                count: ctrl.countByStatus(days, AttendanceStatus.absent),
                                label: 'Absent',
                                color: _kAbsent),
                            _SummaryPill(
                                count: ctrl.countByStatus(days, AttendanceStatus.leave),
                                label: 'Leave',
                                color: _kLeave),
                            _SummaryPill(
                                count: ctrl.countByStatus(days, AttendanceStatus.holiday),
                                label: 'Holiday',
                                color: _kHoliday),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ── Calendar Grid ────────────────────────────────────────────────────────
class _CalendarGrid extends StatelessWidget {
  final AttendanceController ctrl;
  final DateTime month;
  const _CalendarGrid({required this.ctrl, required this.month});

  @override
  Widget build(BuildContext context) {
    final firstDay     = DateTime(month.year, month.month, 1);
    final daysInMonth  = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
              child: Center(
                child: Text(d,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45)),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox.shrink();
                final day = DateTime(month.year, month.month, index - startWeekday + 1);
                final status = ctrl.statusForDay(day);
                final note   = ctrl.noteForDay(day);
                return GestureDetector(
                  onTap: note.isNotEmpty
                      ? () => Get.snackbar(
                    _statusLabel(status),
                    note,
                    duration: const Duration(seconds: 2),
                  )
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusColor(status).withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(status) == _kNone
                            ? Colors.black38
                            : _statusColor(status),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.present:  return _kPresent;
    case AttendanceStatus.absent:   return _kAbsent;
    case AttendanceStatus.leave:    return _kLeave;
    case AttendanceStatus.holiday:  return _kHoliday;
    default:                        return _kNone;
  }
}

String _statusLabel(AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.present:  return 'Present';
    case AttendanceStatus.absent:   return 'Absent';
    case AttendanceStatus.leave:    return 'Leave';
    case AttendanceStatus.holiday:  return 'Holiday';
    default:                        return '';
  }
}

// ── Range Report Page ─────────────────────────────────────────────────────
class AttendanceRangeReportPage extends StatelessWidget {
  const AttendanceRangeReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController ctrl = Get.find<AttendanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // Header
          PageHeroHeader(
            theme: PageHeroTheme.attendance,
            title: 'Attendance Report',
            subtitle: 'Detailed range view',
            onBack: () => Navigator.pop(context),
          ),

          // Date range picker strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: _DatePickerTile(label: 'From', obs: ctrl.rangeFrom)),
                    const SizedBox(width: 10),
                    Expanded(child: _DatePickerTile(label: 'To', obs: ctrl.rangeTo)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: ctrl.fetchRangeReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Go', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Result List
          Expanded(
            child: Obx(() {
              if (ctrl.isRangeLoading.value) {
                return const Center(child: CircularProgressIndicator(color: _kAccent));
              }
              if (ctrl.rangeHasError.value) {
                return _ErrorPanel(
                    message: ctrl.rangeErrorMessage.value,
                    onRetry: ctrl.fetchRangeReport);
              }
              if (ctrl.rangeData.isEmpty) {
                return const Center(
                  child: Text(
                    'Select a date range above and tap Go.',
                    style: TextStyle(color: Colors.black45),
                  ),
                );
              }

              final days = ctrl.rangeData;
              return Column(
                children: [
                  // Range Summary
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SummaryPill(
                            count: ctrl.countByStatus(days, AttendanceStatus.present),
                            label: 'Present', color: _kPresent),
                        _SummaryPill(
                            count: ctrl.countByStatus(days, AttendanceStatus.absent),
                            label: 'Absent', color: _kAbsent),
                        _SummaryPill(
                            count: ctrl.countByStatus(days, AttendanceStatus.leave),
                            label: 'Leave', color: _kLeave),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: days.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final d = days[i];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    color: _statusColor(d.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _formatDate(d.date),
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(d.status).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusLabel(d.status).isEmpty ? '—' : _statusLabel(d.status),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: _statusColor(d.status),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
}

// ── Shared UI Sub-components ──────────────────────────────────────────────
class _DatePickerTile extends StatelessWidget {
  final String label;
  final RxString obs;
  const _DatePickerTile({required this.label, required this.obs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          obs.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        }
      },
      child: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F6), // সুন্দর সফট গ্রে ব্যাকগ্রাউন্ড
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black45),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                obs.value.isEmpty ? label : obs.value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: obs.value.isEmpty ? Colors.black38 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black54)),
    ]);
  }
}

class _SummaryPill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _SummaryPill({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
    ]);
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(color: Color(0xFFFFEFEF), shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded, size: 28, color: _kAbsent),
        ),
        const SizedBox(height: 12),
        const Text('Something went wrong', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black45)),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Try again'),
        ),
      ]),
    );
  }
}