import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'fees_controller.dart';
import 'bkash_payment_page.dart';
import 'page_background.dart';

class FeesInvoiceDetailPage extends StatelessWidget {
  final FeeInvoice invoice;
  const FeesInvoiceDetailPage({Key? key, required this.invoice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(
        title: 'Invoice Detail',
      ),
      backgroundColor: WireframeColor.appcolor,
      body: PageBackground(
        category: PageCategory.fees,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffF5F6FC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: w / 18,
                    vertical: h / 36,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: h / 56),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF3CD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffF59E0B).withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pending_actions, color: Color(0xffD97706), size: 20),
                            SizedBox(width: 8),
                            Text('Payment Pending', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xffD97706))),
                          ],
                        ),
                      ),
                      SizedBox(height: h / 36),
                      _buildInfoCard(context, [
                        {'label': 'Invoice ID', 'value': invoice.invoiceId},
                        {'label': 'Fee Head', 'value': invoice.feeHead},
                        {'label': 'Month', 'value': invoice.month},
                        {'label': 'Due Date', 'value': invoice.dueDate},
                      ]),
                      SizedBox(height: h / 46),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: WireframeColor.appcolor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: w / 18, vertical: h / 46),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount Due', style: sansproRegular.copyWith(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                                Text('৳ ${invoice.amount.toStringAsFixed(0)}', style: sansproBold.copyWith(fontSize: 36, color: Colors.white)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.account_balance_wallet_outlined, color: Colors.white54, size: 44),
                          ],
                        ),
                      ),
                      SizedBox(height: h / 36),
                      Text('Pay Via', style: sansproSemibold.copyWith(fontSize: 15, color: WireframeColor.black)),
                      SizedBox(height: h / 60),
                      Row(
                        children: [
                          _PayMethodChip(
                            label: 'bKash',
                            color: const Color(0xffE2136E),
                            icon: Icons.phone_android,
                            onTap: () => _showPayDialog(context, 'bKash', invoice.amount),
                          ),
                          SizedBox(width: w / 46),
                          _PayMethodChip(
                            label: 'Nagad',
                            color: const Color(0xffF4792B),
                            icon: Icons.phone_android,
                            onTap: () => _showPayDialog(context, 'Nagad', invoice.amount),
                          ),
                          SizedBox(width: w / 46),
                          _PayMethodChip(
                            label: 'Card',
                            color: const Color(0xff1A56DB),
                            icon: Icons.credit_card,
                            onTap: () => _showPayDialog(context, 'Card/SSL', invoice.amount),
                          ),
                          SizedBox(width: w / 46),
                          _PayMethodChip(
                            label: 'QR Pay',
                            color: const Color(0xff059669),
                            icon: Icons.qr_code_2_rounded,
                            onTap: () => _showQrPayDialog(context, invoice),
                          ),
                        ],
                      ),
                      SizedBox(height: h / 36),
                      InkWell(
                        onTap: () => _showPayDialog(context, 'Online', invoice.amount),
                        child: Container(
                          width: double.infinity,
                          height: h / 14,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: WireframeColor.appcolor.withValues(alpha: 0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Text('PAY NOW', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: h / 56),
                      Container(
                        padding: EdgeInsets.all(h / 80),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: WireframeColor.appcolor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: WireframeColor.appcolor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'After successful payment, your receipt will appear in Payment History within a few minutes.',
                                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.appgray),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInfoCard(BuildContext context, List<Map<String, String>> rows) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invoice Details', style: sansproSemibold.copyWith(fontSize: 14, color: WireframeColor.black)),
          SizedBox(height: h / 80),
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: h / 100),
                  child: Row(
                    children: [
                      Text(row['label']!, style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray)),
                      const Spacer(),
                      Text(row['value']!, style: sansproSemibold.copyWith(fontSize: 13, color: WireframeColor.black)),
                    ],
                  ),
                ),
                if (i < rows.length - 1) const Divider(color: WireframeColor.bggray, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showQrPayDialog(BuildContext context, FeeInvoice invoice) {
    // ── QR পেমেন্টের জন্য payload — invoice/amount encode করা bKash-style
    // merchant string। ব্যাকএন্ড রেডি হলে এটাকে dynamic merchant QR string
    // দিয়ে replace করে দিলেই হবে, UI অংশ পরিবর্তনের দরকার নেই।
    final qrData =
        'averroesint-pay://invoice?invoice_id=${invoice.invoiceId}&amount=${invoice.amount.toStringAsFixed(0)}&currency=BDT';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scan to Pay', style: sansproSemibold.copyWith(fontSize: 17, color: WireframeColor.black)),
              const SizedBox(height: 6),
              Text(
                'Open your bKash / Nagad / mobile banking app and scan this QR',
                textAlign: TextAlign.center,
                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WireframeColor.bggray),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                  gapless: true,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: WireframeColor.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: WireframeColor.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '৳ ${invoice.amount.toStringAsFixed(0)}',
                style: sansproBold.copyWith(fontSize: 22, color: WireframeColor.appcolor),
              ),
              Text(
                'Invoice: ${invoice.invoiceId}',
                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WireframeColor.appcolor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Close', style: sansproSemibold.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPayDialog(BuildContext context, String method, double amount) {
    final FeesController feesCtrl = Get.find<FeesController>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Payment', style: sansproSemibold.copyWith(fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Method: $method', style: sansproRegular.copyWith(fontSize: 14)),
            const SizedBox(height: 6),
            Text('Amount: ৳ ${amount.toStringAsFixed(0)}', style: sansproSemibold.copyWith(fontSize: 16, color: WireframeColor.appcolor)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: sansproRegular.copyWith(color: WireframeColor.textgray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (method == 'bKash') {
                // ── এখানে মিসিং ভেরিয়েবলগুলো সেফ মেথড বা ডামি দিয়ে রিপ্লেস করে দেওয়া হলো ──
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BkashPaymentPage(
                      bkashUrl: "https://averroesint.com/averroes_school_erp/api/student/payment/initiate", // ডাইনামিক ইনিশিয়েট লিংক ব্যাকএন্ড এপিআই অনুযায়ী দিয়ে দিও
                      paymentId: "BKASH_PAY_${invoice.invoiceId}",
                      invoiceId: invoice.invoiceId,
                      amount: invoice.amount,
                      feesCtrl: feesCtrl,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Redirecting to $method gateway...'), backgroundColor: WireframeColor.appcolor),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WireframeColor.appcolor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Proceed', style: sansproSemibold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PayMethodChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _PayMethodChip({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: sansproSemibold.copyWith(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}