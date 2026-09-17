// lib/models/food_model.dart

class TuketilenYemek {
  String ad; 
  int kalori;
  int protein;
  int karbonhidrat;
  int yag;
  
  TuketilenYemek(
    this.ad, 
    this.kalori, {
    this.protein = 0,
    this.karbonhidrat = 0,
    this.yag = 0,
  });

  Map<String, dynamic> toJson() => {
    'ad': ad, 
    'kalori': kalori,
    'protein': protein,
    'karbonhidrat': karbonhidrat,
    'yag': yag,
  };
  
  factory TuketilenYemek.fromJson(Map<String, dynamic> json) => TuketilenYemek(
    json['ad'] ?? '', 
    json['kalori'] ?? 0,
    protein: (json['protein'] as num?)?.toInt() ?? 0,
    karbonhidrat: (json['karbonhidrat'] as num?)?.toInt() ?? 0,
    yag: (json['yag'] as num?)?.toInt() ?? 0,
  );
}