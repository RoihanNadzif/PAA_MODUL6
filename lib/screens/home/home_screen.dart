import 'package:flutter/material.dart';
import 'package:modul7/services/auth_service.dart';
import 'package:modul7/screens/car/car_list_screen.dart';
import 'package:modul7/screens/booking/booking_list_screen.dart';
import 'package:modul7/screens/booking/payment_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _role = role ?? 'user');
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const CarListScreen(),
      const BookingListScreen(),
      const PaymentListScreen(),
    ];

    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.directions_car),
        label: 'Mobil',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.book_online),
        label: _role == 'admin' ? 'Kelola Booking' : 'Pemesanan',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.payment),
        label: _role == 'admin' ? 'Verifikasi' : 'Pembayaran',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF1A1A2E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
