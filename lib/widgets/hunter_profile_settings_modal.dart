// lib/widgets/hunter_profile_settings_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/system_memory.dart';
import '../core/translation_manager.dart';

class HunterProfileSettingsModal extends StatefulWidget {
  final VoidCallback onSaved;

  const HunterProfileSettingsModal({super.key, required this.onSaved});

  static Future<void> show(BuildContext context, {required VoidCallback onSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HunterProfileSettingsModal(onSaved: onSaved),
    );
  }

  @override
  State<HunterProfileSettingsModal> createState() => _HunterProfileSettingsModalState();
}

class _HunterProfileSettingsModalState extends State<HunterProfileSettingsModal> {
  static const Color sysCyan = Color(0xFF38BDF8);
  static const Color sysGold = Color(0xFFF59E0B);
  static const Color sysRed = Color(0xFFEF4444);
  static const Color sysGreen = Color(0xFF10B981);
  static const Color sysDarkBg = Color(0xFF070B14);
  static const Color sysTextMuted = Color(0xFF94A3B8);

  late TextEditingController _boyCtrl;
  late TextEditingController _kiloCtrl;
  late TextEditingController _hedefKiloCtrl;
  late TextEditingController _yasCtrl;

  late String _cinsiyet;
  late String _hedef;
  late String _zorluk;
  late String _ekipman;
  late bool _dovusAktif;
  late List<String> _seciliBranslar;
  late List<String> _seciliEklemKisitlari;

  final List<String> _hedefSecenekleri = [
    'Kilo Ver (Yağ Yak)',
    'Kilo Al (Kas İnşa Et)',
    'Mevcut Kilonu Koru',
  ];

  final List<String> _zorlukSecenekleri = [
    'Normal',
    'Hard',
    'Hell',
    'Monster',
  ];

  final List<String> _ekipmanSecenekleri = [
    'Salon',
    'Ev (Dambıl)',
    'Vücut Ağırlığı',
  ];

  final List<String> _bransSecenekleri = [
    'Boks',
    'Kickboks',
    'Muay Thai',
    'MMA',
    'BJJ / Güreş',
  ];

  final List<String> _eklemSecenekleri = [
    'Omuz',
    'Bel',
    'Diz',
    'Dirsek',
    'Bilek',
  ];

  @override
  void initState() {
    super.initState();
    _boyCtrl = TextEditingController(text: SystemMemory.boy.toInt().toString());
    _kiloCtrl = TextEditingController(text: SystemMemory.kilo.toStringAsFixed(1));
    _hedefKiloCtrl = TextEditingController(
      text: SystemMemory.hedefKilo > 0 ? SystemMemory.hedefKilo.toStringAsFixed(1) : '',
    );
    _yasCtrl = TextEditingController(text: SystemMemory.yas.toString());

    _cinsiyet = SystemMemory.cinsiyet.isNotEmpty ? SystemMemory.cinsiyet : 'Erkek';
    _hedef = _hedefSecenekleri.contains(SystemMemory.aktifHedef)
        ? SystemMemory.aktifHedef
        : _hedefSecenekleri.first;
    _zorluk = _zorlukSecenekleri.contains(SystemMemory.aktifZorluk)
        ? SystemMemory.aktifZorluk
        : 'Normal';
    _ekipman = _ekipmanSecenekleri.contains(SystemMemory.ekipmanTuru)
        ? SystemMemory.ekipmanTuru
        : 'Salon';
    _dovusAktif = SystemMemory.dovusSporuYapiyorMu;
    _seciliBranslar = List<String>.from(SystemMemory.dovusBranslari);
    _seciliEklemKisitlari = List<String>.from(SystemMemory.eklemKisiti);
  }

  @override
  void dispose() {
    _boyCtrl.dispose();
    _kiloCtrl.dispose();
    _hedefKiloCtrl.dispose();
    _yasCtrl.dispose();
    super.dispose();
  }

  void _kaydet() async {
    final boyVal = double.tryParse(_boyCtrl.text.trim()) ?? SystemMemory.boy;
    final kiloVal = double.tryParse(_kiloCtrl.text.trim()) ?? SystemMemory.kilo;
    final hedefKiloVal = double.tryParse(_hedefKiloCtrl.text.trim()) ?? SystemMemory.hedefKilo;
    final yasVal = int.tryParse(_yasCtrl.text.trim()) ?? SystemMemory.yas;

    SystemMemory.boy = boyVal;
    SystemMemory.hedefKilo = hedefKiloVal;
    SystemMemory.cinsiyet = _cinsiyet;
    SystemMemory.dogumTarihi = DateTime(DateTime.now().year - yasVal, 1, 1);
    SystemMemory.aktifHedef = _hedef;
    SystemMemory.aktifZorluk = _zorluk;
    SystemMemory.ekipmanTuru = _ekipman;
    SystemMemory.dovusSporuYapiyorMu = _dovusAktif;
    SystemMemory.dovusBranslari = _seciliBranslar;
    if (_seciliBranslar.isNotEmpty) {
      SystemMemory.dovusBransi = _seciliBranslar.first;
    }
    SystemMemory.eklemKisiti = _seciliEklemKisitlari;

    // Tartı ve metabolik motoru güncelle
    SystemMemory.tartiGuncelle(kiloVal);
    await SystemMemory.kaydet();

    widget.onSaved();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TranslationManager.isTurkish
                ? '⚡ [SİSTEM PROTOKOLÜ GÜNCELLENDİ VE SENKRONİZE EDİLDİ]'
                : '⚡ [SYSTEM PROTOCOL UPDATED & SYNCHRONIZED]',
            style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          backgroundColor: sysCyan.withValues(alpha: 0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: BoxDecoration(
        color: sysDarkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: sysCyan.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sysCyan.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: sysCyan, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    TranslationManager.isTurkish
                        ? '[ AVCI PROTOKOL AYARLARI ]'
                        : '[ HUNTER PROTOCOL SETTINGS ]',
                    style: GoogleFonts.orbitron(
                      color: sysCyan,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: sysTextMuted, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            TranslationManager.isTurkish
                ? 'Sistem biyometri, hedef, ekipman ve dövüş protokollerini buradan anında yeniden yapılandırabilirsin.'
                : 'Reconfigure your biometric, goal, equipment, and combat directives here.',
            style: const TextStyle(color: sysTextMuted, fontSize: 11),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // Scrollable Content
          Expanded(
            child: ListView(
              children: [
                // 1. BİYOMETRİK PARAMETRELER
                _sectionTitle(
                  TranslationManager.isTurkish ? '1. BİYOMETRİK PARAMETRELER' : '1. BIOMETRIC PARAMETERS',
                  Icons.accessibility_new,
                  sysCyan,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _inputField('Boy (cm)', _boyCtrl, Icons.height)),
                    const SizedBox(width: 10),
                    Expanded(child: _inputField('Kilo (kg)', _kiloCtrl, Icons.monitor_weight_outlined)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _inputField('Hedef Kilo (kg)', _hedefKiloCtrl, Icons.flag_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _inputField('Yaş', _yasCtrl, Icons.calendar_today_outlined)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      TranslationManager.isTurkish ? 'Cinsiyet: ' : 'Gender: ',
                      style: const TextStyle(color: sysTextMuted, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    _choiceChip('Erkek', _cinsiyet == 'Erkek', () => setState(() => _cinsiyet = 'Erkek'), sysCyan),
                    const SizedBox(width: 8),
                    _choiceChip('Kadın', _cinsiyet == 'Kadın', () => setState(() => _cinsiyet = 'Kadın'), sysCyan),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. AVCI HEDEFİ & ZORLUK SEVİYESİ
                _sectionTitle(
                  TranslationManager.isTurkish ? '2. AVCI HEDEFİ & ZORLUK SEVİYESİ' : '2. GOAL & DIFFICULTY LEVEL',
                  Icons.track_changes,
                  sysGold,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _hedefSecenekleri.map((h) {
                    final selected = _hedef == h;
                    return _choiceChip(h, selected, () => setState(() => _hedef = h), sysGold);
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  TranslationManager.isTurkish ? 'Zorluk Derecesi (DDA):' : 'Difficulty Tier (DDA):',
                  style: const TextStyle(color: sysTextMuted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _zorlukSecenekleri.map((z) {
                    final selected = _zorluk == z;
                    Color color = sysCyan;
                    if (z == 'Hard') color = sysGold;
                    if (z == 'Hell') color = sysRed;
                    if (z == 'Monster') color = const Color(0xFFA855F7);
                    return _choiceChip(z, selected, () => setState(() => _zorluk = z), color);
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 3. EKİPMAN DURUMU
                _sectionTitle(
                  TranslationManager.isTurkish ? '3. EKİPMAN ENVANTERİ' : '3. EQUIPMENT INVENTORY',
                  Icons.fitness_center,
                  sysGreen,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _ekipmanSecenekleri.map((e) {
                    final selected = _ekipman == e;
                    return _choiceChip(e, selected, () => setState(() => _ekipman = e), sysGreen);
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 4. DÖVÜŞ SANATI & BRANŞLAR
                _sectionTitle(
                  TranslationManager.isTurkish ? '4. DÖVÜŞ SANATLARI PROTOKOLÜ' : '4. COMBAT ARTS PROTOCOL',
                  Icons.sports_mma,
                  sysRed,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationManager.isTurkish ? 'Dövüş Sporu Eğitimi Aktif' : 'Combat Training Active',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _dovusAktif,
                      activeThumbColor: sysRed,
                      onChanged: (val) => setState(() => _dovusAktif = val),
                    ),
                  ],
                ),
                if (_dovusAktif) ...[
                  const SizedBox(height: 8),
                  Text(
                    TranslationManager.isTurkish ? 'Aktif Branşlar (Çoklu Seçim):' : 'Active Disciplines:',
                    style: const TextStyle(color: sysTextMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bransSecenekleri.map((b) {
                      final selected = _seciliBranslar.contains(b);
                      return _choiceChip(b, selected, () {
                        setState(() {
                          if (selected) {
                            if (_seciliBranslar.length > 1) _seciliBranslar.remove(b);
                          } else {
                            _seciliBranslar.add(b);
                          }
                        });
                      }, sysRed);
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),

                // 5. EKLEM KORUMASI & KISITLAR
                _sectionTitle(
                  TranslationManager.isTurkish ? '5. EKLEM KORUMASI & KISITLARI' : '5. JOINT RECOVERY RESTRICTIONS',
                  Icons.healing,
                  const Color(0xFFA855F7),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _eklemSecenekleri.map((ek) {
                    final selected = _seciliEklemKisitlari.contains(ek);
                    return _choiceChip(ek, selected, () {
                      setState(() {
                        if (selected) {
                          _seciliEklemKisitlari.remove(ek);
                        } else {
                          _seciliEklemKisitlari.add(ek);
                        }
                      });
                    }, const Color(0xFFA855F7));
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Action Button
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _kaydet,
              icon: const Icon(Icons.bolt, color: Colors.black, size: 20),
              label: Text(
                TranslationManager.isTurkish
                    ? 'SİSTEM PROTOKOLÜNÜ SENKRONİZE ET'
                    : 'SYNCHRONIZE SYSTEM PROTOCOL',
                style: GoogleFonts.orbitron(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: sysCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: sysTextMuted, fontSize: 11),
        prefixIcon: Icon(icon, color: sysCyan, size: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white12),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: sysCyan),
          borderRadius: BorderRadius.circular(4),
        ),
        filled: true,
        fillColor: Colors.black38,
      ),
    );
  }

  Widget _choiceChip(String label, bool isSelected, VoidCallback onTap, Color activeColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.black45,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : sysTextMuted,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
