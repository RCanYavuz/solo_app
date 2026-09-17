// lib/models/inventory_item_model.dart

class InventoryItem {
  final String id;
  final String ad;
  final String aciklama;
  int adet;
  final String aksiyon;
  final int ikonKodu;
  final int renkDegeri;

  InventoryItem({
    required this.id,
    required this.ad,
    required this.aciklama,
    this.adet = 1,
    required this.aksiyon,
    required this.ikonKodu,
    required this.renkDegeri,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ad': ad,
    'aciklama': aciklama,
    'adet': adet,
    'aksiyon': aksiyon,
    'ikonKodu': ikonKodu,
    'renkDegeri': renkDegeri,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] ?? '',
    ad: json['ad'] ?? '',
    aciklama: json['aciklama'] ?? '',
    adet: (json['adet'] as num?)?.toInt() ?? 1,
    aksiyon: json['aksiyon'] ?? '',
    ikonKodu: (json['ikonKodu'] as num?)?.toInt() ?? 0xe25a,
    renkDegeri: (json['renkDegeri'] as num?)?.toInt() ?? 0xFF38BDF8,
  );
}
