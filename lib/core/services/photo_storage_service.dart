// lib/core/services/photo_storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Görselleri (Profil, Avatar, İlerleme Galerisi) SharedPreferences'e Base64
/// olarak yazmak yerine doğrudan yerel dosya sistemine kaydeden ve yükleyen servis.
class PhotoStorageService {
  PhotoStorageService._();
  static final PhotoStorageService instance = PhotoStorageService._();

  static Directory? _cachedPhotoDir;

  /// Görsellerin saklandığı klasörü getirir veya oluşturur
  Future<Directory> get photoDirectory async {
    if (_cachedPhotoDir != null && await _cachedPhotoDir!.exists()) {
      return _cachedPhotoDir!;
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDocDir.path}${Platform.pathSeparator}solo_photos');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cachedPhotoDir = dir;
    return dir;
  }

  /// Profil fotoğrafını yerel dosyaya kaydeder
  Future<String> saveProfilePhoto(Uint8List bytes) async {
    final dir = await photoDirectory;
    final file = File('${dir.path}${Platform.pathSeparator}profile_user.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Avatar fotoğrafını yerel dosyaya kaydeder
  Future<String> saveAvatarPhoto(Uint8List bytes) async {
    final dir = await photoDirectory;
    final file = File('${dir.path}${Platform.pathSeparator}avatar_hunter.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// İlerleme fotoğrafını yerel dosyaya kaydeder
  Future<String> saveProgressPhoto(Uint8List bytes, String id) async {
    final dir = await photoDirectory;
    final progressDir = Directory('${dir.path}${Platform.pathSeparator}progress');
    if (!await progressDir.exists()) {
      await progressDir.create(recursive: true);
    }
    final file = File('${progressDir.path}${Platform.pathSeparator}prog_$id.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Verilen dosya yolundan görsel byte dizisini okur
  Future<Uint8List?> loadPhotoBytes(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty) return null;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('[PhotoStorageService] Okuma hatası ($filePath): $e');
    }
    return null;
  }

  /// Dosyayı diskten siler
  Future<void> deletePhoto(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty) return;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('[PhotoStorageService] Silme hatası ($filePath): $e');
    }
  }

  /// Eski Base64 formatındaki veriyi yerel dosyaya dönüştürür (Migration)
  Future<String?> migrateBase64ToFile(String base64Str, String filename) async {
    if (base64Str.trim().isEmpty) return null;
    try {
      final bytes = base64Decode(base64Str);
      final dir = await photoDirectory;
      final file = File('${dir.path}${Platform.pathSeparator}$filename');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('[PhotoStorageService] Migration hatası ($filename): $e');
      return null;
    }
  }
}
