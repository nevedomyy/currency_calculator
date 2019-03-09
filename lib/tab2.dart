import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:connectivity/connectivity.dart';

class Tab2 extends StatefulWidget{
  @override
  _Tab2 createState() => _Tab2();
}

class _Tab2 extends State<Tab2>{
  String _url = 'http://www.cbr.ru/scripts/XML_daily.asp';
  List<String> _charCode = List();
  List<String> _value = List();
  String _date = '';
  var _indicator = 0.0;

  @override
  initState(){
    super.initState();
    _init();
  }

  TextStyle _style(double size){
    return TextStyle(color: Colors.black54, fontSize: size);
  }

  _init() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _charCode = pref.getStringList('_tab2CharCode') ?? List();
    _value = pref.getStringList('_tab2Value') ?? List();
    _date = pref.getString('_tab2Date') ?? '';
    setState((){});
  }

  _getExRate() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Нет подключения к интернету')));
      return;
    }
    setState(() {_indicator = null;});
    try {
      var response = await http.get(_url);
      if (response.statusCode == 200) {
        var document  = xml.parse(response.body);
        document.findAllElements('CharCode')
            .map((node) => node.text)
            .forEach((item){_charCode.add(item);});
        document.findAllElements('Value')
            .map((node) => node.text)
            .forEach((item){_value.add(item);});
        document.findElements('ValCurs')
            .map((node) => node.getAttribute('Date'))
            .forEach((item){_date = item;});
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setStringList('_tab2CharCode', _charCode);
        pref.setStringList('_tab2Value', _value);
        pref.setString('_tab2Date', _date);
      }else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Ошибка запроса ${response.statusCode}')));
      }
    }catch(e){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }finally{
      setState(() {_indicator = 0.0;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12.0, right: 12.0),
            child: ListView.builder(
              itemCount: _charCode.length,
              itemBuilder: (context, index){
                return Row(
                  children: <Widget>[
                    Text(_charCode[index], style: _style(50.0)),
                    Expanded(child: Container()),
                    Text(_value[index], style: _style(50.0))
                  ],
                );
              },
            ),
          ),
        ),
        Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.orangeAccent, width: 2.0)
                )
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Курс ЦБ РФ на $_date',
                  ),
                ),
                Expanded(child: Container())
              ],
            )
        ),
        Stack(
          alignment: AlignmentDirectional.topStart,
          children: <Widget>[
            Material(
              color: Colors.orangeAccent,
              child: InkWell(
                onTap: _getExRate,
                splashColor: Colors.deepOrangeAccent,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Обновить',
                      style:_style(28.0),
                    ),
                  ),
                ),
              ),
            ),
            LinearProgressIndicator(
              value: _indicator,
              backgroundColor: Color.fromRGBO(0, 0, 0, 0.0),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
            ),
          ],
        )
      ],
    );
  }
}