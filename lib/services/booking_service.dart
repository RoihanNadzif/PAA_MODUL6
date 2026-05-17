import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modul7/config/api_config.dart';
import 'package:modul7/models/booking_model.dart';
import 'package:modul7/services/auth_service.dart';

class BookingService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<BookingModel>> getBookings({
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
      '${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}',
    ).replace(queryParameters: queryParams);

    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final List<dynamic> bookingsJson = data['bookings'] ?? [];
      return bookingsJson.map((j) => BookingModel.fromJson(j)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data booking');
    }
  }

  static Future<BookingModel> getBookingById(String id) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$id',
    );
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Booking tidak ditemukan');
    }
  }

  static Future<BookingModel> createBooking({
    required String carId,
    required String startDate,
    required String endDate,
    required String pickupLocation,
    required String returnLocation,
    String? notes,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}',
    );
    final headers = await _authHeaders();

    final payload = <String, dynamic>{
      'car': carId,
      'startDate': startDate,
      'endDate': endDate,
      'pickupLocation': pickupLocation,
      'returnLocation': returnLocation,
    };
    if (notes != null && notes.isNotEmpty) payload['notes'] = notes;

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );
    final body = json.decode(response.body);

    if (response.statusCode == 201) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat pemesanan');
    }
  }

  static Future<void> cancelBooking(String id, {String? reason}) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$id/cancel',
    );
    final headers = await _authHeaders();

    final payload = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) payload['reason'] = reason;

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal membatalkan pemesanan');
    }
  }

  static Future<void> confirmBooking(String id) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$id/confirm',
    );
    final headers = await _authHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode({}),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal mengkonfirmasi pemesanan');
    }
  }

  static Future<void> completeBooking(String id) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$id/complete',
    );
    final headers = await _authHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode({}),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal menyelesaikan pemesanan');
    }
  }
}
