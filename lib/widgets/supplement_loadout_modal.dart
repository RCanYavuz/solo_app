// lib/widgets/supplement_loadout_modal.dart
// ============================================================
// SOLO LEVELING SUPLEMENT KUŞANMA (LOADOUT) PENCERESİ
// Avcının aldığı takviyeleri 4 yuvaya kuşanmasını ve
// antrenman/su hedeflerine sinerji uygulamasını sağlar.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/supplement_engine.dart';
import '../controllers/system_memory.dart';
import '../core/audio_system.dart';
import '../core/translation_manager.dart';

class SupplementLoadoutModal extends StatefulWidget {
  const SupplementLoadoutModal({super.key});

  static Future<void> goster(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const SupplementLoadoutModal(),
    );
  }

  @override
  State<SupplementLoadoutModal> createState() => _SupplementLoadoutModalState();
}

class _SupplementLoadoutModalState extends State<SupplementLoadoutModal> {
  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color sysGold = Color(0xFFF59E0B);
  static const Color sysGreen = Color(0xFF10B981);
  static const Color darkCard = Color(0xFF070B14);

  IconData _iconBul(String kod) {
    switch (kod) {
      case 'flash_on':
        return Icons.flash_on;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kusanilanlar = SystemMemory.kusanilanSuplementler;
    final int toplamEkSu = SupplementEngine.hesaplaToplamSuArtisi(kusanilanlar);
    final double toplamHacim = SupplementEngine.hesaplaToplamHacimBonusu(kusanilanlar);

    final oneriler = SupplementEngine.hesaplaOneriler(
      kilo: SystemMemory.kilo,
      haftalikBoksDakikasi: 60, // Boks seansları göz önüne alınır
      haftalikAgirlikDakikasi: SystemMemory.toplamIdmanDakikasi > 0 ? SystemMemory.toplamIdmanDakikasi : 90,
      hedef: SystemMemory.aktifHedef,
      kusanilanIdler: kusanilanlar,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFF030712).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sysBlue.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: sysBlue.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sysBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sysBlue.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.shield, color: sysBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationManager.isTurkish ? '[ METABOLİK DONANIM ]' : '[ METABOLIC LOADOUT ]',
                          style: GoogleFonts.orbitron(
                            color: sysBlue,
                            fontSize: 12,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          TranslationManager.isTurkish ? 'Suplement Kuşanma Yuvaları' : 'Supplement Loadout Slots',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Aktif Sinerji Özet Kartı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sysBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(TranslationManager.isTurkish ? 'SU HEDEFİ ETKİSİ' : 'WATER TARGET IMPACT', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          '+$toplamEkSu ml',
                          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 30, color: Colors.white12),
                    Column(
                      children: [
                        Text(TranslationManager.isTurkish ? 'İDMAN HACİM TOLERANSI' : 'VOLUME TOLERANCE', style: GoogleFonts.orbitron(color: sysGold, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          '+${toplamHacim.toStringAsFixed(0)}%',
                          style: GoogleFonts.orbitron(color: sysGold, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Suplement Listesi (4 Donanım Yuvası)
              Text(
                TranslationManager.isTurkish ? 'KUŞANILABİLİR TAKVİYELER' : 'EQUIPPABLE SUPPLEMENTS',
                style: GoogleFonts.orbitron(color: const Color(0xFF94A3B8), fontSize: 11, letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),

              ...SupplementEngine.katalog.map((item) {
                final bool kusanildi = kusanilanlar.contains(item.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: darkCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kusanildi ? sysGreen.withValues(alpha: 0.8) : Colors.white12,
                      width: kusanildi ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (kusanildi ? sysGreen : sysBlue).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_iconBul(item.iconKodu), color: kusanildi ? sysGreen : sysBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.ad,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.dozaj,
                              style: TextStyle(color: sysBlue.withValues(alpha: 0.8), fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.antrenmanEtkisi,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (kusanildi) {
                              SystemMemory.suplementCikar(item.id);
                              AudioSystem.playTransition();
                            } else {
                              SystemMemory.suplementKusan(item.id);
                              AudioSystem.playLevelUp();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: (kusanildi ? sysGreen : sysBlue).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kusanildi ? sysGreen : sysBlue),
                          ),
                          child: Text(
                            kusanildi
                                ? (TranslationManager.isTurkish ? '✓ KUŞANILDI' : '✓ EQUIPPED')
                                : (TranslationManager.isTurkish ? 'KUŞAN' : 'EQUIP'),
                            style: GoogleFonts.orbitron(
                              color: kusanildi ? sysGreen : sysBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Sistem Tavsiyeleri
              Text(
                TranslationManager.isTurkish ? 'SİSTEM AKILLI TAVSİYELERİ' : 'SYSTEM SMART RECOMMENDATIONS',
                style: GoogleFonts.orbitron(color: sysGold, fontSize: 11, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sysGold.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: oneriler
                      .map((oneri) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              oneri,
                              style: GoogleFonts.rajdhani(
                                color: const Color(0xFFE2E8F0),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sysBlue.withValues(alpha: 0.2),
                  side: const BorderSide(color: sysBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  TranslationManager.isTurkish ? 'KAYDET & DEVAM ET' : 'SAVE & PROCEED',
                  style: GoogleFonts.orbitron(color: sysBlue, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
