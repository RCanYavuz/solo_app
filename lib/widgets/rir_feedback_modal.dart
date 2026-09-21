// lib/widgets/rir_feedback_modal.dart
// ============================================================
// SOLO LEVELING RIR & PERFORMANS GERİ BİLDİRİM MODALI
// Egzersiz veya setler tamamlandığında avcının tükeniş
// seviyesini (RIR 0-1, 2-3, 4+) ve eklem durumunu sorgular.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/progressive_overload_engine.dart';
import '../controllers/system_memory.dart';
import '../core/audio_system.dart';

class RirFeedbackModal extends StatefulWidget {
  final String egzersizAdi;
  final double sonKilo;
  final int sonTekrar;
  final VoidCallback? onTamamlandi;

  const RirFeedbackModal({
    super.key,
    required this.egzersizAdi,
    required this.sonKilo,
    required this.sonTekrar,
    this.onTamamlandi,
  });

  /// Modalı açmak için statik yardımcı fonksiyon
  static Future<OverloadKaydi?> goster(
    BuildContext context, {
    required String egzersizAdi,
    required double sonKilo,
    required int sonTekrar,
    VoidCallback? onTamamlandi,
  }) {
    return showDialog<OverloadKaydi>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RirFeedbackModal(
        egzersizAdi: egzersizAdi,
        sonKilo: sonKilo,
        sonTekrar: sonTekrar,
        onTamamlandi: onTamamlandi,
      ),
    );
  }

  @override
  State<RirFeedbackModal> createState() => _RirFeedbackModalState();
}

class _RirFeedbackModalState extends State<RirFeedbackModal> {
  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color sysRed = Color(0xFFEF4444);
  static const Color sysAmber = Color(0xFFF59E0B);
  static const Color sysGreen = Color(0xFF10B981);
  static const Color darkCard = Color(0xFF070B14);

  bool _eklemAgrisiVar = false;
  OverloadKaydi? _hesaplananSonuc;

  void _rirSec(int rir) {
    final sonuc = ProgressiveOverloadEngine.hesaplaGelecekSeans(
      egzersizAdi: widget.egzersizAdi,
      sonKilo: widget.sonKilo,
      sonTekrar: widget.sonTekrar,
      rir: rir,
      agriVarMi: _eklemAgrisiVar,
    );

    SystemMemory.overloadKaydiEkle(sonuc);
    AudioSystem.playLevelUp();

    setState(() {
      _hesaplananSonuc = sonuc;
    });

    if (widget.onTamamlandi != null) {
      widget.onTamamlandi!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF030712).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hesaplananSonuc != null
                ? sysGreen.withValues(alpha: 0.8)
                : (_eklemAgrisiVar ? sysRed.withValues(alpha: 0.8) : sysBlue.withValues(alpha: 0.6)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (_hesaplananSonuc != null
                      ? sysGreen
                      : (_eklemAgrisiVar ? sysRed : sysBlue))
                  .withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: _hesaplananSonuc != null ? _buildSonucEkrani() : _buildSoruEkrani(),
        ),
      ),
    );
  }

  /// Henüz seçim yapılmadığında RIR butonlarını gösterir
  Widget _buildSoruEkrani() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Başlık
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: sysBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sysBlue.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.bolt, color: sysBlue, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '[ SİSTEM ANALİZİ ]',
                    style: GoogleFonts.orbitron(
                      color: sysBlue,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Egzersiz Geri Bildirimi',
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
              icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Hareket Bilgi Rozeti
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: sysBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.egzersizAdi,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sysBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.sonKilo > 0
                      ? '${widget.sonKilo.toStringAsFixed(widget.sonKilo.truncateToDouble() == widget.sonKilo ? 0 : 1)} kg x ${widget.sonTekrar}'
                      : 'BW x ${widget.sonTekrar}',
                  style: GoogleFonts.orbitron(
                    color: sysBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Soru
        Text(
          'Tükenişe (Failure) kaç tekrarın kaldı?',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFE2E8F0),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        // 3 RIR Butonu
        _buildRirSecenek(
          rir: 4,
          icon: Icons.flash_on,
          baslik: 'RIR 4+ (Çok Kolay)',
          aciklama: 'Direnç hafif geldi. Gelecek seans +2.5 kg artır!',
          renk: sysAmber,
        ),
        const SizedBox(height: 8),

        _buildRirSecenek(
          rir: 2,
          icon: Icons.shield,
          baslik: 'RIR 2-3 (İdeal Hipertrofi)',
          aciklama: 'Hedef aralıkta bitti. Gelecek seans +1 tekrar hedefle.',
          renk: sysBlue,
        ),
        const SizedBox(height: 8),

        _buildRirSecenek(
          rir: 0,
          icon: Icons.local_fire_department,
          baslik: 'RIR 0-1 (Tükeniş / Aşırı Zor)',
          aciklama: 'Maksimum efor. Ağırlığı koru, toparlanmaya odaklan.',
          renk: sysRed,
        ),
        const SizedBox(height: 14),

        // Eklem Ağrısı Toggle'ı
        InkWell(
          onTap: () {
            setState(() {
              _eklemAgrisiVar = !_eklemAgrisiVar;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _eklemAgrisiVar ? sysRed.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _eklemAgrisiVar ? sysRed : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _eklemAgrisiVar ? Icons.check_box : Icons.check_box_outline_blank,
                  color: _eklemAgrisiVar ? sysRed : const Color(0xFF94A3B8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ Eklemlerde batma / ağrı hissettim (İkame iste)',
                    style: TextStyle(
                      color: _eklemAgrisiVar ? sysRed : const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: _eklemAgrisiVar ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Alt Atla Butonu
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Şimdilik Atla',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Seçim yapıldıktan sonra sistemin verdiği direktifi gösterir
  Widget _buildSonucEkrani() {
    final sonuc = _hesaplananSonuc!;
    final Color anaRenk = sonuc.agriBildirildiMi
        ? sysRed
        : (sonuc.sonRir >= 4 ? sysAmber : sysGreen);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: anaRenk, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '[ SİSTEM DİREKTİFİ ONAYLANDI ]',
                style: GoogleFonts.orbitron(
                  color: anaRenk,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Direktif Kartı
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: darkCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: anaRenk.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sonuc.sistemMesaji,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Gelecek Seans Hedefi:',
                      style: GoogleFonts.rajdhani(color: const Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ),
                  Text(
                    sonuc.onerilenKilo > 0
                        ? '${sonuc.onerilenKilo.toStringAsFixed(1)} kg x ${sonuc.onerilenTekrar}'
                        : 'BW x ${sonuc.onerilenTekrar}',
                    style: GoogleFonts.orbitron(
                      color: anaRenk,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (sonuc.onerilenAlternatif != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Güvenli İkame Egzersiz:',
                        style: GoogleFonts.rajdhani(color: sysRed, fontSize: 12),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        sonuc.onerilenAlternatif!,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kapat Butonu
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: anaRenk.withValues(alpha: 0.2),
            side: BorderSide(color: anaRenk),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, sonuc),
          child: Text(
            'EMRİ KABUL ET & DEVAM ET',
            style: GoogleFonts.orbitron(
              color: anaRenk,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRirSecenek({
    required int rir,
    required IconData icon,
    required String baslik,
    required String aciklama,
    required Color renk,
  }) {
    return InkWell(
      onTap: () => _rirSec(rir),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: darkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: renk.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: renk.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: renk, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    aciklama,
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: renk.withValues(alpha: 0.5), size: 12),
          ],
        ),
      ),
    );
  }
}
