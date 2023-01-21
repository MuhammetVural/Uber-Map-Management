import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_map_management/splashScreen/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MyApp(
      child: MaterialApp(
        title: 'Drivers App',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Color(0xffCAFB09)),
            color: Color(0xFF1F1F1F),
          ),
          primaryColor: Color(0xffCAFB09),
          primaryColorDark: Color(0xFF1F1F1F),
          primaryColorLight: Color(0xFF393939),
          scaffoldBackgroundColor: Color(0xFFF6F6F8),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Color(0xFFf5f5f5),
          ),
          fontFamily: 'SFProRegular',
        ),
        home: const MySplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class MyApp extends StatefulWidget
{
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context)
  {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
{
  Key key = UniqueKey();

  void restartApp()
  {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
