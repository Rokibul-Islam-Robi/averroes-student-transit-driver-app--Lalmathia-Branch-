import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'syllabus_controller.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// Class Syllabus — List + Detail Page
// Modern background: teal/emerald gradient (study plan / curriculum theme)
// ════════════════════════════════════════════════════════════════════════════
const Color _kAccent = Color(0xFF00BFA5);

class SyllabusListPage extends StatelessWidget {
  const SyllabusListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SyllabusController ctrl = Get.put(SyllabusController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: PageAppBar(
        title: 'Class Syllabus',
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off_outlined, color: Colors.white),
            onPressed: ctrl.clearFilters,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PageBackground(
        category: PageCategory.syllabus,
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top + 8),

            // ── Search box on gradient (With Accent Shadow from 1st Code) ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.black45),
                    hintText: 'Search by title or details',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (v) {
                    ctrl.keyword.value = v.trim();
                    ctrl.fetchSyllabusList();
                  },
                ),
              ),
            ),

            // ── List card container (With Curved Top Border) ───────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(color: _kAccent));
                  }
                  if (ctrl.hasError.value) {
                    return _ErrorState(
                      message: ctrl.errorMessage.value,
                      onRetry: ctrl.fetchSyllabusList,
                    );
                  }
                  if (ctrl.items.isEmpty) {
                    return const _EmptyState();
                  }
                  return RefreshIndicator(
                    color: _kAccent,
                    onRefresh: ctrl.fetchSyllabusList,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: ctrl.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = ctrl.items[i];
                        return _SyllabusCard(item: item);
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyllabusCard extends StatelessWidget {
  final SyllabusItem item;
  const _SyllabusCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => SyllabusDetailPage(id: item.id)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_outlined,
                    color: _kAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.5),
                    ),
                    const SizedBox(height: 4),
                    Text(item.subject,
                        style: const TextStyle(
                            fontSize: 12.5, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _tag(item.term, _kAccent),
                        _tag(item.type, Colors.black45),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.hasAttachment)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.attach_file,
                      size: 17, color: Colors.black38),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ── Detail Page (With Premium Slivers & Custom Background) ─────────────────
class SyllabusDetailPage extends StatefulWidget {
  final String id;
  const SyllabusDetailPage({super.key, required this.id});

  @override
  State<SyllabusDetailPage> createState() => _SyllabusDetailPageState();
}

class _SyllabusDetailPageState extends State<SyllabusDetailPage> {
  final SyllabusController ctrl = Get.find<SyllabusController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchSyllabusDetail(widget.id);
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open the attachment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: const PageAppBar(title: 'Syllabus Details'),
      body: PageBackground(
        category: PageCategory.syllabus,
        headerHeight: 0.20,
        child: Obx(() {
          if (ctrl.isDetailLoading.value) {
            return Column(children: [
              SizedBox(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top),
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(color: _kAccent))),
            ]);
          }
          if (ctrl.detailHasError.value) {
            return Center(child: Text(ctrl.detailErrorMessage.value));
          }
          final d = ctrl.detail.value;
          if (d == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                    height: kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        12),
              ),
              // Header info on gradient (White text configuration from 1st Code)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(spacing: 8, children: [
                        _chip(d.term, Colors.white70),
                        _chip(d.type, Colors.white54),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                        d.title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Subject: ${d.subject}   •   Session: ${d.session}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              // White card body with details and attachment
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _kAccent.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Details',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(
                                d.details.isEmpty
                                    ? 'No details provided.'
                                    : d.details,
                                style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        if (d.attachmentUrl.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _openAttachment(d.attachmentUrl),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _kAccent.withValues(alpha: 0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: _kAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.insert_drive_file_outlined,
                                          color: _kAccent,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        d.attachmentName.isEmpty
                                            ? 'Attachment'
                                            : d.attachmentName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5),
                                      ),
                                    ),
                                    const Icon(Icons.download_outlined,
                                        color: Colors.black45, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Shared States ───────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: Color(0xFFE6F8F5), shape: BoxShape.circle),
          child: const Icon(Icons.menu_book_outlined,
              size: 32, color: Colors.black38),
        ),
        const SizedBox(height: 14),
        const Text('No syllabus entries',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        const Text('Nothing matches this filter yet.',
            style: TextStyle(fontSize: 13, color: Colors.black45)),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: Color(0xFFFFEFEF), shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded,
              size: 30, color: Color(0xFFE53935)),
        ),
        const SizedBox(height: 14),
        const Text('Something went wrong',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black45)),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Try again'),
        ),
      ]),
    );
  }
}