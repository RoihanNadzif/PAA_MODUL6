import 'package:flutter/material.dart';
import 'package:modul7/models/car_model.dart';
import 'package:modul7/services/booking_service.dart';
import 'package:modul7/widgets/custom_text_field.dart';
import 'package:modul7/widgets/loading_indicator.dart';

class BookingFormScreen extends StatefulWidget {
  final CarModel car;
  const BookingFormScreen({super.key, required this.car});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _returnCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  int get _duration {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice => _duration * widget.car.pricePerDay;

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dispDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final first = isStart ? now : (_startDate ?? now).add(const Duration(days: 1));
    final init = isStart ? (_startDate ?? now) : (_endDate ?? first);
    final picked = await showDatePicker(
      context: context,
      initialDate: init.isBefore(first) ? first : init,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A1A2E)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await BookingService.createBooking(
        carId: widget.car.id!,
        startDate: _fmtDate(_startDate!),
        endDate: _fmtDate(_endDate!),
        pickupLocation: _pickupCtrl.text.trim(),
        returnLocation: _returnCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemesanan berhasil dibuat!'), backgroundColor: Colors.green),
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
    _pickupCtrl.dispose();
    _returnCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pemesanan'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Membuat pemesanan...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(car.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 4),
                          Text('${car.brand} • ${car.type.toUpperCase()}', style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Text('Rp ${_fmtPrice(car.pricePerDay)}/hari', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tanggal Sewa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _dateBtn('Tanggal Mulai', _startDate, () => _pickDate(true))),
                    const SizedBox(width: 12),
                    Expanded(child: _dateBtn('Tanggal Selesai', _endDate, () => _pickDate(false))),
                  ]),
                  if (_duration > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A2E).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Durasi: $_duration hari', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Total: Rp ${_fmtPrice(_totalPrice)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), fontSize: 16)),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomTextField(label: 'Lokasi Pengambilan *', controller: _pickupCtrl, prefixIcon: Icons.location_on_outlined, hintText: 'Contoh: Kantor Jakarta Selatan', validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                  CustomTextField(label: 'Lokasi Pengembalian *', controller: _returnCtrl, prefixIcon: Icons.location_on_outlined, hintText: 'Contoh: Kantor Jakarta Selatan', validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                  CustomTextField(label: 'Catatan (Opsional)', controller: _notesCtrl, prefixIcon: Icons.note_outlined, maxLines: 3),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Pesan Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _dateBtn(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
        child: Row(children: [
          Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(date != null ? _dispDate(date) : label, style: TextStyle(color: date != null ? Colors.black87 : Colors.grey.shade500, fontSize: 14))),
        ]),
      ),
    );
  }
}
