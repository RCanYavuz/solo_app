// lib/models/workout_model.dart
// ============================================================
// ANTRENMAN KÜTÜPHANESİ VERİ MODELİ
// Her bir egzersiz satırını ve YouTube bağlantısını tutar.
// ============================================================

class Egzersiz {
  String ad;
  String setTekrar;       // Örn: "4x12", "100", "3x60s"
  String youtubeArama;    // YouTube'da aranacak kelime
  String kategori;        // "Fiziksel" veya "Zihinsel"

  Egzersiz({
    required this.ad,
    required this.setTekrar,
    this.youtubeArama = "",
    this.kategori = "Fiziksel",
  });

  Map<String, dynamic> toJson() => {
    'ad': ad,
    'setTekrar': setTekrar,
    'youtubeArama': youtubeArama,
    'kategori': kategori,
  };

  factory Egzersiz.fromJson(Map<String, dynamic> json) => Egzersiz(
    ad: json['ad'] ?? '',
    setTekrar: json['setTekrar'] ?? '',
    youtubeArama: json['youtubeArama'] ?? '',
    kategori: json['kategori'] ?? 'Fiziksel',
  );

  Egzersiz kopyala() => Egzersiz(
    ad: ad,
    setTekrar: setTekrar,
    youtubeArama: youtubeArama,
    kategori: kategori,
  );
}
