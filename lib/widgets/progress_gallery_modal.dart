// lib/widgets/progress_gallery_modal.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/system_memory.dart';
import '../core/audio_system.dart';

class ProgressGalleryModal extends StatefulWidget {
  const ProgressGalleryModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ProgressGalleryModal(),
    );
  }

  @override
  State<ProgressGalleryModal> createState() => _ProgressGalleryModalState();
}

class _ProgressGalleryModalState extends State<ProgressGalleryModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color gold = Color(0xFFEAB308);
  static const Color darkCard = Color(0xFF070B14);
  static const Color textMuted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _yeniFotoEkle() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    final kiloController =
        TextEditingController(text: SystemMemory.kilo.toStringAsFixed(1));
    final notController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: sysBlue, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'LOG TRANSFORMATION ENTRY',
          style: GoogleFonts.orbitron(color: sysBlue, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(bytes, height: 140, width: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kiloController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Mevcut Kilo (kg)',
                labelStyle: TextStyle(color: textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: sysBlue)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Avcı Notu (Opsiyonel)',
                labelStyle: TextStyle(color: textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: sysBlue)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: sysBlue),
            onPressed: () async {
              final kilo = double.tryParse(kiloController.text.replaceAll(',', '.')) ?? SystemMemory.kilo;
              await SystemMemory.ilerlemeFotoEkle(
                fotoBytes: bytes,
                kilo: kilo,
                not: notController.text.trim(),
              );
              AudioSystem.playSuccess();
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('KAYDET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = SystemMemory.ilerlemeFotolari;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF030712),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: gold, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Top Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.photo_library, color: gold, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      "TRANSFORMATION VAULT",
                      style: GoogleFonts.orbitron(
                        color: gold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo, color: sysBlue),
                  tooltip: 'Yeni Fotoğraf Ekle',
                  onPressed: _yeniFotoEkle,
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: gold,
            labelColor: gold,
            unselectedLabelColor: textMuted,
            tabs: const [
              Tab(text: "TIMELINE"),
              Tab(text: "BEFORE & AFTER"),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. TIMELINE
                list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.collections, color: Colors.white24, size: 50),
                            const SizedBox(height: 12),
                            const Text(
                              "Henüz ilerleme fotoğrafı kaydedilmedi.",
                              style: TextStyle(color: textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _yeniFotoEkle,
                              icon: const Icon(Icons.camera_alt, color: sysBlue, size: 16),
                              label: const Text("İLK FOTOĞRAFI EKLE", style: TextStyle(color: sysBlue)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: sysBlue),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          // Reverse chronological
                          final item = list[list.length - 1 - index];
                          final realIndex = list.length - 1 - index;
                          final date = DateTime.tryParse(item['tarih'] ?? '') ?? DateTime.now();
                          final kilo = item['kilo'] ?? 0.0;
                          final notMetin = item['not'] ?? '';
                          final bytes = base64Decode(item['fotoBase64'] ?? '');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: darkCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.memory(
                                    bytes,
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${date.day}.${date.month}.${date.year}',
                                            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: sysBlue.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: sysBlue.withValues(alpha: 0.4)),
                                            ),
                                            child: Text(
                                              '$kilo KG',
                                              style: const TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (notMetin.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          notMetin,
                                          style: const TextStyle(color: textMuted, fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                                  onPressed: () async {
                                    await SystemMemory.ilerlemeFotoSil(realIndex);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // 2. BEFORE & AFTER
                list.length < 2
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.compare, color: gold, size: 50),
                              const SizedBox(height: 14),
                              Text(
                                "[ BEFORE / AFTER PROTOCOL ]",
                                style: GoogleFonts.orbitron(color: gold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Fiziksel gelişim karşılaştırmasını aktif etmek için en az 2 gelişim fotoğrafı kaydedilmiş olmalıdır.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _yeniFotoEkle,
                                icon: const Icon(Icons.add_a_photo, color: gold, size: 16),
                                label: const Text("YENİ GİRİŞ EKLE", style: TextStyle(color: gold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: gold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildBeforeAfterView(list),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterView(List<Map<String, dynamic>> list) {
    final first = list.first;
    final last = list.last;

    final firstDate = DateTime.tryParse(first['tarih'] ?? '') ?? DateTime.now();
    final lastDate = DateTime.tryParse(last['tarih'] ?? '') ?? DateTime.now();
    final firstKilo = (first['kilo'] as num?)?.toDouble() ?? 0.0;
    final lastKilo = (last['kilo'] as num?)?.toDouble() ?? 0.0;
    final diffKilo = lastKilo - firstKilo;
    final days = lastDate.difference(firstDate).inDays;

    final firstBytes = base64Decode(first['fotoBase64'] ?? '');
    final lastBytes = base64Decode(last['fotoBase64'] ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stat Comparison Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: gold.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('BAŞLANGIÇ', style: TextStyle(color: textMuted, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text('$firstKilo KG', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.white12),
                Column(
                  children: [
                    const Text('GÜNCEL', style: TextStyle(color: textMuted, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text('$lastKilo KG', style: GoogleFonts.orbitron(color: sysBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.white12),
                Column(
                  children: [
                    const Text('DEĞİŞİM', style: TextStyle(color: textMuted, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      '${diffKilo >= 0 ? '+' : ''}${diffKilo.toStringAsFixed(1)} KG',
                      style: GoogleFonts.orbitron(
                        color: diffKilo == 0 ? Colors.white : (diffKilo < 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.white12),
                Column(
                  children: [
                    const Text('SÜRE', style: TextStyle(color: textMuted, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text('$days GÜN', style: GoogleFonts.orbitron(color: gold, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Split Photos
          Row(
            children: [
              // Before
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('BEFORE (${firstDate.day}.${firstDate.month}.${firstDate.year})',
                          style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        firstBytes,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // After
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: gold.withValues(alpha: 0.5)),
                      ),
                      child: Text('AFTER (${lastDate.day}.${lastDate.month}.${lastDate.year})',
                          style: GoogleFonts.orbitron(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        lastBytes,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
