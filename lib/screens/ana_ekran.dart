import 'package:flutter/material.dart';
import '../controllers/system_memory.dart';
import 'dashboard_screen.dart'; // YENİ: ANA KARARGAH
import 'status_screen.dart';    // Eski Sistem
import 'calendar_screen.dart'; 
import 'diet_screen.dart';
import 'profile_screen.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _seciliSayfa = 0;

  // ARTIK 5 SAYFAMIZ VAR (0. İndeks Ana Karargah oldu)
  final List<Widget> _sayfalar = [
    const DashboardScreen(), // 0: ANA KARARGAH (Özet)
    const StatusWindow(),    // 1: SİSTEM (Görevleri tamamlama ve Günü bitirme)
    const CalendarScreen(),  // 2: GÜNLÜK (Takvim planı)
    const YemekEkrani(),     // 3: ENVANTER (Diyet)
    const ProfileScreen(),   // 4: PROFİL (Kimlik)
  ];

  void _sayfaDegistir(int index) {
    setState(() {
      _seciliSayfa = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
// YENİ: SAYFALAR ARASI HOLOGRAM GEÇİŞİ
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutExpo)
              ),
              child: child,
            ),
          );
        },
        child: SizedBox(
          key: ValueKey<int>(_seciliSayfa), // Flutter'ın sayfaların değiştiğini anlaması için anahtar
          child: _sayfalar[_seciliSayfa]
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: Colors.cyanAccent, width: 0.5)),
          boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0A0E17),
          type: BottomNavigationBarType.fixed, // İkonlar kaymasın diye sabitliyoruz
          selectedItemColor: Colors.cyanAccent,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          currentIndex: _seciliSayfa,
          onTap: _sayfaDegistir,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'KARARGAH'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'SİSTEM'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_month), label: 'GÜNLÜK'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_outlined), activeIcon: Icon(Icons.restaurant), label: 'ENVANTER'),
            BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), activeIcon: Icon(Icons.badge), label: 'PROFİL'),
          ],
        ),
      ),
    );
  }
}