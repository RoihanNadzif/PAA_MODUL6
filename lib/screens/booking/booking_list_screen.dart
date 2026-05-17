import 'package:flutter/material.dart';
import 'package:modul7/models/booking_model.dart';
import 'package:modul7/services/booking_service.dart';
import 'package:modul7/services/auth_service.dart';
import 'package:modul7/widgets/loading_indicator.dart';
import 'package:modul7/screens/booking/payment_form_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});
  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}
class _BookingListScreenState extends State<BookingListScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String _error = '';
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _role = role ?? 'user');
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final list = await BookingService.getBookings(limit: 50);
      if (mounted) setState(() => _bookings = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(BookingModel b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pemesanan'),
        content: Text('Batalkan pemesanan ${b.bookingCode ?? ''}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Ya, Batalkan')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await BookingService.cancelBooking(b.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemesanan dibatalkan'), backgroundColor: Colors.green));
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    }
  }

  Future<void> _confirmBooking(BookingModel b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pemesanan'),
        content: Text('Konfirmasi pemesanan ${b.bookingCode ?? ''}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Konfirmasi')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await BookingService.confirmBooking(b.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemesanan dikonfirmasi'), backgroundColor: Colors.green));
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    }
  }

  Future<void> _completeBooking(BookingModel b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan Pemesanan'),
        content: Text('Selesaikan pemesanan ${b.bookingCode ?? ''}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Selesaikan')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await BookingService.completeBooking(b.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemesanan diselesaikan'), backgroundColor: Colors.green));
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed': return Colors.blue;
      case 'active': return Colors.green;
      case 'completed': return Colors.teal;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending': return 'Menunggu';
      case 'confirmed': return 'Dikonfirmasi';
      case 'active': return 'Aktif';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return s;
    }
  }

  String _fmtPrice(double p) {
    String s = p.toStringAsFixed(0);
    String r = '';
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      c++;
      r = s[i] + r;
      if (c % 3 == 0 && i != 0) r = '.$r';
    }
    return r;
  }

  String _fmtDateStr(String? d) {
    if (d == null) return '-';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_role == 'admin' ? 'Kelola Pemesanan' : 'Pemesanan Saya'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat pemesanan...')
          : _error.isNotEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _fetchBookings, child: const Text('Coba Lagi')),
                ]))
              : _bookings.isEmpty
                  ? const Center(child: Text('Belum ada pemesanan'))
                  : RefreshIndicator(
                      onRefresh: _fetchBookings,
                      child: ListView.builder(
                        itemCount: _bookings.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (ctx, i) => _buildBookingCard(_bookings[i]),
                      ),
                    ),
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(b.bookingCode ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor(b.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_statusLabel(b.status), style: TextStyle(color: _statusColor(b.status), fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (b.carName != null) Text('Mobil: ${b.carName}', style: TextStyle(color: Colors.grey.shade700)),
            if (_role == 'admin' && b.userName != null) Text('User: ${b.userName}', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text('${_fmtDateStr(b.startDate)} - ${_fmtDateStr(b.endDate)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            if (b.duration != null) Text('Durasi: ${b.duration} hari', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            if (b.totalPrice != null) ...[
              const SizedBox(height: 4),
              Text('Total: Rp ${_fmtPrice(b.totalPrice!)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), fontSize: 15)),
            ],
            if (b.pickupLocation != null) ...[
              const SizedBox(height: 4),
              Text('Pickup: ${b.pickupLocation}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
            if (b.paymentStatus != null) ...[
              const SizedBox(height: 4),
              Text('Pembayaran: ${b.paymentStatus}', style: TextStyle(fontSize: 12, color: b.paymentStatus == 'paid' ? Colors.green : Colors.orange)),
            ],
            const SizedBox(height: 10),
            _buildActions(b),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BookingModel b) {
    List<Widget> actions = [];

    if (_role == 'user') {
      if ((b.status == 'pending' || b.status == 'confirmed') && b.paymentStatus != 'paid') {
        actions.add(ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentFormScreen(booking: b)));
            if (result == true) _fetchBookings();
          },
          icon: const Icon(Icons.payment, size: 16),
          label: const Text('Bayar'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13)),
        ));
      }
      if (b.status == 'pending') {
        actions.add(OutlinedButton.icon(
          onPressed: () => _cancelBooking(b),
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text('Batalkan'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13)),
        ));
      }
    } else {
      if (b.status == 'pending') {
        actions.add(ElevatedButton.icon(
          onPressed: () => _confirmBooking(b),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Konfirmasi'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13)),
        ));
      }
      if (b.status == 'confirmed' || b.status == 'active') {
        actions.add(ElevatedButton.icon(
          onPressed: () => _completeBooking(b),
          icon: const Icon(Icons.done_all, size: 16),
          label: const Text('Selesaikan'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13)),
        ));
      }
      if (b.status == 'pending') {
        actions.add(OutlinedButton.icon(
          onPressed: () => _cancelBooking(b),
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text('Batalkan'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13)),
        ));
      }
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: actions);
  }
}
