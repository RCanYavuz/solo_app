// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import '../core/translation_manager.dart';
import '../core/youtube_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int seciliMod = 0; 
  DateTime seciliTarih = DateTime.now(); 
  DateTime gosterilenAy = DateTime(DateTime.now().year, DateTime.now().month); 
  int gosterilenYil = DateTime.now().year; 

  late ScrollController _scrollController;
  
  List<String> get aylar => TranslationManager.isTurkish
      ? ["", "Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
      : ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  List<String> get gunAdlari => TranslationManager.isTurkish
      ? ["", "Pzt", "Sal", "Çar", "Per", "Cum", "Cts", "Paz"]
      : ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  List<String> get gunKisa => TranslationManager.isTurkish
      ? ["Pzt", "Sal", "Çar", "Per", "Cum", "Cts", "Paz"]
      : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  static const Color sysBlue = Color(0xFF38BDF8); 
  static const Color sysDarkBg = Color(0xFF030712); 
  static const Color sysTextMuted = Color(0xFF94A3B8); 
  static const Color sysRed = Color(0xFFEF4444); 

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 15 * 80.0); 
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTopToggle() {
    return Container(
      margin: const EdgeInsets.all(15), padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4), border: Border.all(color: sysBlue.withValues(alpha: 0.3))),
      child: Row(
        children: [
          _buildToggleBtn(TranslationManager.get('calendar_strip'), 0),
          _buildToggleBtn(TranslationManager.get('calendar_month'), 1),
          _buildToggleBtn(TranslationManager.get('calendar_year'), 2),
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
          duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: aktif ? sysBlue.withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(2), border: Border.all(color: aktif ? sysBlue : Colors.transparent, width: 1)),
          child: Center(child: Text(text, style: TextStyle(color: aktif ? sysBlue : sysTextMuted, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1))),
        ),
      ),
    );
  }

  Widget _buildSeritTakvim() {
    DateTime bugun = DateTime.now();
    DateTime baslangicTarihi = bugun.subtract(const Duration(days: 15));

    return Container(
      height: 100,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12, width: 1))),
      child: ListView.builder(
        controller: _scrollController, scrollDirection: Axis.horizontal, itemCount: 45,
        itemBuilder: (context, index) {
          DateTime islenenTarih = baslangicTarihi.add(Duration(days: index));
          bool seciliMi = islenenTarih.year == seciliTarih.year && islenenTarih.month == seciliTarih.month && islenenTarih.day == seciliTarih.day;
          bool bugunMu = islenenTarih.year == bugun.year && islenenTarih.month == bugun.month && islenenTarih.day == bugun.day;

          List<Gorev> p = SystemMemory.haftalikPlan[islenenTarih.weekday]!;
          bool gorevVar = p.isNotEmpty;

          return GestureDetector(
            onTap: () => setState(() => seciliTarih = islenenTarih),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), width: 65, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                color: seciliMi ? sysBlue.withValues(alpha: 0.1) : const Color(0xFF070B14), 
                borderRadius: BorderRadius.circular(4), 
                border: Border.all(color: seciliMi ? sysBlue : (bugunMu ? Colors.white54 : Colors.transparent), width: 1)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(aylar[islenenTarih.month].toUpperCase(), style: TextStyle(color: seciliMi ? sysBlue : sysTextMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${islenenTarih.day}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(gunAdlari[islenenTarih.weekday].toUpperCase(), style: TextStyle(color: seciliMi ? sysBlue : sysTextMuted, fontSize: 10)),
                  const SizedBox(height: 4),
                  if (gorevVar) Container(width: 4, height: 4, decoration: const BoxDecoration(color: sysBlue, shape: BoxShape.circle)),
                  if (!gorevVar) const SizedBox(height: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAylikTakvim() {
    int daysInMonth = DateUtils.getDaysInMonth(gosterilenAy.year, gosterilenAy.month);
    int firstWeekday = DateTime(gosterilenAy.year, gosterilenAy.month, 1).weekday; 
    int offset = firstWeekday - 1; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: sysBlue, size: 24), onPressed: () => setState(() => gosterilenAy = DateTime(gosterilenAy.year, gosterilenAy.month - 1))),
              Text('${aylar[gosterilenAy.month].toUpperCase()} ${gosterilenAy.year}', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
              IconButton(icon: const Icon(Icons.chevron_right, color: sysBlue, size: 24), onPressed: () => setState(() => gosterilenAy = DateTime(gosterilenAy.year, gosterilenAy.month + 1))),
            ],
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: gunKisa.map((g) => Text(g.toUpperCase(), style: const TextStyle(color: sysTextMuted, fontSize: 10, fontWeight: FontWeight.bold))).toList()),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.8),
            itemCount: daysInMonth + offset,
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox(); 
              DateTime islenen = DateTime(gosterilenAy.year, gosterilenAy.month, index - offset + 1);
              bool seciliMi = islenen.year == seciliTarih.year && islenen.month == seciliTarih.month && islenen.day == seciliTarih.day;
              bool bugunMu = islenen.year == DateTime.now().year && islenen.month == DateTime.now().month && islenen.day == DateTime.now().day;

              List<Gorev> p = SystemMemory.haftalikPlan[islenen.weekday]!;
              bool gorevVar = p.isNotEmpty;

              return GestureDetector(
                onTap: () => setState(() => seciliTarih = islenen),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: seciliMi ? sysBlue.withValues(alpha: 0.1) : const Color(0xFF070B14), 
                    borderRadius: BorderRadius.circular(4), 
                    border: Border.all(color: seciliMi ? sysBlue : (bugunMu ? Colors.white54 : Colors.white12), width: 1)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${islenen.day}', style: TextStyle(color: Colors.white, fontWeight: seciliMi || bugunMu ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                      const SizedBox(height: 2),
                      if (gorevVar) Container(width: 3, height: 3, decoration: const BoxDecoration(color: sysBlue, shape: BoxShape.circle))
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

  Widget _buildYillikTakvim() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: sysBlue, size: 24), onPressed: () => setState(() => gosterilenYil--)),
              Text('$gosterilenYil', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
              IconButton(icon: const Icon(Icons.chevron_right, color: sysBlue, size: 24), onPressed: () => setState(() => gosterilenYil++)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: 12,
            itemBuilder: (context, index) {
              int ayNo = index + 1;
              bool seciliAyMi = seciliTarih.year == gosterilenYil && seciliTarih.month == ayNo;
              return GestureDetector(
                onTap: () { setState(() { gosterilenAy = DateTime(gosterilenYil, ayNo); seciliMod = 1; }); },
                child: Container(decoration: BoxDecoration(color: seciliAyMi ? sysBlue.withValues(alpha: 0.1) : const Color(0xFF070B14), borderRadius: BorderRadius.circular(4), border: Border.all(color: seciliAyMi ? sysBlue : Colors.white12)), child: Center(child: Text(aylar[ayNo].toUpperCase(), style: GoogleFonts.rajdhani(color: seciliAyMi ? sysBlue : sysTextMuted, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)))),
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
    
    DateTime simdi = DateTime.now();
    bool isToday = seciliTarih.year == simdi.year && seciliTarih.month == simdi.month && seciliTarih.day == simdi.day;

    List<Map<String, dynamic>> seciliGunIdmanlari = SystemMemory.idmanGecmisi.where((idman) {
      DateTime idmanTarihi = DateTime.parse(idman['tarih']);
      return idmanTarihi.year == seciliTarih.year && idmanTarihi.month == seciliTarih.month && idmanTarihi.day == seciliTarih.day;
    }).toList();

    // =========================================================
    // YENİ: GEÇMİŞ GÜNÜN KALORİSİNİ ARŞİVDEN (YEMEK GEÇMİŞİ) BUL
    // =========================================================
    int gecmisKalori = 0;
    bool gecmisKayitBulundu = false;

    if (!isToday) {
      String seciliTarihStr = "${seciliTarih.year}-${seciliTarih.month.toString().padLeft(2,'0')}-${seciliTarih.day.toString().padLeft(2,'0')}";
      for (var kayit in SystemMemory.yemekGecmisi) {
        if (kayit['tarih'] == seciliTarihStr) {
          gecmisKalori = kayit['toplamKalori'] ?? 0;
          gecmisKayitBulundu = true;
          break;
        }
      }
    }

    return ValueListenableBuilder<String>(
      valueListenable: SystemMemory.appLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: sysDarkBg,
          appBar: AppBar(
            title: Text(
              TranslationManager.get('calendar_title'),
              style: GoogleFonts.rajdhani(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4.0),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildTopToggle(), 
              if (seciliMod == 0)
                _buildSeritTakvim()
              else
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: seciliMod == 1 ? _buildAylikTakvim() : _buildYillikTakvim(),
                  ),
                ),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFF030712), border: Border(top: BorderSide(color: Colors.white12))),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text('${seciliTarih.day} ${aylar[seciliTarih.month]} ${seciliTarih.year} - ${gunAdlari[seciliHaftaninGunu].toUpperCase()}', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 5),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(TranslationManager.get('calendar_protocol'), style: const TextStyle(color: sysTextMuted, fontSize: 10, letterSpacing: 2)),
                          if (SystemMemory.gunlukHedefKalori > 0)
                            Text(
                              isToday 
                                ? '${TranslationManager.get('calendar_energy')}: ${SystemMemory.bugunAlinanKalori} / ${SystemMemory.gunlukHedefKalori} KCAL'
                                : (gecmisKayitBulundu 
                                    ? '${TranslationManager.get('calendar_logged_energy')}: $gecmisKalori / ${SystemMemory.gunlukHedefKalori} KCAL'
                                    : '${TranslationManager.get('calendar_target')}: ${SystemMemory.gunlukHedefKalori} KCAL'), 
                              style: TextStyle(
                                color: isToday 
                                  ? (SystemMemory.bugunAlinanKalori > SystemMemory.gunlukHedefKalori ? sysRed : sysBlue)
                                  : (gecmisKayitBulundu && gecmisKalori > SystemMemory.gunlukHedefKalori ? sysRed : sysBlue), 
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 1
                              )
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      if (seciliGunProgrami.isEmpty)
                        Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text(TranslationManager.get('calendar_rest_day'), textAlign: TextAlign.center, style: const TextStyle(color: sysTextMuted, fontSize: 12))))
                      else
                        ListView.builder(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          itemCount: seciliGunProgrami.length,
                          itemBuilder: (context, index) {
                            Gorev gorev = seciliGunProgrami[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(color: const Color(0xFF070B14), border: Border(left: BorderSide(color: sysBlue, width: 2)), borderRadius: BorderRadius.circular(4)),
                              child: ListTile(
                                title: Text(gorev.ad, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                subtitle: Text(gorev.tip == "Fiziksel" ? TranslationManager.get('dash_phy') : TranslationManager.get('dash_mnt'), style: const TextStyle(color: sysTextMuted, fontSize: 10)),
                                trailing: YoutubeHelper.buildYouTubeButton(gorevAdi: gorev.ad, size: 20),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 20),
                      
                      Text(TranslationManager.get('calendar_dungeon_logs'), style: GoogleFonts.orbitron(color: sysRed, fontSize: 10, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      if (seciliGunIdmanlari.isEmpty)
                        Text(TranslationManager.get('calendar_no_raids'), style: const TextStyle(color: sysTextMuted, fontSize: 12))
                      else
                        ...seciliGunIdmanlari.map((idman) {
                          DateTime t = DateTime.parse(idman['tarih']);
                          String saat = "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: const Color(0xFF070B14), border: Border.all(color: sysRed.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)),
                            child: ListTile(
                              leading: const Icon(Icons.whatshot, color: sysRed, size: 20),
                              title: Text('${TranslationManager.get('calendar_raid_at')} $saat', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              subtitle: Text('${TranslationManager.get('dash_duration')}: ${idman['dakika']} ${TranslationManager.get('dash_min')} | ${TranslationManager.get('dash_quests_done')}: ${idman['gorevSayisi']}', style: const TextStyle(color: sysTextMuted, fontSize: 12)),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}