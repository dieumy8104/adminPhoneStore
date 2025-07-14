import 'package:admin/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  //create an instance of FirebaseApi
  final _firebaseMessaging = FirebaseMessaging.instance;

  //function to initialize notifications
  Future<void> initNotifications() async {
    //request permission for notifications
    await _firebaseMessaging.requestPermission( 
    );
    //fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    //print the FCM token
    print('FCM Token: $fCMToken');
    initPushNotifications();
  }

  //function to handle background messages
  void handleMessages(RemoteMessage? message) {
    if (message == null) return;
    //print the message data
    navigatorKey.currentState?.pushNamed(
      '/notiScreen',
      arguments: message,
    );
  }
  //function to handle foreground messages
  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessages) ;
    FirebaseMessaging.onMessage.listen(handleMessages);
  }
}
