import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/unifiedpush.dart';

/// Web Push 推播服務
///
/// 使用 UnifiedPush 接收報導者推播通知
/// 僅在 Android 平台上運作
class PushService {
  PushService._();

  static PushService? _instance;

  /// 取得 PushService 單例
  // ignore: prefer_constructors_over_static_methods
  static PushService get instance {
    _instance ??= PushService._();
    return _instance!;
  }

  static const String _vapidKey =
      'BHkStXEZjGMSdCHolgJAdmREB75lfi42OLNyRt4NRkLu_'
      'FEJYR-7Jv8hho1TSuYxTw2GqpYc3tLrotc55DfaNx0';

  static const String _subscriptionApiUrl =
      'https://go-api.twreporter.org/v1/web-push/subscriptions';

  static const String _prefKeyEnabled = 'push_enabled';
  static const String _prefKeyEndpoint = 'push_endpoint';
  static const String _instanceName = 'tw-reporter';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _enabled = false;
  bool _initialized = false;
  bool _userDisabling = false;
  String? _registrationError;

  /// 狀態變更回調列表
  final List<VoidCallback> _stateListeners = <VoidCallback>[];

  /// 推播是否已啟用
  bool get enabled => _enabled;

  /// 最近一次註冊錯誤
  String? get registrationError => _registrationError;

  /// 當前平台是否支援推播
  bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

  /// 是否有可用的 distributor
  bool _hasDistributor = false;
  bool get hasDistributor => _hasDistributor;

  /// 最近一次點擊通知的 payload
  String? _pendingNotificationPayload;
  String? consumePendingPayload() {
    final payload = _pendingNotificationPayload;
    _pendingNotificationPayload = null;
    return payload;
  }

  /// 新增狀態變更監聽
  void addStateListener(VoidCallback listener) {
    _stateListeners.add(listener);
  }

  /// 移除狀態變更監聽
  void removeStateListener(VoidCallback listener) {
    _stateListeners.remove(listener);
  }

  void _notifyStateChanged() {
    for (final listener in List<VoidCallback>.of(_stateListeners)) {
      listener();
    }
  }

  /// 初始化推播服務
  Future<void> init(List<String> args) async {
    if (_initialized) return;
    _initialized = true;

    if (!isSupported) return;

    // 初始化本地通知
    await _initLocalNotifications();

    // 從偏好設定讀取狀態
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefKeyEnabled) ?? false;

    // 初始化 UnifiedPush（回傳 true 表示之前已儲存 distributor）
    final alreadyRegistered = await UnifiedPush.initialize(
      onNewEndpoint: _onNewEndpoint,
      onRegistrationFailed: _onRegistrationFailed,
      onUnregistered: _onUnregistered,
      onMessage: _onMessage,
    );

    debugPrint('UnifiedPush: init — enabled=$_enabled, '
        'alreadyRegistered=$alreadyRegistered');

    // 每次啟動都必須重新 register，distributor 才會重新遞送 endpoint
    if (_enabled && alreadyRegistered) {
      _hasDistributor = true;
      debugPrint('UnifiedPush: re-registering on startup');
      await UnifiedPush.register(instance: _instanceName, vapid: _vapidKey);
    }
    _notifyStateChanged();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _pendingNotificationPayload = response.payload;
      _notifyStateChanged();
    }
  }

  /// 取得可用的推播提供者列表
  Future<List<String>> getDistributors() async {
    if (!isSupported) return <String>[];
    return UnifiedPush.getDistributors();
  }

  /// 啟用推播通知
  ///
  /// [distributor] 使用者選擇的推播提供者。若為 null，嘗試使用目前或預設提供者。
  Future<bool> enable({String? distributor}) async {
    if (!isSupported) return false;

    debugPrint('UnifiedPush: enable — distributor=$distributor');

    if (distributor != null) {
      await UnifiedPush.saveDistributor(distributor);
    } else {
      final success =
          await UnifiedPush.tryUseCurrentOrDefaultDistributor();
      if (!success) {
        final distributors = await UnifiedPush.getDistributors();
        _hasDistributor = distributors.isNotEmpty;
        if (distributors.isEmpty) {
          _notifyStateChanged();
          return false;
        }
        // 只有一個時自動選擇
        await UnifiedPush.saveDistributor(distributors.first);
      }
    }

    _hasDistributor = true;
    await UnifiedPush.register(
      instance: _instanceName,
      vapid: _vapidKey,
    );

    _enabled = true;
    _registrationError = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, true);
    _notifyStateChanged();
    return true;
  }

  /// 停用推播通知
  Future<void> disable() async {
    if (!isSupported) return;

    _userDisabling = true;
    await UnifiedPush.unregister(_instanceName);
    _userDisabling = false;
    _enabled = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, false);
    await prefs.remove(_prefKeyEndpoint);
    _notifyStateChanged();
  }

  /// UnifiedPush 回調：收到新端點
  void _onNewEndpoint(PushEndpoint endpoint, String instance) {
    debugPrint('UnifiedPush: onNewEndpoint — '
        'instance=$instance, url=${endpoint.url}');
    _enabled = true;
    _registrationError = null;
    _notifyStateChanged();
    unawaited(_subscribeToServer(endpoint));
  }

  /// UnifiedPush 回調：註冊失敗
  void _onRegistrationFailed(FailedReason reason, String instance) {
    debugPrint('UnifiedPush registration failed: $reason');
    _registrationError = '註冊失敗：$reason';
    // 不設 _enabled = false，保留用戶意圖以便重試
    _notifyStateChanged();
  }

  /// UnifiedPush 回調：已取消註冊
  void _onUnregistered(String instance) {
    debugPrint('UnifiedPush unregistered');
    // 只有用戶主動停用才改 _enabled
    if (_userDisabling) {
      _enabled = false;
      _notifyStateChanged();
    }
  }

  /// UnifiedPush 回調：收到推播訊息
  void _onMessage(PushMessage message, String instance) {
    try {
      final content = utf8.decode(message.content);
      debugPrint('UnifiedPush: onMessage — content=$content');
      final data = json.decode(content) as Map<String, dynamic>;
      final title = data['title'] as String? ?? '報導者';
      final body = data['body'] as String?;
      final href = data['href'] as String?;

      unawaited(_showNotification(title: title, body: body, href: href));
    } on Object catch (e) {
      debugPrint('UnifiedPush: error processing message — $e');
    }
  }

  /// 向報導者伺服器訂閱推播
  Future<void> _subscribeToServer(PushEndpoint endpoint) async {
    debugPrint('UnifiedPush: subscribing to server — '
        'endpoint=${endpoint.url}');
    try {
      final dio = Dio();
      final response = await dio.post<dynamic>(
        _subscriptionApiUrl,
        data: <String, dynamic>{
          'endpoint': endpoint.url,
          // 報導者 API 要求 keys 為 JSON 字串，不是 object
          'keys': json.encode(<String, String>{
            'p256dh': endpoint.pubKeySet?.pubKey ?? '',
            'auth': endpoint.pubKeySet?.auth ?? '',
          }),
        },
      );
      debugPrint('UnifiedPush: server subscription succeeded — '
          'status=${response.statusCode}');

      // 儲存端點
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyEndpoint, endpoint.url);
      _enabled = true;
      _registrationError = null;
      _notifyStateChanged();
    } on Object catch (e) {
      debugPrint('UnifiedPush: server subscription failed — $e');
      _registrationError = '伺服器訂閱失敗：$e';
      _notifyStateChanged();
    }
  }

  /// 顯示本地通知
  Future<void> _showNotification({
    required String title,
    String? body,
    String? href,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tw_reporter_push',
      '報導者推播',
      channelDescription: '報導者新聞推播通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: href,
    );
  }
}
