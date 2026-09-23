// lib/widgets/exercise_detail_modal.dart
// ============================================================
// SOLO LEVELING AVCI TAKTİK & FORM MODALI
// Egzersizin hedef kaslarını, dövüş katkısını, form kurallarını,
// YouTube rehberini ve alternatif değiştirme seçeneklerini sunar.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/exercise_coach.dart';
import '../core/youtube_helper.dart';
import '../core/audio_system.dart';
import '../core/translation_manager.dart';

class ExerciseDetailModal extends StatefulWidget {
  final String gorevAdi;
  final int? gun;
  final int? index;
  final VoidCallback? onSwapped;

  const ExerciseDetailModal({
    super.key,
    required this.gorevAdi,
    this.gun,
    this.index,
    this.onSwapped,
  });

  static void show(
    BuildContext context, {
    required String gorevAdi,
    int? gun,
    int? index,
    VoidCallback? onSwapped,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailModal(
        gorevAdi: gorevAdi,
        gun: gun,
        index: index,
        onSwapped: onSwapped,
      ),
    );
  }

  @override
  State<ExerciseDetailModal> createState() => _ExerciseDetailModalState();
}

class _ExerciseDetailModalState extends State<ExerciseDetailModal> {
  static const Color _sysBlue = Color(0xFF38BDF8);
  static const Color _sysGold = Color(0xFFEAB308);
  static const Color _sysRed = Color(0xFFEF4444);
  static const Color _sysDarkBg = Color(0xFF070B14);
  static const Color _sysTextMuted = Color(0xFF94A3B8);

  bool _alternatifModu = false;
  late ExerciseTactics _taktik;

  @override
  void initState() {
    super.initState();
    _taktik = ExerciseCoach.getTactics(widget.gorevAdi);
  }

  Future<void> _hareketDegistir(String yeniHareket) async {
    if (widget.gun != null && widget.index != null) {
      final basarili = await ExerciseCoach.swapExercise(
        gun: widget.gun!,
        index: widget.index!,
        yeniHareketAdi: yeniHareket,
      );
      if (basarili) {
        AudioSystem.playTransition();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(TranslationManager.isTurkish ? '[SİSTEM] Hareket başarıyla güncellendi: $yeniHareket' : '[SYSTEM] Exercise updated successfully: $yeniHareket'),
              backgroundColor: _sysBlue,
            ),
          );
          widget.onSwapped?.call();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _sysDarkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: _sysBlue.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _sysBlue.withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 2,
          )
        ],
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst bar tutamacı
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Başlık & Kategori
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _sysBlue.withValues(alpha: 0.1),
                    border: Border.all(color: _sysBlue.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.fitness_center, color: _sysBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _taktik.ad,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _sysGold.withValues(alpha: 0.15),
                          border: Border.all(color: _sysGold.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _taktik.bolge.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            color: _sysGold,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: _sysTextMuted, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Görünüm Değiştirme (Taktik Kartı vs Alternatifler)
            if (!_alternatifModu) ...[
              // 1. Hedef Kaslar Kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: _sysBlue, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'HEDEF KASLAR',
                          style: GoogleFonts.orbitron(
                            color: _sysBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _taktik.hedefKaslar,
                      style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 2. Dövüş Aktarımı Kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _sysGold.withValues(alpha: 0.08),
                  border: Border.all(color: _sysGold.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_mma, color: _sysGold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'DÖVÜŞ & ATLETİK KATKI',
                          style: GoogleFonts.orbitron(
                            color: _sysGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _taktik.dovusKatkisi,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. 3 Altın Form Kuralı
              Text(
                'KRİTİK FORM KURALLARI',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ..._taktik.formKurallari.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _sysBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: _sysBlue, width: 1),
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: _sysBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(color: _sysTextMuted, fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),

              // Eklem Koruma Uyarısı
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _sysRed.withValues(alpha: 0.1),
                  border: Border.all(color: _sysRed.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: _sysRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _taktik.eklemKorumaNotu,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ALTERNATİF EGZERSİZ SEÇİM LİSTESİ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EŞDEĞER ALTERNATİFLER',
                    style: GoogleFonts.orbitron(
                      color: _sysBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back, color: _sysTextMuted, size: 16),
                    label: Text(TranslationManager.isTurkish ? 'Geri' : 'Back', style: const TextStyle(color: _sysTextMuted, fontSize: 12)),
                    onPressed: () => setState(() => _alternatifModu = false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                TranslationManager.isTurkish
                    ? 'Salondaki alet doluysa veya ekleminizi korumak istiyorsanız aşağıdaki muadil hareketlerden birini seçin:'
                    : 'If gym equipment is busy or to protect joints, select one of the equivalent exercises below:',
                style: const TextStyle(color: _sysTextMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ..._taktik.alternatifler.map((alt) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: _sysBlue.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: const Icon(Icons.swap_horiz, color: _sysBlue, size: 22),
                    title: Text(
                      alt,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sysBlue.withValues(alpha: 0.2),
                        side: const BorderSide(color: _sysBlue),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () => _hareketDegistir(alt),
                      child: Text(TranslationManager.isTurkish ? 'SEÇ' : 'SELECT', style: const TextStyle(color: _sysBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),

            // AKSİYON BUTONLARI (YouTube & Alternatif Değiştir)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      YoutubeHelper.videoAc(widget.gorevAdi, context: context);
                    },
                    icon: const Icon(Icons.play_circle_fill, color: Color(0xFFEF4444), size: 20),
                    label: const Text(
                      'YOUTUBE REHBERİ',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                if (widget.gun != null && widget.index != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sysBlue.withValues(alpha: 0.15),
                        side: const BorderSide(color: _sysBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        setState(() => _alternatifModu = !_alternatifModu);
                      },
                      icon: Icon(
                        _alternatifModu ? Icons.info_outline : Icons.swap_horizontal_circle_outlined,
                        color: _sysBlue,
                        size: 20,
                      ),
                      label: Text(
                        _alternatifModu ? 'TAKTIK BİLGİ' : 'ALTERNATİFLER',
                        style: const TextStyle(
                          color: _sysBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Taktik Bilgi Modalı ve YouTube Butonunu birleştiren kompakt satır widget'ı
class ExerciseTacticalButtons extends StatelessWidget {
  final String gorevAdi;
  final int? gun;
  final int? index;
  final VoidCallback? onSwapped;
  final double size;

  const ExerciseTacticalButtons({
    super.key,
    required this.gorevAdi,
    this.gun,
    this.index,
    this.onSwapped,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.info_outline, color: const Color(0xFF38BDF8), size: size),
          tooltip: 'Avcı Taktik Kartı & Alternatifler',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          splashRadius: size + 6,
          onPressed: () {
            ExerciseDetailModal.show(
              context,
              gorevAdi: gorevAdi,
              gun: gun,
              index: index,
              onSwapped: onSwapped,
            );
          },
        ),
        YoutubeHelper.buildYouTubeButton(
          gorevAdi: gorevAdi,
          size: size,
        ),
      ],
    );
  }
}

