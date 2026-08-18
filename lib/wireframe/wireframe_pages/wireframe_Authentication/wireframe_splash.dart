import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_login.dart';

import '../../wireframe_gloabelclass/wireframe_icons.dart';

class WireframeSplash extends StatefulWidget {
  const WireframeSplash({Key? key}) : super(key: key);

  @override
  State<WireframeSplash> createState() => _WireframeSplashState();
}

class _WireframeSplashState extends State<WireframeSplash> {
  @override
  void initState() {
    super.initState();
    goup();
  }

  goup() async {
    var navigator = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 5));
    navigator.push(MaterialPageRoute(
      builder: (context) {
        return const WireframeLogin();
      },
    ));
  }

  dynamic size;
  double height = 0.00;
  double width = 0.00;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      body: Center(
          child: SizedBox(
              child: Image.asset(WireframePngimage.splashiconn,height: height/6,fit: BoxFit.fitHeight,))),
    );  }
}
