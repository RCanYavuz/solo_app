// lib/models/task_model.dart

class SetKaydi {
  int setNo;
  double kilo;
  int tekrar;
  bool tamamlandi;

  SetKaydi({
    required this.setNo,
    required this.kilo,
    required this.tekrar,
    this.tamamlandi = false,
  });

  Map<String, dynamic> toJson() => {
    'setNo': setNo,
    'kilo': kilo,
    'tekrar': tekrar,
    'tamamlandi': tamamlandi,
  };

  factory SetKaydi.fromJson(Map<String, dynamic> json) => SetKaydi(
    setNo: json['setNo'] ?? 1,
    kilo: (json['kilo'] as num?)?.toDouble() ?? 0.0,
    tekrar: json['tekrar'] ?? 0,
    tamamlandi: json['tamamlandi'] ?? false,
  );
}

class Gorev {
  String ad; 
  bool yapildiMi; 
  String tip;
  List<SetKaydi> setler;
  
  Gorev(this.ad, this.yapildiMi, this.tip, [List<SetKaydi>? setler])
      : setler = setler ?? [];

  // Hafızaya yazmak için Metne (JSON) çevir
  Map<String, dynamic> toJson() => {
    'ad': ad, 
    'yapildiMi': yapildiMi, 
    'tip': tip,
    'setler': setler.map((s) => s.toJson()).toList(),
  };
  
  // Hafızadan okumak için Metinden (JSON) Objeye çevir
  factory Gorev.fromJson(Map<String, dynamic> json) {
    List<SetKaydi> setList = [];
    if (json['setler'] != null) {
      try {
        setList = (json['setler'] as List)
            .map((s) => SetKaydi.fromJson(s))
            .toList();
      } catch (_) {}
    }
    return Gorev(
      json['ad'], 
      json['yapildiMi'], 
      json['tip'],
      setList,
    );
  }
}