import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken.');

    // final FirebaseAuth _auth = FirebaseAuth.instance;
    // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // final User user = _auth.currentUser!;

    // try {
    //   await FirebaseFirestore.instance
    //       .collection('User')
    //       .doc(user.uid)
    //       .update({'deviceToken': fCMToken});
    // } catch (e) {
    //   print('Error updating token: $e');
    //   rethrow;
    // }
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({'deviceToken': fCMToken});
      } catch (e) {
        print('Error updating token: $e');
        rethrow;
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Handle Firebase Messaging onMessage and onMessageOpenedApp callbacks
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showForegroundNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Handle the message when the app is opened from a notification
    });

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print(
          'App opened from a terminated state by a notification: ${initialMessage.messageId}');
      // Handle the initial message here
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    // Show a local notification when receiving a message while the app is in the foreground
    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'SBS',
          'This channel is responsible for all the local notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      // payload: 'test notification'
    );
  }

  Future<void> onSelectNotification() async {
    // Handle when a notification is tapped
    await navigatorKey.currentState?.pushNamed('/');
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await navigatorKey.currentState?.pushNamed('/');
  }

  Future<void> storeDeviceToken(String userId) async {
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken.');

    if (fCMToken != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .update({'deviceToken': fCMToken});
        print('Device token updated successfully.');
      } catch (e) {
        print('Error updating token: $e');
      }
    }
  }

  Future<void> setDeviceTokenToNull(String userId) async {
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken.');

    if (fCMToken != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .update({'deviceToken': ""});
        print('Device token updated to null successfully.');
      } catch (e) {
        print('Error updating token: $e');
      }
    }
  }

  // Future<void> saveNotification(
  //     String userId, String title, String body) async {
  //   await FirebaseFirestore.instance.collection('notifications').add({
  //     'title': title,
  //     'body': body,
  //     'timestamp': FieldValue.serverTimestamp(),
  //     'userId': userId,
  //   });
  // }

  Future<String?> getUserDeviceToken(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
    return userDoc['deviceToken'];
  }

  Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = {
      // "type": "service_account",
      // "project_id": "onlyucafe-ade4f",
      // "private_key_id": "abd6367fd427f5cf81b392b4ca35f55f75a7ee0b",
      // "private_key":
      //     "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDXxlkFd7VmXeAS\nu28BzDhFjyFxKcFKuiDXhr5TGceI2ucYzKOXcp6nzSOww33omE1D1AZ4mKgiBdbu\ngQS9uCY3jUpWn4ro4GnUv5EmSKNE2wvyPQ6fIeW9lef3XgwrQLDhpvltm4jd8EML\nBG4HITifbPM+pWvhyxxQPZ4VskU21LqH2puPg97PqoJ/97mCCNJcE/oZtcHonzBK\nw9ZzKbPFMF7yEAvh7WzlVkZI5/R2oQ2dhQQdK3vL769C034v3OkXci3l65jbXuw3\ns25JkbHxtb2cUQ0oZ9ivAkZ+Xq5wM41u/iDIOUFi9iLI2QccROw6qq/POhG/ekDz\ntkwGJrh5AgMBAAECggEAJhH15PQRCmWnwkZVuKB6kTNGuDugwfmDD+PTMsBKp0fQ\nHF0GxBLSEVMtZ+OmFGLCxyPinGZ6y73yBRS4bGzQOV7xbcUqchoeMg42ouWQAPcQ\n7YV+Te9iJIgNbGSoiv0X+EhIm+EkTdw1R/1ZGGLxJZfIdxYiqaz3auTkPnm8ooak\n+BnDx1GfhxWEHLTMFFijJlQid65139eolZQp4gXJQEyKFHO6wYmVbBCDYVjm89F4\nSnztVQnREgZhw+NR0rV+rmylfdCO63XvqLjOUR84yxbF/WM8UjboKZMIfqwpSDUx\nzNz+fvh9mlEjpNCLDeKqjTFmuHYBdisnvwPb+YgMMQKBgQD2Nv9yWSSraMJGWX1K\nU1cot47h25QZD0iqKsWm/Cmr5Lgfj/WqjkIHKzk49TsFQzOTdz1OijTXXniNOgP8\nzAxBRn0Ww5c2z7mharHiG1G4pECUcKEe20vFDTkqNPc67HALL1fZM8hftyfvPD8g\ndXcbAomL6PE4B+SfLOSTK1sP1QKBgQDgWabCX0blGctFpK0HKt7AAR+cgjZZB3Fk\nVa/eE1twZVsrgIbtCzimGDVI+Vb7XJkRTCJMH77qIGMwmKZJtU3HofKifhjbBAho\nkGCoiwZkAiun2Ytc2zf21wE7mT8/KyaJ+VxkUVu5vE4f70BCviUxSTjl3hOsQr2B\n2Pt/7Na8FQKBgFr5EUOX6nOnHnlN4XxP9NlnkVSkhEEKI6g0a5l6fI810E5hK71c\nGMt7TgZcnfUg0nK/URiu+j1Fe7d64zRJ1JFd0SRTGpE3CXi56oYH4BcgIXh3cSDs\nmD9z1lZhAaR07iVD1eq8NmIfU5MSqKR+ooaJVncql85DJFcoCEDUeS4NAoGAYbvs\nf6SN9+Qiv3YbwpGUdESJBt9a2bH6XeFOOgpovTAKZYsaPE21IfZN0Dp/AAW40OY/\n0rXJr6joTRVS661F8v/D+bHBFjhNiW/MC+B0qkCf0AFfStZdLPVBHjuGZ/heU6ED\n9NfUg7dauWK6tdirzyq81LbIDzUL5XMnLPV6HnkCgYEA5UTIipIupQinSZjIlMVt\n274jSehDCMk40B+CwqS1Grs8KZ2bjh8jmFimRUJFXSySGH0/gmK+R9Nk7GhcHA7Y\n76kmtrE5d3sR59O/KWJFFWpZs8OKmZLru71s8pAmSAJOxEhcDoXDLqQlqi4nKrri\n9ox7idatz/MgcLEiAx7G9gE=\n-----END PRIVATE KEY-----\n",
      // "client_email":
      //     "firebase-adminsdk-vg41c@onlyucafe-ade4f.iam.gserviceaccount.com",
      // "client_id": "118236171447788246397",
      // "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      // "token_uri": "https://oauth2.googleapis.com/token",
      // "auth_provider_x509_cert_url":
      //     "https://www.googleapis.com/oauth2/v1/certs",
      // "client_x509_cert_url":
      //     "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-vg41c%40onlyucafe-ade4f.iam.gserviceaccount.com",
      // "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }

  Future<void> sendMessage(
      Future<String?> deviceTokenFuture, String title, String body) async {
    final deviceToken = await deviceTokenFuture;
    if (deviceToken == null) {
      print('Device token is null, unable to send message.');
      return;
    }
    print("Send to $deviceToken");
    final String serverKey = await getAccessToken(); // Your FCM server key
    const String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/onlyucafe-ade4f/messages:send';
    // final currentFCMToken = await FirebaseMessaging.instance.getToken();
    print("fcmkey : $deviceToken");
    final Map<String, dynamic> message = {
      'message': {
        'token':
            deviceToken, // Token of the device you want to send the message to
        'notification': {'body': body, 'title': title},
        'data': {
          'current_user_fcm_token':
              deviceToken, // Include the current user's FCM token in data payload
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
    }
  }
}