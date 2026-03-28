import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/system_memory.dart';
import '../controllers/system_memory.dart';
import '../models/task_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 0: Günlük/Haftalık (Şerit), 1: Aylık (Grid), 2: Yıllık (Kuşbakışı)
  int seciliMod = 0; 
  
  DateTime seciliTarih = DateTime.now(); // Detayları gösterilen gün
  DateTime gosterilenAy = DateTime(DateTime.now().year, DateTime.now().month); // Aylık görünümde gezilen ay
  int gosterilenYil = DateTime.now().year; // Yıllık görünümde gezilen yıl

  late ScrollController _scrollController;
  
  final List<String> aylar = ["", "Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"];
  final List<String> gunAdlari = ["", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
  final List<String> gunKisa = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 15 * 80.0); 
  }

  // --- ÜST MENÜ (GÖRÜNÜM DEĞİŞTİRİCİ) ---
  Widget _buildTopToggle() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
      child: Row(
        children: [
          _buildToggleBtn('Şerit', 0),
          _buildToggleBtn('Aylık', 1),
          _buildToggleBtn('Yıllık', 2),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String text, int modIndex) {
    bool aktif = seciliMod == modIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => seciliMod = modIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: aktif ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: aktif ? Colors.cyanAccent : Colors.transparent)),
          child: Center(child: Text(text, style: TextStyle(color: aktif ? Colors.cyanAccent : Colors.white54, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  // --- MOD 0: GÜNLÜK/HAFTALIK ŞERİT ---
  Widget _buildSeritTakvim() {
    DateTime bugun = DateTime.now();
    DateTime baslangicTarihi = bugun.subtract(const Duration(days: 15));

    return Container(
      height: 120,
      decoration: BoxDecoration(border: const Border(bottom: BorderSide(color: Colors.white12, width: 1)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
      child: ListView.builder(
        controller: _scrollController, scrollDirection: Axis.horizontal, itemCount: 45,
        itemBuilder: (context, index) {
          DateTime islenenTarih = baslangicTarihi.add(Duration(days: index));
          bool seciliMi = islenenTarih.year == seciliTarih.year && islenenTarih.month == seciliTarih.month && islenenTarih.day == seciliTarih.day;
          bool bugunMu = islenenTarih.year == bugun.year && islenenTarih.month == bugun.month && islenenTarih.day == bugun.day;

          List<Gorev> p = SystemMemory.haftalikPlan[islenenTarih.weekday]!;
          bool fizikselVar = p.any((g) => g.tip == "Fiziksel");
          bool zihinselVar = p.any((g) => g.tip == "Zihinsel");

          return GestureDetector(
            onTap: () => setState(() => seciliTarih = islenenTarih),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), width: 70, margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
              decoration: BoxDecoration(color: seciliMi ? Colors.cyanAccent.withOpacity(0.2) : const Color(0xFF1F2937), borderRadius: BorderRadius.circular(15), border: Border.all(color: seciliMi ? Colors.cyanAccent : (bugunMu ? Colors.amberAccent : Colors.transparent), width: seciliMi || bugunMu ? 2 : 0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(aylar[islenenTarih.month], style: TextStyle(color: seciliMi ? Colors.cyanAccent : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('${islenenTarih.day}', style: GoogleFonts.orbitron(color: bugunMu && !seciliMi ? Colors.amberAccent : Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(gunAdlari[islenenTarih.weekday], style: TextStyle(color: seciliMi ? Colors.cyanAccent : Colors.white54, fontSize: 12)),
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (fizikselVar) Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6, decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle)),
                    if (zihinselVar) Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6, decoration: const BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle)),
                    if (!fizikselVar && !zihinselVar) const SizedBox(height: 6),
                  ])
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- MOD 1: AYLIK GRID (GOOGLE CALENDAR TARZI) ---
  Widget _buildAylikTakvim() {
    int daysInMonth = DateUtils.getDaysInMonth(gosterilenAy.year, gosterilenAy.month);
    int firstWeekday = DateTime(gosterilenAy.year, gosterilenAy.month, 1).weekday; // 1=Pzt, 7=Paz
    int offset = firstWeekday - 1; // Boşluk sayısı

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          // Ay Değiştirme Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: Colors.cyanAccent, size: 30), onPressed: () => setState(() => gosterilenAy = DateTime(gosterilenAy.year, gosterilenAy.month - 1))),
              Text('${aylar[gosterilenAy.month]} ${gosterilenAy.year}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.chevron_right, color: Colors.cyanAccent, size: 30), onPressed: () => setState(() => gosterilenAy = DateTime(gosterilenAy.year, gosterilenAy.month + 1))),
            ],
          ),
          const SizedBox(height: 10),
          // Gün İsimleri
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: gunKisa.map((g) => Text(g, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))).toList()),
          const SizedBox(height: 10),
          // Takvim Grid'i
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.8),
            itemCount: daysInMonth + offset,
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox(); // Boş günler
              
              DateTime islenen = DateTime(gosterilenAy.year, gosterilenAy.month, index - offset + 1);
              bool seciliMi = islenen.year == seciliTarih.year && islenen.month == seciliTarih.month && islenen.day == seciliTarih.day;
              bool bugunMu = islenen.year == DateTime.now().year && islenen.month == DateTime.now().month && islenen.day == DateTime.now().day;

              List<Gorev> p = SystemMemory.haftalikPlan[islenen.weekday]!;
              bool fizikselVar = p.any((g) => g.tip == "Fiziksel");
              bool zihinselVar = p.any((g) => g.tip == "Zihinsel");

              return GestureDetector(
                onTap: () => setState(() => seciliTarih = islenen),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: seciliMi ? Colors.cyanAccent.withOpacity(0.2) : const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: seciliMi ? Colors.cyanAccent : (bugunMu ? Colors.amberAccent : Colors.white12), width: seciliMi || bugunMu ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${islenen.day}', style: TextStyle(color: bugunMu && !seciliMi ? Colors.amberAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        if (fizikselVar) Container(margin: const EdgeInsets.symmetric(horizontal: 1), width: 5, height: 5, decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle)),
                        if (zihinselVar) Container(margin: const EdgeInsets.symmetric(horizontal: 1), width: 5, height: 5, decoration: const BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle)),
                      ])
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- MOD 2: YILLIK GÖRÜNÜM ---
  Widget _buildYillikTakvim() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          // Yıl Değiştirme Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: Colors.cyanAccent, size: 30), onPressed: () => setState(() => gosterilenYil--)),
              Text('$gosterilenYil', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.chevron_right, color: Colors.cyanAccent, size: 30), onPressed: () => setState(() => gosterilenYil++)),
            ],
          ),
          const SizedBox(height: 10),
          // 12 Aylık Grid
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: 12,
            itemBuilder: (context, index) {
              int ayNo = index + 1;
              bool seciliAyMi = seciliTarih.year == gosterilenYil && seciliTarih.month == ayNo;
              
              return GestureDetector(
                onTap: () {
                  // Yıllık görünümden bir aya tıklayınca, o ayı Aylık moda geçirir!
                  setState(() {
                    gosterilenAy = DateTime(gosterilenYil, ayNo);
                    seciliMod = 1; // Aylık moda dön
                  });
                },
                child: Container(
                  decoration: BoxDecoration(color: seciliAyMi ? Colors.cyanAccent.withOpacity(0.1) : const Color(0xFF111827), borderRadius: BorderRadius.circular(10), border: Border.all(color: seciliAyMi ? Colors.cyanAccent : Colors.white12)),
                  child: Center(
                    child: Text(aylar[ayNo], style: GoogleFonts.rajdhani(color: seciliAyMi ? Colors.cyanAccent : Colors.white70, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int seciliHaftaninGunu = seciliTarih.weekday;
    List<Gorev> seciliGunProgrami = SystemMemory.haftalikPlan[seciliHaftaninGunu]!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text('SİSTEM: GÜNLÜK PLAN', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)), backgroundColor: const Color(0xFF0A0E17), elevation: 0),
      body: Column(
        children: [
          _buildTopToggle(), // Mod Seçici
          
          // --- ÜST KISIM: TAKVİMLER ---
          // Ekran küçülürse diye takvim kısmını kaydırılabilir yaptık
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (seciliMod == 0) _buildSeritTakvim(),
                  if (seciliMod == 1) _buildAylikTakvim(),
                  if (seciliMod == 2) _buildYillikTakvim(),
                ],
              ),
            ),
          ),

          // --- ALT KISIM: SEÇİLİ GÜNÜN DETAYLARI ---
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF0A0E17), border: const Border(top: BorderSide(color: Colors.white12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${seciliTarih.day} ${aylar[seciliTarih.month]} ${seciliTarih.year} - ${gunAdlari[seciliHaftaninGunu]}', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  const Text('SİSTEM GÖREV PROTOKOLÜ', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 15),

                  if (seciliGunProgrami.isEmpty)
                    const Expanded(child: Center(child: Text("DİNLENME GÜNÜ\nBu tarihte planlanmış bir Sistem Görevi bulunmuyor.", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent, fontSize: 16)))),

                  if (seciliGunProgrami.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: seciliGunProgrami.length,
                        itemBuilder: (context, index) {
                          Gorev gorev = seciliGunProgrami[index];
                          bool fizikselMi = gorev.tip == "Fiziksel";
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: const Color(0xFF111827), border: Border(left: BorderSide(color: fizikselMi ? Colors.cyanAccent : Colors.purpleAccent, width: 4)), borderRadius: BorderRadius.circular(5)),
                            child: ListTile(
                              leading: Icon(fizikselMi ? Icons.fitness_center : Icons.psychology, color: fizikselMi ? Colors.cyanAccent : Colors.purpleAccent),
                              title: Text(gorev.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(fizikselMi ? 'Fiziksel Gelişim' : 'Zihinsel Gelişim', style: TextStyle(color: fizikselMi ? Colors.cyanAccent.withOpacity(0.7) : Colors.purpleAccent.withOpacity(0.7), fontSize: 12)),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}