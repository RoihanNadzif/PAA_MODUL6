import 'package:flutter/material.dart';
import 'package:modul7/models/payment_model.dart';
import 'package:modul7/services/payment_service.dart';
import 'package:modul7/services/auth_service.dart';
import 'package:modul7/widgets/loading_indicator.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  List<PaymentModel> _payments = [];
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
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final list = await PaymentService.getPayments(limit: 50);
      if (mounted) setState(() => _payments = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyPayment(PaymentModel p, String status) async {
    final label = status == 'success' ? 'Terima' : 'Tolak';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$label Pembayaran'),
        content: Text('$label pembayaran ${p.paymentCode ?? ''}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: status == 'success' ? Colors.green : Colors.red),
            child: Text('Ya, $label'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await PaymentService.verifyPayment(p.id!, status: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran di${label.toLowerCase()}'), backgroundColor: Colors.green));
        _fetchPayments();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'success': return Colors.green;
      case 'failed': return Colors.red;
      case 'refunded': return Colors.purple;
      default: return Colors.orange;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending': return 'Menunggu';
      case 'success': return 'Berhasil';
      case 'failed': return 'Gagal';
      case 'refunded': return 'Refund';
      default: return s;
    }
  }

  String _methodLabel(String? m) {
    switch (m) {
      case 'transfer_bank': return 'Transfer Bank';
      case 'kartu_kredit': return 'Kartu Kredit';
      case 'kartu_debit': return 'Kartu Debit';
      case 'e_wallet': return 'E-Wallet';
      case 'tunai': return 'Tunai';
      default: return m ?? '-';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_role == 'admin' ? 'Verifikasi Pembayaran' : 'Riwayat Pembayaran'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat pembayaran...')
          : _error.isNotEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _fetchPayments, child: const Text('Coba Lagi')),
                ]))
              : _payments.isEmpty
                  ? const Center(child: Text('Belum ada pembayaran'))
                  : RefreshIndicator(
                      onRefresh: _fetchPayments,
                      child: ListView.builder(
                        itemCount: _payments.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (ctx, i) => _buildPaymentCard(_payments[i]),
                      ),
                    ),
    );
  }

  Widget _buildPaymentCard(PaymentModel p) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(p.paymentCode ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor(p.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(_statusLabel(p.status), style: TextStyle(color: _statusColor(p.status), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            if (_role == 'admin' && p.userName != null) Text('User: ${p.userName}', style: TextStyle(color: Colors.grey.shade700)),
            if (p.bookingCode != null) Text('Booking: ${p.bookingCode}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            Text('Metode: ${_methodLabel(p.method)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            if (p.bankName != null) Text('Bank: ${p.bankName}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            if (p.amount != null) ...[
              const SizedBox(height: 4),
              Text('Rp ${_fmtPrice(p.amount!)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), fontSize: 16)),
            ],
            // Admin verify actions
            if (_role == 'admin' && p.status == 'pending') ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                ElevatedButton.icon(
                  onPressed: () => _verifyPayment(p, 'success'),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Terima'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _verifyPayment(p, 'failed'),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13)),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
