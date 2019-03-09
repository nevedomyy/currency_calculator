import 'package:flutter/material.dart';
import 'tab1.dart';
import 'tab2.dart';

void main() => runApp(App());

class App extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Colors.white,
        fontFamily: 'OpenSans',
        textTheme: TextTheme(
          subhead: TextStyle(color: Colors.black54, fontSize: 20.0),
          body1: TextStyle(color: Colors.black54, fontSize: 20.0),
          caption: TextStyle(color: Colors.black54, fontSize: 20.0),
        )
      ),
      home: Container(
        color: Colors.white,
        child: Calc(),
      ),
    );
  }
}

class Calc extends StatefulWidget{
  @override
  _Calc createState() => _Calc();
}

class _Calc extends State<Calc>{
  TextStyle _style(double size){
    return TextStyle(color: Colors.black54, fontSize: size);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(
            indicatorColor: Colors.orangeAccent,
            tabs: <Widget>[
              SizedBox(
                child: Center(
                  child: Text(
                    'Калькулятор',
                    style: _style(30.0)),
                ),
              ),
              SizedBox(
                child: Center(
                  child: Text(
                    'Курс валют',
                    style: _style(30.0),
                  ),
                ),
              )
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              Tab1(),
              Tab2()
            ],
          ),
        ),
      ),
    );
  }
}