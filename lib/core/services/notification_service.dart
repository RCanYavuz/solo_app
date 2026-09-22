// lib/core/services/notification_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Solo Leveling Temalı Yerel Bildirim ve Hatırlatma Servisi
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool isTest = false;

  // Notification IDs
  static const int idSuHatirlatici = 1001;
  static const int idIdmanHatirlatici = 1002;
  static const int idGeceRaporuHatirlatici = 1003;
  static const int idTestBildirimi = 1004;

  // Notification Channels
  static const String channelWaterId = 'solo_water_channel';
  static const String channelWorkoutId = 'solo_workout_channel';
  static const String channelSystemId = 'solo_system_channel';

  /// Servisi başlatır ve bildirim kanallarını konfigüre eder.
  Future<void> init({bool testMode = false}) async {
    if (_isInitialized) return;

    // Test ortamı kontrolü
    if (testMode ||
        Platform.environment.containsKey('FLUTTER_TEST') ||
        kIsWeb) {
      isTest = true;
      _isInitialized = true;
      debugPrint('[NotificationService] Test modunda başlatıldı (Platform kanalları atlandı).');
      return;
    }

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      debugPrint('[NotificationService] Başarıyla başlatıldı.');
    } catch (e) {
      debugPrint('[NotificationService] Başlatma hatası: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Bildirime tıklandı: ${response.payload}');
  }

  /// Bildirim izni ister (Android 13+ ve iOS için)
  Future<bool> izinIste() async {
    if (isTest) return true;
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] İzin isteme hatası: $e');
    }
    return true;
  }

  /// Anlık sistem bildirimi gönderir
  Future<void> anlikBildirimGonder({
    required String title,
    required String body,
    int id = 2000,
    String? payload,
    String channelId = channelSystemId,
    String channelName = 'Solo Sistem Bildirimleri',
  }) async {
    if (isTest) {
      debugPrint('[NotificationService TEST] Bildirim: $title - $body');
      return;
    }

    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Solo Leveling Sistem Direktifleri',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Solo Hunter Alert',
        color: const Color(0xFF38BDF8), // AppColors.systemBlue
      );

      final DarwinNotificationDetails iosDetails =
          const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Anlık bildirim hatası: $e');
    }
  }

  /// Su Hatırlatıcısı (Periyodik veya Zamanlanmış)
  Future<void> suHatirlaticisiPlanla({int intervalHours = 2}) async {
    if (isTest) {
      debugPrint('[NotificationService TEST] Su hatırlatıcısı her $intervalHours saatte bir planlandı.');
      return;
    }

    try {
      // Önce varsa eski su hatırlatıcıyı temizle
      await suHatirlaticisiIptal();

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelWaterId,
        'Solo Hidrasyon Protokolü',
        channelDescription: 'Su takviyesi ve yenilenme direktifleri',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF38BDF8),
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      await _notificationsPlugin.periodicallyShow(
        id: idSuHatirlatici,
        title: '⚠️ [SİSTEM UYARISI: HİDRASYON PROTOKOLÜ]',
        body: 'Avcı, fiziksel dayanıklılığının düşmemesi için su takviyesi yap! (+1 MP)',
        repeatInterval: RepeatInterval.hourly,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[NotificationService] Su hatırlatıcı planlama hatası: $e');
    }
  }

  /// İdman Hatırlatıcısı (Her gün belirlenen saatte zindan çağrısı)
  Future<void> idmanHatirlaticisiPlanla({
    required int hour,
    required int minute,
  }) async {
    if (isTest) {
      debugPrint('[NotificationService TEST] İdman hatırlatıcısı saat $hour:$minute için planlandı.');
      return;
    }

    try {
      await idmanHatirlaticisiIptal();

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelWorkoutId,
        'Solo Zindan Çağrısı',
        channelDescription: 'Günlük antrenman ve fiziksel gelişim hatırlatması',
        importance: Importance.max,
        priority: Priority.high,
        color: const Color(0xFFEF4444), // AppColors.errorRed / dungeon
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id: idIdmanHatirlatici,
        title: '⚔️ [SİSTEM BİLDİRİMİ: ZİNDAN ÇAĞRISI]',
        body: 'Bugünkü günlük görevlerin seni bekliyor. Zindana adım at ve seviye atla!',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('[NotificationService] İdman hatırlatıcı planlama hatası: $e');
    }
  }

  /// Gece Yarısı Öncesi Hesaplaşma Hatırlatıcısı (Saat 22:30)
  Future<void> geceHesaplasmaHatirlaticisiPlanla() async {
    if (isTest) {
      debugPrint('[NotificationService TEST] Gece hesaplaşma hatırlatıcısı planlandı.');
      return;
    }

    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelSystemId,
        'Solo Sistem Hesaplaşması',
        channelDescription: 'Gece yarısı ceza protokolü öncesi son uyarı',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFFF59E0B), // AppColors.questGold
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        22,
        30,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id: idGeceRaporuHatirlatici,
        title: '⏳ [SİSTEM GÖREVİ: GÜNLÜK HESAPLAŞMA]',
        body: 'Gece yarısı hesaplaşması yaklaşıyor. Tamamlanmamış görevlerini kontrol et!',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('[NotificationService] Gece hesaplaşma hatırlatıcısı hatası: $e');
    }
  }

  /// Test bildirimi gönderir
  Future<void> testBildirimiGonder() async {
    await anlikBildirimGonder(
      id: idTestBildirimi,
      title: '⚡ [SİSTEM BAĞLANTISI AKTİF]',
      body: 'Avcı, bildirim entegrasyonu başarıyla kuruldu. Sistem direktifleri iletilecektir.',
    );
  }

  /// Su hatırlatıcısını iptal eder
  Future<void> suHatirlaticisiIptal() async {
    if (isTest) return;
    try {
      await _notificationsPlugin.cancel(id: idSuHatirlatici);
    } catch (e) {
      debugPrint('[NotificationService] Su iptal hatası: $e');
    }
  }

  /// İdman hatırlatıcısını iptal eder
  Future<void> idmanHatirlaticisiIptal() async {
    if (isTest) return;
    try {
      await _notificationsPlugin.cancel(id: idIdmanHatirlatici);
    } catch (e) {
      debugPrint('[NotificationService] İdman iptal hatası: $e');
    }
  }

  /// Tüm zamanlanmış ve bekleyen bildirimleri iptal eder
  Future<void> tumBildirimleriIptalEt() async {
    if (isTest) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('[NotificationService] Tümünü iptal etme hatası: $e');
    }
  }
}
