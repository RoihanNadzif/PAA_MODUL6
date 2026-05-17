import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modul7/config/api_config.dart';
import 'package:modul7/models/payment_model.dart';
import 'package:modul7/services/auth_service.dart';

class PaymentService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Ambil semua pembayaran
  static Future<List<PaymentModel>> getPayments({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}',
    ).replace(queryParameters: queryParams);

    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final List<dynamic> paymentsJson = data['payments'] ?? [];
      return paymentsJson.map((j) => PaymentModel.fromJson(j)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data pembayaran');
    }
  }

  static Future<PaymentModel> getPaymentById(String id) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}/$id',
    );
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      throw Exception(body['message'] ?? 'Pembayaran tidak ditemukan');
    }
  }
  static Future<PaymentModel> createPayment({
    required String bookingId,
    required String method,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? transactionId,
    String? notes,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}',
    );
    final headers = await _authHeaders();

    final payload = <String, dynamic>{
      'bookingId': bookingId,
      'method': method,
    };
    if (bankName != null && bankName.isNotEmpty) payload['bankName'] = bankName;
    if (accountNumber != null && accountNumber.isNotEmpty) {
      payload['accountNumber'] = accountNumber;
    }
    if (accountName != null && accountName.isNotEmpty) {
      payload['accountName'] = accountName;
    }
    if (transactionId != null && transactionId.isNotEmpty) {
      payload['transactionId'] = transactionId;
    }
    if (notes != null && notes.isNotEmpty) payload['notes'] = notes;

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );
    final body = json.decode(response.body);

    if (response.statusCode == 201) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat pembayaran');
    }
  }
  static Future<void> verifyPayment(String id, {
    required String status,
    String? notes,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}/$id/verify',
    );
    final headers = await _authHeaders();

    final payload = <String, dynamic>{
      'status': status,
    };
    if (notes != null && notes.isNotEmpty) payload['notes'] = notes;

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal memverifikasi pembayaran');
    }
  }
}
