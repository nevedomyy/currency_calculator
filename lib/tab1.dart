import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:connectivity/connectivity.dart';
import 'list.dart';

class Tab1 extends StatefulWidget{
  @override
  _Tab1 createState() => _Tab1();
}

class _Tab1 extends State<Tab1>{
  final _controller = TextEditingController();
  String _url = 'http://www.cbr.ru/scripts/XML_daily.asp';
  String _result = '';
  var _indicator = 0.0;
  String _value;
  bool _directional = true;

  @override
  initState(){
    super.initState();
    _init();
  }

  @override
  dispose(){
    super.dispose();
    _controller.dispose();
  }

  TextStyle _style(double size){
    return TextStyle(color: Colors.black54, fontSize: size);
  }

  _init() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _directional = pref.getBool('_tab1Directional') ?? true;
    _value = pref.getString('_tab1Value');
    setState((){});
  }

  _calculation() async{
    if (_value == null) return;
    if (_controller.text == '') return;
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
        List<String> _list = List();
        List<String> _nominal = List();
        document.findAllElements('Value')
            .map((node) => node.text)
            .forEach((item){_list.add(item);});
        document.findAllElements('Nominal')
            .map((node) => node.text)
            .forEach((item){_nominal.add(item);});
        String _aString = _list[CurrencyList().getItems().indexOf(_value)];
        double _a = double.parse(_aString.replaceAll(',', '.'));
        _a = _directional ? _a : 1/_a;
        String _bString = _nominal[CurrencyList().getItems().indexOf(_value)];
        double _b = double.parse(_bString);
        _b = _directional ? _b : 1/_b;
        double _c = double.parse(_controller.text);
        _result = (_a*_c/_b).toStringAsFixed(2);
      } else {
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
        Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Text(
                  'По курсу ЦБ РФ на сегодня',
                ),
                Expanded(child: Container())
              ],
            )
        ),
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.import_export, size: 25.0, color: Colors.black54,),
              onPressed: () async{
                _directional = !_directional;
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setBool('_tab1Directional', _directional);
                setState((){});
              },
            ),
            Text(
              _directional ? 'Из' : 'В  ',
            ),
            SizedBox(width: 12.0),
            DropdownButton(
              hint: Text(
                'Выберите валюту',
              ),
              value: _value,
              onChanged: (value) async{
                setState(() {_value = value;});
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setString('_tab1Value', _value);
              },
              items: CurrencyList().getItems().map((value){
                return DropdownMenuItem(
                    value: value,
                    child: Text(value)
                );
              }).toList(),
            ),
            Expanded(child: Container())
          ],
        ),
        Expanded(
          child: Center(
            child: Text(
                _result,
                style: _style(50.0)
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.orangeAccent, width: 2.0)
              )
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration.collapsed(
                  hintText: 'Введите значение',
                )
            ),
          ),
        ),
        Stack(
          alignment: AlignmentDirectional.topStart,
          children: <Widget>[
            Material(
              color: Colors.orangeAccent,
              child: InkWell(
                onTap: _calculation,
                splashColor: Colors.deepOrangeAccent,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Рассчет',
                      style: _style(28.0),
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