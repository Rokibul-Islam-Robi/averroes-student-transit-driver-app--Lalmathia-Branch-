import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODEL — FeeInvoice Model
// ════════════════════════════════════════════════════════════════════════════
class FeeInvoice {
  final String invoiceId;
  final String feeHead; // e.g., "Tuition Fee", "Transport Fee"
  final String month;
  final String dueDate;
  final double amount;
  final bool isPaid;
  final String? paidDate;
  final String? receiptNo;
  final String? payMode;

  FeeInvoice({
    required this.invoiceId,
    required this.feeHead,
    required this.month,
    required this.dueDate,
    required this.amount,
    required this.isPaid,
    this.paidDate,
    this.receiptNo,
    this.payMode,
  });

  factory FeeInvoice.fromJson(Map<String, dynamic> json) {
    return FeeInvoice(
      invoiceId: json['invoice_id']?.toString() ?? '',
      feeHead: json['fee_head']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      isPaid: json['is_paid'] == true || json['is_paid'] == 1 || json['is_paid'] == '1',
      paidDate: json['paid_date']?.toString(),
      receiptNo: json['receipt_no']?.toString(),
      payMode: json['pay_mode']?.toString(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — FeesController using GetX State Management
// ════════════════════════════════════════════════════════════════════════════
class FeesController extends GetxController {
  // ── Base API Configuration ────────────────────────────────────────────────
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _feesEndpoint = '/student/fees-dues';
  static const String _invoiceDetailEndpoint = '/student/invoice';
  static const String _invoicePdfEndpoint = '/student/invoice';
  static const String _paymentHistoryEndpoint = '/student/payments';
  static const String _initiatePaymentEndpoint = '/student/payment/initiate';

  // ── Reactive States ───────────────────────────────────────────────────────
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var pendingInvoices = <FeeInvoice>[].obs;
  var paidInvoices = <FeeInvoice>[].obs;
  var totalDue = 0.0.obs;
  var currency = 'BDT'.obs;
  var studentName = 'Student'.obs;
  var studentClass = ''.obs;

  // Invoice Detail States
  var isInvoiceDetailLoading = false.obs;
  var invoiceDetailHasError = false.obs;
  var invoiceDetailErrorMessage = ''.obs;
  Rx<FeeInvoice?> invoiceDetail = Rx<FeeInvoice?>(null);

  // PDF Download State
  var isDownloadingInvoicePdf = false.obs;

  // Payment History States
  var isPaymentHistoryLoading = true.obs;
  var paymentHistoryHasError = false.obs;
  var paymentHistoryErrorMessage = ''.obs;
  var paymentHistory = <FeeInvoice>[].obs;
  var paymentFilterSession = ''.obs;
  var paymentFilterMonth = ''.obs;

  // Online Payment State
  var isInitiatingPayment = false.obs;

  // Authentication Token
  String? _authToken;

  @override
  void onInit() {
    super.onInit();
    fetchFeesData();
  }

  // ── Helper Get Headers ────────────────────────────────────────────────────
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ── Set Auth Token ────────────────────────────────────────────────────────
  void setAuthToken(String token) {
    _authToken = token;
  }

  // ── Fetch Main Fees Dashboard Data ────────────────────────────────────────
  Future<void> fetchFeesData() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final uri = Uri.parse('$_baseUrl$_feesEndpoint');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'];

          studentName.value = data['student_name']?.toString() ?? 'Student';
          studentClass.value = data['student_class']?.toString() ?? '';
          currency.value = data['currency']?.toString() ?? 'BDT';
          totalDue.value = double.tryParse(data['total_due_amount'].toString()) ?? 0.0;

          final List pendingRaw = data['pending_invoices'] ?? [];
          final List paidRaw = data['paid_invoices'] ?? [];

          pendingInvoices.value = pendingRaw.map((e) => FeeInvoice.fromJson(e)).toList();
          paidInvoices.value = paidRaw.map((e) => FeeInvoice.fromJson(e)).toList();
        } else {
          hasError(true);
          errorMessage.value = decoded['message']?.toString() ?? 'Failed to load fees data.';
        }
      } else if (response.statusCode == 401) {
        hasError(true);
        errorMessage.value = 'Session expired. Please log in again.';
      } else {
        hasError(true);
        errorMessage.value = 'Server error (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isLoading(false);
    }
  }

  // ── Public Refresh Method (Avoids GetxController name conflict) ───────────
  Future<void> refreshFees() async {
    await fetchFeesData();
  }

  // ── Format Amount to Currency Style (e.g., ৳ 4,500) ───────────────────────
  String formatAmount(double amount) {
    final symbol = currency.value == 'BDT' ? '৳' : currency.value;
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$symbol $formatted';
  }

  // ── Fetch Single Invoice Detail ───────────────────────────────────────────
  Future<void> fetchInvoiceDetail(String invoiceId) async {
    try {
      isInvoiceDetailLoading(true);
      invoiceDetailHasError(false);
      invoiceDetail.value = null;

      final uri = Uri.parse('$_baseUrl$_invoiceDetailEndpoint/$invoiceId');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          invoiceDetail.value = FeeInvoice.fromJson(decoded['data']);
        } else {
          invoiceDetailHasError(true);
          invoiceDetailErrorMessage.value = decoded['message']?.toString() ?? 'Could not load invoice.';
        }
      } else {
        invoiceDetailHasError(true);
        invoiceDetailErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      invoiceDetailHasError(true);
      invoiceDetailErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isInvoiceDetailLoading(false);
    }
  }

  // ── Download Invoice PDF ──────────────────────────────────────────────────
  Future<String?> downloadInvoicePdf(String invoiceId) async {
    try {
      isDownloadingInvoicePdf(true);

      final uri = Uri.parse('$_baseUrl$_invoicePdfEndpoint/$invoiceId/pdf');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        Get.snackbar('Error', 'PDF download failed (${response.statusCode}).');
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_$invoiceId.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) {
      Get.snackbar('Error', 'Could not download invoice. Check your internet.');
      return null;
    } finally {
      isDownloadingInvoicePdf(false);
    }
  }

  // ── Fetch Payment History ─────────────────────────────────────────────────
  Future<void> fetchPaymentHistory() async {
    try {
      isPaymentHistoryLoading(true);
      paymentHistoryHasError(false);

      final queryParams = <String, String>{
        if (paymentFilterSession.value.isNotEmpty) 'session': paymentFilterSession.value,
        if (paymentFilterMonth.value.isNotEmpty) 'month': paymentFilterMonth.value,
      };

      final uri = Uri.parse('$_baseUrl$_paymentHistoryEndpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          paymentHistory.value = (decoded['data'] as List).map((e) => FeeInvoice.fromJson(e)).toList();
        } else {
          paymentHistoryHasError(true);
          paymentHistoryErrorMessage.value = decoded['message']?.toString() ?? 'No payment history found.';
        }
      } else {
        paymentHistoryHasError(true);
        paymentHistoryErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      paymentHistoryHasError(true);
      paymentHistoryErrorMessage.value = 'Please check your internet connection.';
    } finally {
      isPaymentHistoryLoading(false);
    }
  }

  // ── Initiate Online Payment (SSLCommerz / bKash) ──────────────────────────
  Future<String?> initiateOnlinePayment({
    required String invoiceId,
    required String method,
  }) async {
    try {
      isInitiatingPayment(true);

      final uri = Uri.parse('$_baseUrl$_initiatePaymentEndpoint');
      final response = await http
          .post(
        uri,
        headers: _headers,
        body: json.encode({'invoice_id': invoiceId, 'method': method}),
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          return decoded['data']['checkout_url']?.toString();
        }
        Get.snackbar('Payment', decoded['message']?.toString() ?? 'Could not start payment.');
        return null;
      }
      Get.snackbar('Error', 'Server error (${response.statusCode}).');
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Could not start payment. Check your internet.');
      return null;
    } finally {
      isInitiatingPayment(false);
    }
  }

  // ── Verify Payment Status (Execute Payment complete হওয়ার পর) ─────────────
  // bKash callback আসার পর backend নিজে Execute Payment call করে,
  // আমরা GET করে জিজ্ঞেস করি "এই paymentID-টার status কী?"
  //
  // প্রত্যাশিত JSON:
  // {
  //   "status": "success",
  //   "data": {
  //     "payment_id": "TR0011xxxxx",
  //     "transaction_status": "Completed",
  //     "trx_id": "BKxxxxxxx",
  //     "amount": 4500,
  //     "paid_at": "2026-07-04T10:30:00Z"
  //   }
  // }
  Future<bool> verifyPayment(String paymentId) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/student/payment/status/$paymentId');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' &&
            decoded['data'] != null) {
          final txStatus =
              decoded['data']['transaction_status']?.toString() ?? '';
          return txStatus.toLowerCase() == 'completed';
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}