// lib/models/task_model.dart

class Gorev {
  String ad; 
  bool yapildiMi; 
  String tip;
  
  Gorev(this.ad, this.yapildiMi, this.tip);

  // Hafızaya yazmak için Metne (JSON) çevir
  Map<String, dynamic> toJson() => {
    'ad': ad, 
    'yapildiMi': yapildiMi, 
    'tip': tip
  };
  
  // Hafızadan okumak için Metinden (JSON) Objeye çevir
  factory Gorev.fromJson(Map<String, dynamic> json) => Gorev(
    json['ad'], 
    json['yapildiMi'], 
    json['tip']
  );
}