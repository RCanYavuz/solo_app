// lib/screens/boxing_timer_screen.dart - OTOMATİK RANK GÜNCELLEMESİ
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/audio_system.dart'; 
import '../controllers/system_memory.dart'; // Level bilgisini çekmek için

class EgitimFazi {
  final String isim;
  final int sureSaniye;
  final Color renk;
  final String talimat;
  EgitimFazi(this.isim, this.sureSaniye, this.renk, this.talimat);
}

class BoxingTimerScreen extends StatefulWidget {
  const BoxingTimerScreen({super.key});
  @override
  State<BoxingTimerScreen> createState() => _BoxingTimerScreenState();
}

class _BoxingTimerScreenState extends State<BoxingTimerScreen> {
  static const Color systemBlue = Color(0xFF389EFF); 
  static const Color physicalGold = Color(0xFFB08D57); 
  static const Color deepBlack = Colors.black; 
  static const Color cardBg = Color(0xFF0D0D0D); 
  static const Color systemRed = Color(0xFFD32F2F);

  String anaMod = 'Sistem Parkurları'; 
  String sistemTuru = 'Koşu (Hız Odaklı)'; 
  
  // YENİ: OTOMATİK RANK HESAPLAYICI
  String get otomatikRank {
    int lvl = SystemMemory.level.value;
    if (lvl < 5) return 'E-Rank (Çaylak)';
    if (lvl < 15) return 'C-Rank (Orta)';
    return 'A-Rank (Zor)';
  }

  int raundSuresiSaniye = 180; 
  int dinlenmeSuresiSaniye = 60; 
  int toplamRaund = 3;

  List<EgitimFazi> parkur = [];
  int aktifFazIndex = 0;
  int kalanSaniye = 0; 
  bool calisiyor = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _parkuruOlustur(); 
  }

  void _parkuruOlustur() {
    parkur.clear();
    String rank = otomatikRank; // Rank artık sistemden geliyor

    if (anaMod == 'Serbest Ayarlar') {
      for (int i = 0; i < toplamRaund; i++) {
        parkur.add(EgitimFazi("RAUND ${i+1}", raundSuresiSaniye, systemRed, "DÖVÜŞ/ÇALIŞ!"));
        if (i < toplamRaund - 1 && dinlenmeSuresiSaniye > 0) {
          parkur.add(EgitimFazi("DİNLENME", dinlenmeSuresiSaniye, Colors.greenAccent, "ŞİFA VE NEFES"));
        }
      }
    } else {
      if (sistemTuru == 'İp Atlama') {
        if (rank == 'E-Rank (Çaylak)') {
          parkur.add(EgitimFazi("Isınma", 60, Colors.white54, "Yavaş tempo atla"));
          parkur.add(EgitimFazi("Çalışma", 180, systemBlue, "Orta tempo atla"));
          parkur.add(EgitimFazi("Dinlenme", 60, Colors.greenAccent, "İpi bırak, nefeslen"));
          parkur.add(EgitimFazi("Kapanış", 180, systemBlue, "Orta tempo atla"));
        } else if (rank == 'C-Rank (Orta)') {
          for(int i=0; i<3; i++) {
            parkur.add(EgitimFazi("Hızlı Tempo", 180, systemRed, "Hızlan! Durmak yok."));
            parkur.add(EgitimFazi("Aktif Dinlenme", 60, systemBlue, "İpi yavaş çevirerek dinlen."));
          }
        } else {
          parkur.add(EgitimFazi("Cehennem", 900, physicalGold, "15 Dakika Kesintisiz Atlama!")); 
        }
      } 
      else if (sistemTuru == 'Koşu (Hız Odaklı)') {
        if (rank == 'E-Rank (Çaylak)') {
          parkur.add(EgitimFazi("Yürüyüş", 120, Colors.greenAccent, "Hız 4-5. Tempolu yürü."));
          parkur.add(EgitimFazi("Hafif Koşu", 180, systemBlue, "Hız 7-8. Vücudunu alıştır."));
          parkur.add(EgitimFazi("Soğuma", 120, Colors.greenAccent, "Hız 4. Yürü ve nefeslen."));
        } else if (rank == 'C-Rank (Orta)') {
          parkur.add(EgitimFazi("Yürüyüş", 120, Colors.greenAccent, "Hız 5. Hazırlan."));
          for(int i=0; i<3; i++) {
            parkur.add(EgitimFazi("Koşu", 120, systemBlue, "Hız 8-9. Stabil koşu."));
            parkur.add(EgitimFazi("DEPAR", 60, systemRed, "HIZI 12+ YAP! GÖLGELERDEN KAÇ!"));
            parkur.add(EgitimFazi("Yürüyüş", 60, Colors.greenAccent, "Hız 4. Nefeslanma."));
          }
        } else {
          parkur.add(EgitimFazi("Isınma", 120, Colors.greenAccent, "Hız 5."));
          for(int i=0; i<5; i++) {
            parkur.add(EgitimFazi("Ölüm Koşusu", 180, physicalGold, "Hız 10. Dayanıklılık Testi."));
            parkur.add(EgitimFazi("DEPAR", 60, systemRed, "HIZI MAKSİMUMA ÇEK!"));
          }
          parkur.add(EgitimFazi("Soğuma", 120, Colors.greenAccent, "Hız 3. Başardın."));
        }
      }
      else if (sistemTuru == 'Koşu (Eğim/Direnç)') {
        if (rank == 'E-Rank (Çaylak)') {
          parkur.add(EgitimFazi("Düz Yol", 120, Colors.greenAccent, "Hız 5, Eğim 0."));
          parkur.add(EgitimFazi("Hafif Tepe", 180, systemBlue, "Hız 5, Eğimi %5 yap."));
          parkur.add(EgitimFazi("Düz Yol", 120, Colors.greenAccent, "Eğimi sıfırla."));
        } else if (rank == 'C-Rank (Orta)') {
          parkur.add(EgitimFazi("Düz Yol", 120, Colors.greenAccent, "Hız 5, Eğim 0."));
          parkur.add(EgitimFazi("Tepe", 120, systemBlue, "Hız 5, Eğimi %8 yap."));
          parkur.add(EgitimFazi("Dağ Tırmanışı", 120, physicalGold, "Hız 4.5, Eğimi %12 yap!"));
          parkur.add(EgitimFazi("İniş", 120, Colors.greenAccent, "Eğimi sıfırla."));
          parkur.add(EgitimFazi("Son Zirve", 120, systemRed, "Hız 5, Eğimi %15 YAP!"));
        } else {
          parkur.add(EgitimFazi("Düz Yol", 60, Colors.greenAccent, "Kısa ısınma."));
          for(int i=0; i<4; i++) {
            parkur.add(EgitimFazi("Dağ Eteği", 120, systemBlue, "Eğim %10, Hız 5."));
            parkur.add(EgitimFazi("ZİNDAN ZİRVESİ", 120, systemRed, "EĞİM %15 (MAKSIMUM)."));
          }
        }
      }
    }
    aktifFazIndex = 0;
    if (parkur.isNotEmpty) kalanSaniye = parkur[0].sureSaniye;
  }

  void _baslatDuraklat() {
    if (calisiyor) {
      _timer?.cancel();
      setState(() => calisiyor = false);
    } else {
      if (parkur.isEmpty) return;
      setState(() => calisiyor = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (kalanSaniye > 0) { setState(() => kalanSaniye--); } else {
          AudioSystem.playBell(); 
          aktifFazIndex++;
          if (aktifFazIndex < parkur.length) {
            setState(() { kalanSaniye = parkur[aktifFazIndex].sureSaniye; });
          } else {
            _timer?.cancel();
            setState(() { calisiyor = false; });
            AudioSystem.playSuccess(); 
            _antrenmanBittiDialog();
          }
        }
      });
    }
  }

  void _sifirla() { _timer?.cancel(); setState(() { calisiyor = false; _parkuruOlustur(); }); }

  void _antrenmanBittiDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(side: const BorderSide(color: physicalGold), borderRadius: BorderRadius.circular(15)),
        title: Text('[ ZİNDAN TEMİZLENDİ ]', style: GoogleFonts.orbitron(color: physicalGold, fontWeight: FontWeight.bold)),
        content: Text("Rankın için belirlenen parkuru tamamladın.\nSistem seni izliyor.", style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [ ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: physicalGold.withOpacity(0.2), side: const BorderSide(color: physicalGold)), onPressed: () { Navigator.pop(context); _sifirla(); }, child: const Text('ONAYLA', style: TextStyle(color: physicalGold, fontWeight: FontWeight.bold))) ],
      ),
    );
  }

  String _sureFormatla(int saniye) {
    int dk = saniye ~/ 60; int sn = saniye % 60;
    return '${dk.toString().padLeft(2, '0')}:${sn.toString().padLeft(2, '0')}';
  }

  Widget _ayarButonu(String baslik, String degerMetni, VoidCallback azalt, VoidCallback artir) {
    return Column(
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline, color: systemBlue), onPressed: calisiyor ? null : azalt),
            Text(degerMetni, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle_outline, color: systemBlue), onPressed: calisiyor ? null : artir),
          ],
        )
      ],
    );
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    EgitimFazi? aktifFaz = parkur.isNotEmpty ? parkur[aktifFazIndex] : null;
    EgitimFazi? siradakiFaz = (parkur.isNotEmpty && aktifFazIndex + 1 < parkur.length) ? parkur[aktifFazIndex + 1] : null;
    Color fazRengi = aktifFaz?.renk ?? systemBlue;

    return Scaffold(
      backgroundColor: deepBlack,
      appBar: AppBar(title: Text('SAVAŞ SİMÜLATÖRÜ', style: GoogleFonts.orbitron(color: systemRed, fontWeight: FontWeight.bold, fontSize: 18)), backgroundColor: const Color(0xFF050A10), elevation: 0, iconTheme: const IconThemeData(color: systemRed)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!calisiyor)
                Container(
                  margin: const EdgeInsets.all(15), padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: cardBg, border: Border.all(color: systemRed.withOpacity(0.5)), borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      // RANK GÖSTERGESİ (Kullanıcı değiştiremez, sadece görür)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield, color: systemRed, size: 20),
                          const SizedBox(width: 10),
                          Text("SİSTEM RANKI: ", style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 14)),
                          Text(otomatikRank, style: GoogleFonts.orbitron(color: systemRed, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SegmentedButton<String>(
                        segments: const [ButtonSegment(value: 'Serbest Ayarlar', label: Text('SERBEST')), ButtonSegment(value: 'Sistem Parkurları', label: Text('PARKURLAR'))],
                        selected: {anaMod},
                        onSelectionChanged: (set) { setState(() { anaMod = set.first; _parkuruOlustur(); }); },
                        style: SegmentedButton.styleFrom(backgroundColor: const Color(0xFF101820), selectedBackgroundColor: systemRed.withOpacity(0.2), selectedForegroundColor: systemRed, foregroundColor: Colors.white54),
                      ),
                      const SizedBox(height: 15),
                      if (anaMod == 'Sistem Parkurları') 
                        DropdownButtonFormField<String>(
                          value: sistemTuru, dropdownColor: cardBg, decoration: InputDecoration(labelText: 'Antrenman Türü', labelStyle: const TextStyle(color: physicalGold), filled: true, fillColor: const Color(0xFF101820), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: physicalGold.withOpacity(0.5))), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: physicalGold))),
                          style: const TextStyle(color: physicalGold, fontWeight: FontWeight.bold),
                          items: ['İp Atlama', 'Koşu (Hız Odaklı)', 'Koşu (Eğim/Direnç)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) { setState(() { sistemTuru = val!; _parkuruOlustur(); }); },
                        ),
                      if (anaMod == 'Serbest Ayarlar') 
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ayarButonu('Çalışma', _sureFormatla(raundSuresiSaniye), () { if(raundSuresiSaniye > 15) setState(() { raundSuresiSaniye -= 30; _parkuruOlustur(); }); }, () { setState(() { raundSuresiSaniye += 30; _parkuruOlustur(); }); }),
                              const SizedBox(width: 10),
                              _ayarButonu('Dinlenme', _sureFormatla(dinlenmeSuresiSaniye), () { if(dinlenmeSuresiSaniye > 0) setState(() { dinlenmeSuresiSaniye -= 10; _parkuruOlustur(); }); }, () { setState(() { dinlenmeSuresiSaniye += 10; _parkuruOlustur(); }); }),
                              const SizedBox(width: 10),
                              _ayarButonu('Raund', toplamRaund.toString().padLeft(2, '0'), () { if(toplamRaund > 1) setState(() { toplamRaund--; _parkuruOlustur(); }); }, () { setState(() { toplamRaund++; _parkuruOlustur(); }); }),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    if (aktifFaz != null) ...[
                      Text(aktifFaz.isim.toUpperCase(), style: GoogleFonts.rajdhani(color: fazRengi, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Text("Adım: ${aktifFazIndex + 1} / ${parkur.length}", style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      const SizedBox(height: 20),
                    ],
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(width: 240, height: 240, child: CircularProgressIndicator(value: aktifFaz != null ? (kalanSaniye / aktifFaz.sureSaniye) : 0, strokeWidth: 12, backgroundColor: cardBg, valueColor: AlwaysStoppedAnimation<Color>(fazRengi))),
                        Text(_sureFormatla(kalanSaniye), style: GoogleFonts.orbitron(color: Colors.white, fontSize: 55, fontWeight: FontWeight.bold, shadows: [Shadow(color: fazRengi.withOpacity(0.6), blurRadius: 25)])),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (aktifFaz != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: fazRengi.withOpacity(0.1), border: Border.all(color: fazRengi, width: 2), borderRadius: BorderRadius.circular(10)),
                        child: Text(aktifFaz.talimat, textAlign: TextAlign.center, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 15),
                    if (siradakiFaz != null) Text('Sıradaki: ${siradakiFaz.isim}', style: const TextStyle(color: Colors.white38, fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.white, size: 30), onPressed: _sifirla),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: _baslatDuraklat,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: calisiyor ? physicalGold.withOpacity(0.2) : systemRed.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: calisiyor ? physicalGold : systemRed, width: 3)),
                        child: Icon(calisiyor ? Icons.pause : Icons.play_arrow, color: calisiyor ? physicalGold : systemRed, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}