import 'package:flutter/material.dart';
import 'package:modul7/models/booking_model.dart';
import 'package:modul7/services/payment_service.dart';
import 'package:modul7/widgets/loading_indicator.dart';

class PaymentFormScreen extends StatefulWidget {
  final BookingModel booking;
  const PaymentFormScreen({super.key, required this.booking});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _accNumberCtrl = TextEditingController();
  final _accNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _method = 'transfer_bank';
  bool _isLoading = false;

  final List<Map<String, String>> _methods = [
    {'value': 'transfer_bank', 'label': 'Transfer Bank'},
    {'value': 'kartu_kredit', 'label': 'Kartu Kredit'},
    {'value': 'kartu_debit', 'label': 'Kartu Debit'},
    {'value': 'e_wallet', 'label': 'E-Wallet'},
    {'value': 'tunai', 'label': 'Tunai'},
  ];

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await PaymentService.createPayment(
        bookingId: widget.booking.id!,
        method: _method,
        bankName: _bankNameCtrl.text.trim().isEmpty ? null : _bankNameCtrl.text.trim(),
        accountNumber: _accNumberCtrl.text.trim().isEmpty ? null : _accNumberCtrl.text.trim(),
        accountName: _accNameCtrl.text.trim().isEmpty ? null : _accNameCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil dibuat!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accNumberCtrl.dispose();
    _accNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memproses pembayaran...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Info Booking
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kode: ${b.bookingCode ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          if (b.carName != null) ...[const SizedBox(height: 4), Text('Mobil: ${b.carName}', style: TextStyle(color: Colors.grey.shade700))],
                          if (b.totalPrice != null) ...[
                            const SizedBox(height: 8),
                            Text('Total Bayar: Rp ${_fmtPrice(b.totalPrice!)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A2E))),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metode Pembayaran
                  const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _method,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _methods.map((m) => DropdownMenuItem(value: m['value'], child: Text(m['label']!))).toList(),
                    onChanged: (v) => setState(() => _method = v!),
                  ),
                  const SizedBox(height: 16),

                  if (_method == 'transfer_bank') ...[
                    TextFormField(
                      controller: _bankNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama Bank',
                        hintText: 'Contoh: BCA',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accNumberCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nomor Rekening',
                        hintText: 'Contoh: 1234567890',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama Pemilik Rekening',
                        hintText: 'Contoh: Budi Santoso',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
