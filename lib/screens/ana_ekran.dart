// lib/screens/ana_ekran.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../controllers/system_memory.dart';
import '../core/audio_system.dart';
import '../core/translation_manager.dart';

import 'dashboard_screen.dart'; 
import 'status_screen.dart';    
import 'calendar_screen.dart'; 
import 'diet_screen.dart';
import 'profile_screen.dart';

class AnaEkran extends StatefulWidget {
  final bool playStartupSound;
  const AnaEkran({super.key, this.playStartupSound = true});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> with WidgetsBindingObserver {
  int _seciliSayfa = 0;

  final List<Widget> _sayfalar = [
    const DashboardScreen(), 
    const StatusWindow(),    
    const CalendarScreen(),  
    const YemekEkrani(),     
    const ProfileScreen(),   
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.playStartupSound) {
      AudioSystem.playStartup();
    }
    _kontrolVeRapor();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _kontrolVeRapor();
    }
  }

  void _kontrolVeRapor() {
    SystemMemory.yeniGunKontrolu();
    
    if (SystemMemory.geceRaporu.isNotEmpty) {
      String rapor = SystemMemory.geceRaporu;
      SystemMemory.geceRaporu = ""; 
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _geceRaporunuGoster(rapor);
          setState(() {}); 
        }
      });
    }
  }

  void _geceRaporunuGoster(String rapor) {
    bool cezaVarMi = rapor.contains("PENALTY");
    Color dialogColor = cezaVarMi ? const Color(0xFFEF4444) : const Color(0xFF38BDF8);

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF030712).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(side: BorderSide(color: dialogColor, width: 1), borderRadius: BorderRadius.circular(4)),
          title: Text(
            cezaVarMi
                ? (TranslationManager.isTurkish ? '[ SİSTEM UYARISI ]' : '[ SYSTEM WARNING ]')
                : (TranslationManager.isTurkish ? '[ GÜNLÜK GÖREV TAMAMLANDI ]' : '[ DAILY QUEST COMPLETED ]'),
            style: GoogleFonts.orbitron(color: dialogColor, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          content: Text(rapor, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2, height: 1.5)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: dialogColor.withValues(alpha: 0.1), side: BorderSide(color: dialogColor)),
              onPressed: () { 
                Navigator.pop(context); 
                setState(() {}); 
              },
              child: Text(TranslationManager.isTurkish ? 'ONAYLA' : 'CONFIRM', style: TextStyle(color: dialogColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // GÜNCELLENEN KISIM: MENÜ DEĞİŞTİRİRKEN SES ÇAL
  // =========================================================
  void _sayfaDegistir(int index) {
    if (_seciliSayfa != index) {
      AudioSystem.playTransition(); // Tıklama sesini tetikler!
      setState(() {
        _seciliSayfa = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SystemMemory.appLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF030712), 
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
              key: ValueKey<int>(_seciliSayfa), 
              child: _sayfalar[_seciliSayfa]
            ),
          ),
          
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: const Border(top: BorderSide(color: Color(0xFF38BDF8), width: 0.5)),
              boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.1), blurRadius: 10)],
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF030712),
              type: BottomNavigationBarType.fixed, 
              selectedItemColor: const Color(0xFF38BDF8),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              currentIndex: _seciliSayfa,
              onTap: _sayfaDegistir,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.dashboard_outlined), 
                  activeIcon: const Icon(Icons.dashboard), 
                  label: TranslationManager.get('nav_dashboard'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.analytics_outlined), 
                  activeIcon: const Icon(Icons.analytics), 
                  label: TranslationManager.get('nav_system'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.calendar_today_outlined), 
                  activeIcon: const Icon(Icons.calendar_month), 
                  label: TranslationManager.get('nav_quest_log'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.restaurant_outlined), 
                  activeIcon: const Icon(Icons.restaurant), 
                  label: TranslationManager.get('nav_inventory'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.badge_outlined), 
                  activeIcon: const Icon(Icons.badge), 
                  label: TranslationManager.get('nav_profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}