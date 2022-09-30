import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:serviclick/main.dart';

class NotificacionService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static String? token;

  static StreamController<String> streamControllerMessage =
      new StreamController.broadcast();

  static Stream<String> get messageStream => streamControllerMessage.stream;

  static Future backgroundhandler(RemoteMessage message) async {
    print("Notificaciones en segundo plano: ${message.messageId}");
    streamControllerMessage.add(message.notification?.title ?? 'No hay titulo');
    FlutterAppBadger.updateBadgeCount(1);
  }

  static Future onmessagehandler(RemoteMessage message) async {
    FlutterAppBadger.updateBadgeCount(1);
    print("Notificar cuando la aplicacion este abierta: ${message.messageId}");
    streamControllerMessage.add(message.notification?.title ?? 'No hay titulo');
  }

  static Future onopenmessage(RemoteMessage message) async {
    FlutterAppBadger.updateBadgeCount(1);
    print("on open app handler: ${message.messageId}");
    streamControllerMessage.add(message.notification?.title ?? 'No hay titulo');
  }

  static Future initializedApp() async {
    print("Inicializar la escucha de notificaciones");
    //Notificaciones push
    await Firebase.initializeApp();
    await requestPermission();
    token = await FirebaseMessaging.instance.getToken();
    print("Token: $token");
    //Handlers
    FirebaseMessaging.onBackgroundMessage(backgroundhandler);
    FirebaseMessaging.onMessage.listen(onmessagehandler); //Aplicacion abierta
    FirebaseMessaging.onMessageOpenedApp.listen(onopenmessage);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    //Local Notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            chanel.id,
            chanel.name,
            //chanel.description,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });
  }

  //Apple / web
  static requestPermission() async {
    NotificationSettings setting = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true);

    print("Status $setting");
  }

  static closeStream() {
    streamControllerMessage.close();
  }
}
