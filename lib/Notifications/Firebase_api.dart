import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessaging(RemoteMessage message) async {
    print('${message.notification?.title}');
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    print('Token  $fCMToken');

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessaging);
  }
}
