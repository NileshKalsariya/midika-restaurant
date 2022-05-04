import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:midika/Screens/splash_screen/splash_screen.dart';
import 'package:midika/provider/internet_check_provider.dart';
import 'package:midika/provider/location_provider.dart';
import 'package:midika/provider/operational_hours_provider.dart';
import 'package:midika/provider/screen_provider.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/apple_login_service/apple_auth_service.dart';
import 'package:midika/services/apple_login_service/apple_sign_in_available.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/item_services.dart';
import 'package:midika/services/payment_service.dart';
import 'package:midika/services/qr_code_services.dart';
import 'package:midika/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'Internationalization/messages.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final appleSignInAvailable = await AppleSignInAvailable.check();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: appPrimaryColor, // status bar color
  ));
  String? token = await FirebaseMessaging.instance.getToken();
  print(token);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(Provider<AppleSignInAvailable>.value(
    value: appleSignInAvailable,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ItemServices()),
            ChangeNotifierProvider(create: (context) => RestaurantProvider()),
            ChangeNotifierProvider(create: (context) => AuthServices()),
            ChangeNotifierProvider(
                create: (context) => OperationalHoursProvider()),
            ChangeNotifierProvider(create: (context) => LocationProvider()),
            ChangeNotifierProvider(create: (context) => QrCodeServices()),
            ChangeNotifierProvider(create: (context) => ScreenProvier()),
            ChangeNotifierProvider(
                create: (context) => PaymentServiceProvider()),
            ChangeNotifierProvider(create: (context) => AuthServiceApple()),
            ChangeNotifierProvider(create: (context) => InternetProvider()),
          ],
          child: GetMaterialApp(
            translations: Messages(),
            locale: const Locale('en', 'us'),
            fallbackLocale: const Locale('en', 'us'),
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            home: MaterialApp(
                debugShowCheckedModeBanner: false, home: const SplashScreen()),
          ),
        );
      },
    );
  }
}
