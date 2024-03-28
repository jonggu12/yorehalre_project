// import 'pages/LoginPage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
// import 'package:uni_links/uni_links.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   KakaoSdk.init(
//     nativeAppKey: 'e0366b423bb3b7d6ebfab517a7569518',
//     javaScriptAppKey: 'fbbba262d06f904f8a104827f72a7d32',
//         );
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LoginPage(),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seniorproject/pages/LoginPage.dart';

import 'firebase_options.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:uni_links/uni_links.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  KakaoSdk.init(
    nativeAppKey: 'e0366b423bb3b7d6ebfab517a7569518',
    javaScriptAppKey: 'fbbba262d06f904f8a104827f72a7d32',
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    getInitialLink().then((String? link) {
    });
    linkStream.listen((String? link) {
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

