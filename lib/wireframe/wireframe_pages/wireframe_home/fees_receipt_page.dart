import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'fees_controller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart'; // কাস্টম ব্যাকগ্রাউন্ডের জন্য

class FeesReceiptPage extends StatelessWidget {
  final FeeInvoice invoice;
  const FeesReceiptPage({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // গ্লোবাল বা কমন অ্যাপ বার প্রোপার্টি ব্যবহার করা হয়েছে
      appBar: const PageAppBar(
        title: 'Fee Receipt',
      ),
      backgroundColor: WireframeColor.appcolor,
      body: PageBackground(
        category: PageCategory.fees,
        child: Column(
          children: [
            // অ্যাপ বারের নিচের সেফ এরিয়া স্পেসিং কনসিস্টেন্সি বজায় রাখার জন্য
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

            // মূল হোয়াইট বডি বা কন্টেইনার
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
                      horizontal: w / 18, vertical: h / 36),
                  child: Column(
                    children: [
                      // ── Success Badge ──────────────────────────────────────
                      Container(
                        padding: EdgeInsets.symmetric(vertical: h / 40),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F5E9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff4CD964)
                                        .withAlpha(77),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.check,
                                  color: Color(0xff2E7D32), size: 44),
                            ),
                            SizedBox(height: h / 56),
                            Text(
                              'Payment Successful',
                              style: sansproSemibold.copyWith(
                                  fontSize: 20, color: const Color(0xff2E7D32)),
                            ),
                            SizedBox(height: h / 120),
                            Text(
                              'Paid on ${invoice.paidDate ?? ''}',
                              style: sansproRegular.copyWith(
                                  fontSize: 13, color: WireframeColor.textgray),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h / 46),

                      // ── Receipt Card ───────────────────────────────────────
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 16,
                                offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Receipt header
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: w / 18, vertical: h / 46),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    WireframeColor.appcolor,
                                    WireframeColor.lightappcolor,
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('RECEIPT',
                                          style: sansproSemibold.copyWith(
                                              fontSize: 12,
                                              color: Colors.white54,
                                              letterSpacing: 2)),
                                      Text(invoice.receiptNo ?? '',
                                          style: sansproBold.copyWith(
                                              fontSize: 22, color: Colors.white)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '৳ ${invoice.amount.toStringAsFixed(0)}',
                                    style: sansproBold.copyWith(
                                        fontSize: 30, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),

                            // Receipt rows
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: w / 22, vertical: h / 56),
                              child: Column(
                                children: [
                                  _receiptRow('Fee Head', invoice.feeHead),
                                  _divider(),
                                  _receiptRow('Month', invoice.month),
                                  _divider(),
                                  _receiptRow('Payment Date', invoice.paidDate ?? ''),
                                  _divider(),
                                  _receiptRow('Pay Mode', invoice.payMode ?? ''),
                                  _divider(),
                                  _receiptRow('Invoice ID', invoice.invoiceId),
                                ],
                              ),
                            ),

                            // Bottom dashed line (receipt style)
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: w / 22),
                              child: Row(
                                children: List.generate(
                                  30,
                                      (i) => Expanded(
                                    child: Container(
                                      height: 1.5,
                                      color: i.isEven
                                          ? WireframeColor.bggray
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: w / 22, vertical: h / 60),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.school_outlined,
                                      size: 16, color: WireframeColor.textgray),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Averroes International School Lalmatia',
                                    style: sansproRegular.copyWith(
                                        fontSize: 11,
                                        color: WireframeColor.textgray),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h / 36),

                      // ── Download Button ────────────────────────────────────
                      InkWell(
                        onTap: () {
                          // TODO: PDF download API call
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt download coming soon...'),
                              backgroundColor: WireframeColor.appcolor,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: h / 14,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: WireframeColor.appcolor, width: 2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download_outlined,
                                  color: WireframeColor.appcolor, size: 22),
                              const SizedBox(width: 10),
                              Text('Download Receipt',
                                  style: sansproSemibold.copyWith(
                                      fontSize: 15,
                                      color: WireframeColor.appcolor)),
                            ],
                          ),
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

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label,
              style: sansproRegular.copyWith(
                  fontSize: 13, color: WireframeColor.textgray)),
          const Spacer(),
          Text(value,
              style: sansproSemibold.copyWith(
                  fontSize: 13, color: WireframeColor.black)),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(color: WireframeColor.bggray, height: 1);
}