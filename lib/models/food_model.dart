// lib/models/food_model.dart

class TuketilenYemek {
  String ad; 
  int kalori;
  
  TuketilenYemek(this.ad, this.kalori);

  Map<String, dynamic> toJson() => {
    'ad': ad, 
    'kalori': kalori
  };
  
  factory TuketilenYemek.fromJson(Map<String, dynamic> json) => TuketilenYemek(
    json['ad'], 
    json['kalori']
  );
}