// lib/screens/macro_dashboard_screen.dart
// ============================================================
// GÖRSEL DESTEKLİ MAKRO & DİYET LABORATUVARI
// DiyetMotoru'nu kullanarak makro hesabı yapar,
// sonuçları animasyonlu çemberlerle gösterir ve
// hedefe özel yemek planı kartları sunar.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/diyet_motoru.dart';
import '../controllers/system_memory.dart';
import '../widgets/hologram_card.dart';

// ──────────────────────────────────────────────
// ANA EKRAN
// ──────────────────────────────────────────────
class MacroDashboardScreen extends StatefulWidget {
  const MacroDashboardScreen({super.key});

  @override
  State<MacroDashboardScreen> createState() => _MacroDashboardScreenState();
}

class _MacroDashboardScreenState extends State<MacroDashboardScreen>
    with SingleTickerProviderStateMixin {
  // ─── Sistem Renkleri ───
  static const Color _sysBlue    = Color(0xFF38BDF8);
  static const Color _sysDarkBg  = Color(0xFF030712);
  static const Color _sysRed     = Color(0xFFEF4444);
  static const Color _sysGold    = Color(0xFFB08D57);
  static const Color _sysText    = Color(0xFF94A3B8);
  static const Color _sysGreen   = Color(0xFF22C55E);
  static const Color _sysPurple  = Color(0xFFA855F7);

  // ─── State ───
  double _kilo = 75.0;
  String _secilenHedef = "yag_yakma";
  Map<String, int>? _sonuc;

  late AnimationController _animCtrl;
  late Animation<double> _animDeger;

  @override
  void initState() {
    super.initState();
    _kilo = SystemMemory.kilo > 0 ? SystemMemory.kilo : 75.0;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animDeger = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);

    // İlk açılışta otomatik hesapla
    _hesapla();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _hesapla() {
    setState(() {
      _sonuc = DiyetMotoru.makroHesapla(_kilo, _secilenHedef);
    });
    _animCtrl.forward(from: 0);
  }

  // ─── YEMEK PLANI ÜRETİCİ ───
  List<_Ogun> _ogunleriOlustur() {
    if (_secilenHedef == "yag_yakma") {
      return [
        _Ogun(
          baslik: "MORNING RATION",
          altBaslik: "Sabah Rasyonu",
          ikon: Icons.wb_sunny_rounded,
          renk: _sysGold,
          yemekler: [
            _YemekOnerisi("Yumurta Beyazı Omleti (3 Adet)", 150, "30g P / 1g F / 0g C", Icons.egg_alt),
            _YemekOnerisi("Yulaf Ezmesi + Tarçın", 200, "7g P / 4g F / 35g C", Icons.grain),
            _YemekOnerisi("Yeşil Çay (Şekersiz)", 0, "0g P / 0g F / 0g C", Icons.local_cafe),
          ],
        ),
        _Ogun(
          baslik: "HUNTER'S FEAST",
          altBaslik: "Öğle Avı",
          ikon: Icons.restaurant,
          renk: _sysBlue,
          yemekler: [
            _YemekOnerisi("Izgara Tavuk Göğsü", 250, "45g P / 6g F / 0g C", Icons.set_meal),
            _YemekOnerisi("Bulgur Pilavı", 180, "6g P / 1g F / 38g C", Icons.rice_bowl),
            _YemekOnerisi("Mevsim Salatası + Limon", 50, "2g P / 0g F / 10g C", Icons.eco),
          ],
        ),
        _Ogun(
          baslik: "EVENING PROTOCOL",
          altBaslik: "Akşam Protokolü",
          ikon: Icons.nightlight_round,
          renk: _sysPurple,
          yemekler: [
            _YemekOnerisi("Somon Fileto (Fırında)", 300, "35g P / 18g F / 0g C", Icons.set_meal),
            _YemekOnerisi("Buharda Brokoli & Havuç", 55, "3g P / 0g F / 10g C", Icons.spa),
            _YemekOnerisi("Kinoa (1 Porsiyon)", 120, "5g P / 2g F / 21g C", Icons.grain),
          ],
        ),
        _Ogun(
          baslik: "RECOVERY POTION",
          altBaslik: "İyileşme İksiri",
          ikon: Icons.local_pharmacy,
          renk: _sysGreen,
          yemekler: [
            _YemekOnerisi("Badem (15 Adet)", 100, "4g P / 9g F / 3g C", Icons.filter_vintage),
            _YemekOnerisi("Whey Protein Shake", 120, "25g P / 1g F / 3g C", Icons.local_drink),
            _YemekOnerisi("Yeşil Elma", 80, "0g P / 0g F / 20g C", Icons.apple),
          ],
        ),
      ];
    } else {
      return [
        _Ogun(
          baslik: "MORNING RATION",
          altBaslik: "Sabah Rasyonu",
          ikon: Icons.wb_sunny_rounded,
          renk: _sysGold,
          yemekler: [
            _YemekOnerisi("Tam Yumurta (3 Adet)", 240, "18g P / 15g F / 2g C", Icons.egg_alt),
            _YemekOnerisi("Peynirli Tam Buğday Tost", 350, "15g P / 12g F / 42g C", Icons.bakery_dining),
            _YemekOnerisi("Bal + Fıstık Ezmesi", 200, "6g P / 10g F / 24g C", Icons.icecream),
          ],
        ),
        _Ogun(
          baslik: "HUNTER'S FEAST",
          altBaslik: "Öğle Avı",
          ikon: Icons.restaurant,
          renk: _sysBlue,
          yemekler: [
            _YemekOnerisi("Kırmızı Et (200g Dana)", 400, "50g P / 20g F / 0g C", Icons.set_meal),
            _YemekOnerisi("Makarna (Tam Buğday)", 350, "12g P / 3g F / 70g C", Icons.dinner_dining),
            _YemekOnerisi("Pirinç Pilavı", 250, "5g P / 1g F / 55g C", Icons.rice_bowl),
          ],
        ),
        _Ogun(
          baslik: "EVENING PROTOCOL",
          altBaslik: "Akşam Protokolü",
          ikon: Icons.nightlight_round,
          renk: _sysPurple,
          yemekler: [
            _YemekOnerisi("Tavuk But (Fırında)", 350, "40g P / 18g F / 0g C", Icons.set_meal),
            _YemekOnerisi("Patates Püresi", 250, "4g P / 8g F / 40g C", Icons.breakfast_dining),
            _YemekOnerisi("Mercimek Çorbası", 200, "12g P / 3g F / 30g C", Icons.soup_kitchen),
          ],
        ),
        _Ogun(
          baslik: "RECOVERY POTION",
          altBaslik: "İyileşme İksiri",
          ikon: Icons.local_pharmacy,
          renk: _sysGreen,
          yemekler: [
            _YemekOnerisi("Muz (2 Adet)", 200, "2g P / 0g F / 50g C", Icons.spa),
            _YemekOnerisi("Mass Gainer Shake", 400, "30g P / 8g F / 65g C", Icons.local_drink),
            _YemekOnerisi("Kuru Üzüm + Ceviz", 150, "3g P / 8g F / 18g C", Icons.filter_vintage),
          ],
        ),
      ];
    }
  }

  // ══════════════════════════════════════════════
  // ANA BUILD
  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final ogunler = _sonuc != null ? _ogunleriOlustur() : <_Ogun>[];

    // Makro dağılımı yüzdeleri (animasyonlu çemberler için)
    int topP = _sonuc?["Protein"] ?? 0;
    int topF = _sonuc?["Yag"] ?? 0;
    int topC = _sonuc?["Karbonhidrat"] ?? 0;
    int topKalori = _sonuc?["Kalori"] ?? 0;
    int topGram = topP + topF + topC;

    double pYuzde = topGram > 0 ? topP / topGram : 0;
    double fYuzde = topGram > 0 ? topF / topGram : 0;
    double cYuzde = topGram > 0 ? topC / topGram : 0;

    return Scaffold(
      backgroundColor: _sysDarkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _sysBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'N U T R I T I O N   L A B',
          style: GoogleFonts.orbitron(
            color: _sysBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ──────────────────────────────────
            // 1. GİRDİ PANELİ
            // ──────────────────────────────────
            HologramCard(
              neonRenk: _sysBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BODY SCAN INPUT', style: GoogleFonts.orbitron(color: _sysText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 20),

                  // Kilo Slider
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight_outlined, color: _sysBlue, size: 22),
                      const SizedBox(width: 10),
                      Text('WEIGHT', style: GoogleFonts.rajdhani(color: _sysText, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _sysBlue.withOpacity(0.1),
                          border: Border.all(color: _sysBlue.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_kilo.toStringAsFixed(1)} KG',
                          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _sysBlue,
                      inactiveTrackColor: _sysBlue.withOpacity(0.15),
                      thumbColor: _sysBlue,
                      overlayColor: _sysBlue.withOpacity(0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: _kilo.clamp(30, 200),
                      min: 30,
                      max: 200,
                      onChanged: (v) => setState(() => _kilo = double.parse(v.toStringAsFixed(1))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hedef Seçimi
                  Text('OBJECTIVE', style: GoogleFonts.rajdhani(color: _sysText, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _hedefChip("yag_yakma", "YAĞ YAK", "CUT", Icons.local_fire_department, _sysRed)),
                      const SizedBox(width: 12),
                      Expanded(child: _hedefChip("kilo_alma", "KAS İNŞA", "BULK", Icons.fitness_center, _sysGreen)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Hesapla Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _hesapla,
                      icon: const Icon(Icons.bolt, color: _sysBlue, size: 22),
                      label: Text('ANALYZE MACROS', style: GoogleFonts.orbitron(color: _sysBlue, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sysBlue.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: _sysBlue, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ──────────────────────────────────
            // 2. SONUÇ PANELİ (Animasyonlu)
            // ──────────────────────────────────
            if (_sonuc != null) ...[
              // Toplam Kalori Göstergesi
              AnimatedBuilder(
                animation: _animDeger,
                builder: (context, child) {
                  int animKalori = (topKalori * _animDeger.value).round();
                  return HologramCard(
                    neonRenk: _sysBlue,
                    child: Column(
                      children: [
                        Text('DAILY ENERGY TARGET', style: GoogleFonts.orbitron(color: _sysText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$animKalori',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: _sysBlue.withOpacity(0.6), blurRadius: 20)],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text('KCAL', style: GoogleFonts.rajdhani(color: _sysBlue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _secilenHedef == "yag_yakma" ? 'Fat Burning Protocol Active' : 'Muscle Building Protocol Active',
                          style: GoogleFonts.rajdhani(
                            color: _secilenHedef == "yag_yakma" ? _sysRed : _sysGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Makro Çemberleri
              Text('MACRO DISTRIBUTION', style: GoogleFonts.orbitron(color: _sysBlue, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 15),
              AnimatedBuilder(
                animation: _animDeger,
                builder: (context, child) {
                  return Row(
                    children: [
                      Expanded(child: _makroCemberi("PROTEIN", topP, pYuzde * _animDeger.value, _sysBlue, "g")),
                      const SizedBox(width: 10),
                      Expanded(child: _makroCemberi("FAT", topF, fYuzde * _animDeger.value, _sysGold, "g")),
                      const SizedBox(width: 10),
                      Expanded(child: _makroCemberi("CARBS", topC, cYuzde * _animDeger.value, _sysGreen, "g")),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),

              // Makro Detay Barları
              AnimatedBuilder(
                animation: _animDeger,
                builder: (context, child) {
                  return HologramCard(
                    neonRenk: _sysBlue,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        _makroDetayBar("Protein", topP, topGram, _sysBlue, "${topP * 4} kcal"),
                        const SizedBox(height: 12),
                        _makroDetayBar("Fat (Yağ)", topF, topGram, _sysGold, "${topF * 9} kcal"),
                        const SizedBox(height: 12),
                        _makroDetayBar("Carbs (Karb)", topC, topGram, _sysGreen, "${topC * 4} kcal"),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // ──────────────────────────────────
              // 3. YEMEK PLANI KARTLARI
              // ──────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.menu_book, color: _sysGold, size: 20),
                  const SizedBox(width: 8),
                  Text('MEAL PLAN', style: GoogleFonts.orbitron(color: _sysGold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: _sysGold.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _secilenHedef == "yag_yakma" ? "CUT MODE" : "BULK MODE",
                      style: GoogleFonts.rajdhani(color: _sysGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              ...ogunler.map((ogun) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _ogunKartiWidget(ogun),
              )),

              const SizedBox(height: 20),

              // Uyarı Notu
              HologramCard(
                neonRenk: _sysText.withOpacity(0.3),
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: _sysText, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bu plan tahmini değerler içerir. Kişisel ihtiyaçlarınıza göre miktarları ayarlayabilirsiniz.',
                        style: GoogleFonts.rajdhani(color: _sysText, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // YARDIMCI WİDGET'LAR
  // ══════════════════════════════════════════════

  // ─── Hedef Seçim Chip'i ───
  Widget _hedefChip(String hedefKey, String baslik, String altBaslik, IconData ikon, Color renk) {
    bool secili = _secilenHedef == hedefKey;
    return GestureDetector(
      onTap: () => setState(() => _secilenHedef = hedefKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: secili ? renk.withOpacity(0.12) : const Color(0xFF0F172A),
          border: Border.all(color: secili ? renk : _sysText.withOpacity(0.2), width: secili ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
          boxShadow: secili ? [BoxShadow(color: renk.withOpacity(0.15), blurRadius: 12)] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: secili ? renk : _sysText, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: GoogleFonts.rajdhani(color: secili ? Colors.white : _sysText, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(altBaslik, style: TextStyle(color: secili ? renk : _sysText.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Makro Çember Widget'ı ───
  Widget _makroCemberi(String label, int gram, double yuzde, Color renk, String birim) {
    return HologramCard(
      neonRenk: renk,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _MakroCemberPainter(ilerleme: yuzde, renk: renk),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(gram * _animDeger.value).round()}',
                      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(birim, style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: GoogleFonts.orbitron(color: renk, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text(
            '${(yuzde / (_animDeger.value == 0 ? 1 : _animDeger.value) * 100).round()}%',
            style: TextStyle(color: _sysText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─── Makro Detay Bar ───
  Widget _makroDetayBar(String label, int gram, int topGram, Color renk, String kcalStr) {
    double oran = topGram > 0 ? (gram / topGram) : 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Text('${gram}g', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(kcalStr, style: TextStyle(color: _sysText, fontSize: 11)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(3)),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (oran * _animDeger.value).clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: renk,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [BoxShadow(color: renk.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Öğün Kartı Widget'ı ───
  Widget _ogunKartiWidget(_Ogun ogun) {
    int toplamKal = ogun.yemekler.fold(0, (toplam, y) => toplam + y.kalori);

    return HologramCard(
      neonRenk: ogun.renk,
      padding: EdgeInsets.zero,
      child: Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          initiallyExpanded: false,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ogun.renk.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ogun.renk.withOpacity(0.3)),
            ),
            child: Icon(ogun.ikon, color: ogun.renk, size: 22),
          ),
          title: Text(
            ogun.baslik,
            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          subtitle: Row(
            children: [
              Text(ogun.altBaslik, style: GoogleFonts.rajdhani(color: _sysText, fontSize: 12, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('$toplamKal kcal', style: GoogleFonts.rajdhani(color: ogun.renk, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          iconColor: ogun.renk,
          collapsedIconColor: _sysText,
          children: [
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),
            ...ogun.yemekler.map((y) => _yemekSatiri(y, ogun.renk)),
          ],
        ),
      ),
    );
  }

  // ─── Yemek Satırı ───
  Widget _yemekSatiri(_YemekOnerisi yemek, Color vurguRenk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: vurguRenk.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(yemek.ikon, color: vurguRenk.withOpacity(0.7), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(yemek.ad, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(yemek.makroBilgisi, style: TextStyle(color: _sysText.withOpacity(0.7), fontSize: 11, letterSpacing: 0.5)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: vurguRenk.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${yemek.kalori}',
              style: GoogleFonts.orbitron(color: vurguRenk, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// CUSTOM PAINTER: Makro Çemberi
// ══════════════════════════════════════════════
class _MakroCemberPainter extends CustomPainter {
  final double ilerleme;
  final Color renk;

  _MakroCemberPainter({required this.ilerleme, required this.renk});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Arka plan halkası
    final arkaPlan = Paint()
      ..color = renk.withOpacity(0.1)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, arkaPlan);

    // İlerleme halkası
    final ilerlemeP = Paint()
      ..color = renk
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * ilerleme.clamp(0.0, 1.0),
      false,
      ilerlemeP,
    );

    // Parlama efekti
    final parlama = Paint()
      ..color = renk.withOpacity(0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * ilerleme.clamp(0.0, 1.0),
      false,
      parlama,
    );
  }

  @override
  bool shouldRepaint(covariant _MakroCemberPainter oldDelegate) =>
      oldDelegate.ilerleme != ilerleme || oldDelegate.renk != renk;
}

// ══════════════════════════════════════════════
// YARDIMCI VERİ SINIFLARI (Ekran İçi)
// ══════════════════════════════════════════════
class _Ogun {
  final String baslik;
  final String altBaslik;
  final IconData ikon;
  final Color renk;
  final List<_YemekOnerisi> yemekler;

  const _Ogun({
    required this.baslik,
    required this.altBaslik,
    required this.ikon,
    required this.renk,
    required this.yemekler,
  });
}

class _YemekOnerisi {
  final String ad;
  final int kalori;
  final String makroBilgisi;
  final IconData ikon;

  const _YemekOnerisi(this.ad, this.kalori, this.makroBilgisi, this.ikon);
}
