import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uber_map_management/authentication/signInScreen.dart';
import 'package:uber_map_management/global/global.dart';
import 'package:uber_map_management/home_screen.dart';






class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  startTimer(){


    Timer(Duration(seconds: 3), () async {
      if( await fAuth.currentUser != null) {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c)=>  HomeScreen()));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=>  SignInScreen()));
      }




    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white70,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo-drivers.png", width: 219, height: 182,),
              const SizedBox(height: 10,),
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('Delivery by Bike Riders',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontFamily:   "SedgwickAveDisplay",
                  letterSpacing: 3,
                ),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
