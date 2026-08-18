import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'fees_controller.dart';
import 'fees_invoice_detail_page.dart';
import 'fees_receipt_page.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart'; // কাস্টম ব্যাকগ্রাউন্ডের জন্য

class FeesOverviewPage extends StatefulWidget {
  const FeesOverviewPage({Key? key}) : super(key: key);

  @override
  State<FeesOverviewPage> createState() => _FeesOverviewPageState();
}

class _FeesOverviewPageState extends State<FeesOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // GetX controller — এটা দিয়ে সব data access করব
  final FeesController feesCtrl = Get.put(FeesController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PageAppBar(
        title: 'Fees & Payments',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => feesCtrl.refreshFees(),
          ),
        ],
      ),
      backgroundColor: WireframeColor.appcolor,
      body: PageBackground(
        category: PageCategory.fees,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // ── Summary Card ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Obx(() => feesCtrl.isLoading.value
                            ? const SizedBox()
                            : Padding(
                          padding: EdgeInsets.symmetric(horizontal: w / 26),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withAlpha(77)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: w / 18, vertical: h / 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Outstanding Dues',
                                  style: sansproRegular.copyWith(
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(217)),
                                ),
                                SizedBox(height: h / 120),
                                Text(
                                  feesCtrl.formatAmount(feesCtrl.totalDue.value),
                                  style: sansproBold.copyWith(
                                      fontSize: 38, color: Colors.white),
                                ),
                                SizedBox(height: h / 80),
                                Container(
                                  height: 1,
                                  color: Colors.white.withAlpha(64),
                                ),
                                SizedBox(height: h / 80),
                                Row(
                                  children: [
                                    _summaryChip(
                                      Icons.pending_actions,
                                      '${feesCtrl.pendingInvoices.length} Pending',
                                      const Color(0xffFFD700),
                                    ),
                                    SizedBox(width: w / 26),
                                    _summaryChip(
                                      Icons.check_circle_outline,
                                      '${feesCtrl.paidInvoices.length} Paid',
                                      const Color(0xff4CD964),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                        SizedBox(height: h / 36),
                      ],
                    ),
                  ),

                  // ── Tab Bar ──────────────────────────────────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        labelStyle: sansproSemibold.copyWith(fontSize: 14),
                        unselectedLabelStyle: sansproRegular.copyWith(fontSize: 14),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withAlpha(153),
                        tabs: const [
                          Tab(text: '  📋  Dues & Invoices  '),
                          Tab(text: '  ✅  Payment History  '),
                        ],
                      ),
                      color: WireframeColor.appcolor,
                    ),
                  ),
                ],

                // ── Tab Body ────────────────────────────────────────────────────────
                body: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffF5F6FC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DuesTab(feesCtrl: feesCtrl),
                      _HistoryTab(feesCtrl: feesCtrl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: sansproRegular.copyWith(
              fontSize: 13, color: Colors.white.withAlpha(230)),
        ),
      ],
    );
  }
}

// ── Tab 1: Dues & Invoices ────────────────────────────────────────────────────
class _DuesTab extends StatelessWidget {
  final FeesController feesCtrl;
  const _DuesTab({required this.feesCtrl});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      if (feesCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: WireframeColor.appcolor),
        );
      }

      if (feesCtrl.hasError.value) {
        return _ErrorWidget(
          message: feesCtrl.errorMessage.value,
          onRetry: feesCtrl.refreshFees,
        );
      }

      if (feesCtrl.pendingInvoices.isEmpty) {
        return const _EmptyWidget(
          icon: Icons.check_circle_outline,
          message: 'No pending dues!\nAll fees are cleared.',
          iconColor: Color(0xff4CD964),
        );
      }

      return RefreshIndicator(
        color: WireframeColor.appcolor,
        onRefresh: feesCtrl.refreshFees,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: w / 26, vertical: h / 46),
          itemCount: feesCtrl.pendingInvoices.length,
          itemBuilder: (context, index) {
            final inv = feesCtrl.pendingInvoices[index];
            return _DueInvoiceCard(
              invoice: inv,
              onTap: () async {
                // ইউজার ডিটেইল পেজে যাওয়ার পর পেমেন্ট শেষ করে ব্যাক আসলে অটো-রিফ্রেশ হবে
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeesInvoiceDetailPage(invoice: inv),
                  ),
                );
                feesCtrl.refreshFees(); // ব্যাক আসার সাথে সাথে কন্ট্রোলার আপডেট করবে
              },
            );
          },
        ),
      );
    });
  }
}

// ── Tab 2: Payment History ────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final FeesController feesCtrl;
  const _HistoryTab({required this.feesCtrl});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      if (feesCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: WireframeColor.appcolor),
        );
      }

      if (feesCtrl.paidInvoices.isEmpty) {
        return const _EmptyWidget(
          icon: Icons.receipt_long_outlined,
          message: 'No payment history found.',
          iconColor: WireframeColor.textgray,
        );
      }

      return RefreshIndicator(
        color: WireframeColor.appcolor,
        onRefresh: feesCtrl.refreshFees,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: w / 26, vertical: h / 46),
          itemCount: feesCtrl.paidInvoices.length,
          itemBuilder: (context, index) {
            final inv = feesCtrl.paidInvoices[index];
            return _PaidReceiptCard(
              invoice: inv,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeesReceiptPage(invoice: inv),
                  ),
                );
                feesCtrl.refreshFees();
              },
            );
          },
        ),
      );
    });
  }
}

// ── Due Invoice Card ──────────────────────────────────────────────────────────
class _DueInvoiceCard extends StatelessWidget {
  final FeeInvoice invoice;
  final VoidCallback onTap;
  const _DueInvoiceCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: h / 56),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 60),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: Color(0xffF57C00), size: 22),
                      ),
                      SizedBox(width: w / 26),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.feeHead,
                              style: sansproSemibold.copyWith(
                                  fontSize: 15, color: WireframeColor.black),
                            ),
                            Text(
                              invoice.month,
                              style: sansproRegular.copyWith(
                                  fontSize: 12, color: WireframeColor.textgray),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳ ${invoice.amount.toStringAsFixed(0)}',
                            style: sansproBold.copyWith(
                                fontSize: 18, color: WireframeColor.appcolor),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xffFFF3CD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PENDING',
                              style: sansproSemibold.copyWith(
                                  fontSize: 10, color: const Color(0xffD97706)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: h / 80),
                  const Divider(color: WireframeColor.bggray, height: 1),
                  SizedBox(height: h / 80),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: WireframeColor.textgray),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${invoice.dueDate}',
                        style: sansproRegular.copyWith(
                            fontSize: 12, color: WireframeColor.textgray),
                      ),
                      const Spacer(),
                      Text(
                        'View & Pay →',
                        style: sansproSemibold.copyWith(
                            fontSize: 12, color: WireframeColor.appcolor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Paid Receipt Card ─────────────────────────────────────────────────────────
class _PaidReceiptCard extends StatelessWidget {
  final FeeInvoice invoice;
  final VoidCallback onTap;
  const _PaidReceiptCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: h / 56),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 60),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Color(0xff2E7D32), size: 22),
                  ),
                  SizedBox(width: w / 26),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.feeHead,
                          style: sansproSemibold.copyWith(
                              fontSize: 15, color: WireframeColor.black),
                        ),
                        Text(
                          invoice.month,
                          style: sansproRegular.copyWith(
                              fontSize: 12, color: WireframeColor.textgray),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳ ${invoice.amount.toStringAsFixed(0)}',
                        style: sansproBold.copyWith(
                            fontSize: 18, color: const Color(0xff2E7D32)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PAID',
                          style: sansproSemibold.copyWith(
                              fontSize: 10, color: const Color(0xff2E7D32)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: h / 80),
              const Divider(color: WireframeColor.bggray, height: 1),
              SizedBox(height: h / 80),
              Row(
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 13, color: WireframeColor.textgray),
                  const SizedBox(width: 4),
                  Text(
                    invoice.receiptNo ?? '',
                    style: sansproRegular.copyWith(
                        fontSize: 12, color: WireframeColor.textgray),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.payment_outlined,
                      size: 13, color: WireframeColor.textgray),
                  const SizedBox(width: 4),
                  Text(
                    invoice.payMode ?? '',
                    style: sansproRegular.copyWith(
                        fontSize: 12, color: WireframeColor.textgray),
                  ),
                  const Spacer(),
                  Text(
                    'View Receipt →',
                    style: sansproSemibold.copyWith(
                        fontSize: 12, color: WireframeColor.appcolor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────
class _EmptyWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color iconColor;
  const _EmptyWidget(
      {required this.icon, required this.message, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
                fontSize: 16, color: WireframeColor.textgray),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(
                  fontSize: 15, color: WireframeColor.textgray)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WireframeColor.appcolor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SliverPersistentHeader Delegate ───────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;
  const _TabBarDelegate(this.tabBar, {required this.color});

  @override
  Widget build(context, shrinkOffset, overlapsContent) =>
      Container(color: color, child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}