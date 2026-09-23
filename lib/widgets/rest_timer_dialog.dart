// lib/widgets/rest_timer_dialog.dart
// ============================================================
// SOLO LEVELING SET ARASI DİNLENME SAYACI (MP RECOVERY TIMER)
// Set aralarında dinlenme süresini takip eder, süre dolduğunda
// sesli ve görsel bildirimle avcıyı sıradaki sete çağırır.
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/audio_system.dart';
import '../core/voice_coach_system.dart';
import '../controllers/system_memory.dart';
import '../core/translation_manager.dart';

class RestTimerDialog extends StatefulWidget {
  final int initialSeconds;
  final String? exerciseName;
  final VoidCallback? onComplete;

  const RestTimerDialog({
    super.key,
    this.initialSeconds = 60,
    this.exerciseName,
    this.onComplete,
  });

  static void show(
    BuildContext context, {
    int initialSeconds = 60,
    String? exerciseName,
    VoidCallback? onComplete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RestTimerDialog(
        initialSeconds: initialSeconds,
        exerciseName: exerciseName,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  static const Color _sysBlue = Color(0xFF38BDF8);
  static const Color _sysGold = Color(0xFFEAB308);
  static const Color _sysDarkBg = Color(0xFF070B14);
  static const Color _sysTextMuted = Color(0xFF94A3B8);

  late int _kalanSaniye;
  late int _toplamSaniye;
  Timer? _timer;
  bool _bitti = false;

  @override
  void initState() {
    super.initState();
    _kalanSaniye = widget.initialSeconds;
    _toplamSaniye = widget.initialSeconds;
    VoiceCoachSystem.dinlenmeBasladi(_kalanSaniye, egzersizAdi: widget.exerciseName);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_kalanSaniye > 1) {
        setState(() => _kalanSaniye--);
        if (_kalanSaniye <= 3) {
          VoiceCoachSystem.dinlenmeGeriSayim(_kalanSaniye);
        }
      } else {
        _timer?.cancel();
        setState(() {
          _kalanSaniye = 0;
          _bitti = true;
        });
        VoiceCoachSystem.dinlenmeBitti(egzersizAdi: widget.exerciseName);
        widget.onComplete?.call();
      }
    });
  }

  void _sureAyarla(int saniye) {
    setState(() {
      _kalanSaniye = saniye;
      _toplamSaniye = saniye;
      _bitti = false;
    });
    _startTimer();
  }

  void _sureEkle(int saniye) {
    setState(() {
      _kalanSaniye += saniye;
      _toplamSaniye += saniye;
      _bitti = false;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double ilerleme = _toplamSaniye > 0 ? (_kalanSaniye / _toplamSaniye).clamp(0.0, 1.0) : 0.0;
    final int dakika = _kalanSaniye ~/ 60;
    final int saniye = _kalanSaniye % 60;
    final String sureMetni = '${dakika.toString().padLeft(2, '0')}:${saniye.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: _sysDarkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: _bitti ? _sysGold : _sysBlue.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (_bitti ? _sysGold : _sysBlue).withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 3,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutamaç
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 15),

          // Başlık ve Sesli Koç Anahtarı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _bitti ? TranslationManager.get('rest_complete_title') : TranslationManager.get('rest_mp_recovery_title'),
                style: GoogleFonts.orbitron(
                  color: _bitti ? _sysGold : _sysBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<bool>(
                valueListenable: SystemMemory.sesliKocAktif,
                builder: (ctx, aktif, _) => IconButton(
                  icon: Icon(
                    aktif ? Icons.record_voice_over : Icons.voice_over_off,
                    color: aktif ? _sysBlue : _sysTextMuted,
                    size: 18,
                  ),
                  tooltip: aktif
                      ? (TranslationManager.isTurkish ? 'Sesli Koç Aktif' : 'Voice Coach Active')
                      : (TranslationManager.isTurkish ? 'Sesli Koç Sessiz' : 'Voice Coach Muted'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    SystemMemory.sesliKocAktif.value = !aktif;
                    SystemMemory.kaydet();
                  },
                ),
              ),
            ],
          ),
          if (widget.exerciseName != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.exerciseName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _sysTextMuted, fontSize: 11),
            ),
          ],
          const SizedBox(height: 25),

          // Dairesel Geri Sayım Göstergesi
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: ilerleme,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(_bitti ? _sysGold : _sysBlue),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sureMetni,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _bitti ? TranslationManager.get('rest_ready_badge') : TranslationManager.get('rest_recovery_badge'),
                    style: TextStyle(
                      color: _bitti ? _sysGold : _sysBlue.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Hızlı Süre Seçim Butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _sureChip('30s', 30),
              const SizedBox(width: 8),
              _sureChip('60s', 60),
              const SizedBox(width: 8),
              _sureChip('90s', 90),
              const SizedBox(width: 8),
              _sureChip('120s', 120),
            ],
          ),
          const SizedBox(height: 20),

          // Aksiyon Butonları (+15s ve Kapat/Hazırım)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _sysBlue.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _sureEkle(15),
                  icon: const Icon(Icons.add, color: _sysBlue, size: 16),
                  label: Text(TranslationManager.get('rest_plus_15s'), style: const TextStyle(color: _sysBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_bitti ? _sysGold : _sysBlue).withValues(alpha: 0.2),
                    side: BorderSide(color: _bitti ? _sysGold : _sysBlue, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    AudioSystem.playTransition();
                    Navigator.pop(context);
                  },
                  icon: Icon(_bitti ? Icons.flash_on : Icons.check, color: _bitti ? _sysGold : _sysBlue, size: 18),
                  label: Text(
                    _bitti ? TranslationManager.get('rest_next_set') : TranslationManager.get('rest_ready_btn'),
                    style: TextStyle(
                      color: _bitti ? _sysGold : _sysBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sureChip(String label, int seconds) {
    final bool secili = _toplamSaniye == seconds;
    return GestureDetector(
      onTap: () => _sureAyarla(seconds),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: secili ? _sysBlue.withValues(alpha: 0.2) : const Color(0xFF0F172A),
          border: Border.all(color: secili ? _sysBlue : Colors.white12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: secili ? _sysBlue : _sysTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
