import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'sign_up.dart';
import 'prompt_wait.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:soultalk/config/conf.dart';
import 'package:soultalk/db/appbase.dart';
import 'package:soultalk/im/im.dart';
import 'home.dart';






class SignIn extends StatefulWidget {
  @override
  State createState() => new _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  bool _correctPhone = true;
  bool _correctPassword = true;
  AnimationController _loginButtonController;
  Database db;
  IOWebSocketChannel channel;
  List<Map> messages = [];
  @override
  void initState() {
    super.initState();
    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    FocusScope.of(context).requestFocus(new FocusNode());
    _checkInput();
    if (_phoneController.text == '' || _passwordController.text == '') {
      showMessage(context, "登录信息填写不完整！");
      return;
    } else if (!_correctPhone || !_correctPassword) {
      showMessage(context, "登录信息的格式不正确！");
      return;
    }
    showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder:(context) => new ShowAwait(
            _userLogIn(_phoneController.text,_passwordController.text,_nameController.text)))
        .then((int onValue) {
      if (onValue == 0) {
        showMessage(context, "这个手机号码没有被注册！");
      } else if (onValue == 1) {
        showMessage(context, "手机号码或登陆密码不正确！");
      } else if (onValue == 2) {
        Navigator
            .of(context)
            .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
          return new HomePage(title:"Soultalk",landing: true,);
        }));
      }
    });
  }

  String mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }

  Future<int> _userLogIn(String phone, String password,String name)  async {
    /*final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
    var urlparams = mapToQueryParams({
      "client_id": "5cfcda33d98740475a16",
      "response_type": "code",
      "redirect_uri": "http://10.12.164.130:8080/api/user/auth",
    });
    flutterWebviewPlugin.launch("https://github.com/login/oauth/authorize?$urlparams",
    clearCookies: true);*/
    return await http
        .post(
        "http://eevee.petpika.cn/soultalk/api/user/login",
        body: json.encode({ 'phone': int.parse(phone),'password': password})
        )
        .timeout(new Duration(seconds: 1),onTimeout: (){print("timeout");})

        .then((resp){
          print(resp.body);
          var map = json.decode(resp.body);
          if (resp.statusCode == 200) {
            map = json.decode(map["msg"]);
            _saveLogin(phone, password,map["username"],"abc");
            AppDatabase.get().getDb().then((db) async {
              this.db = db;
              channel = IOWebSocketChannel.connect('ws://eevee.petpika.cn:443/ws');
              channel.sink.add(
                  json.encode({
                    "id":0,
                    "method":"register",
                    "params": {
                      "name": map["username"],
                    }})
              );
              channel.stream.listen((data){
                print(data);
                Map js = json.decode(data);
                messages.add(js);
                IMManager
                    .instance()
                    .streamController
                    .add(js);
              });
            });
            return 2;
          }else{
            return 1;
          }
        }).catchError((error){
          print(error);
        });
  }

  Future<Null> _saveLogin(String phone, String password,String name,String portrait) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/LandingInformation');
    await file.writeAsString(
          '{"phone":"$phone","name":"$name","password":"$password","portrait":"$portrait"}');
  }

  void _openSignUp() {
    setState(() {
      Navigator.of(context).push(new MaterialPageRoute<List<String>>(
        builder: (BuildContext context) {
          return new SignUp();
        },
      )).then((onValue) {
        if (onValue != null) {
          _phoneController.text = onValue[0];
          _passwordController.text = onValue[1];
          _nameController.text = onValue[2];
          FocusScope.of(context).requestFocus(new FocusNode());
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text("注册成功！"),
          ));
        }
      });
    });
  }

  void _checkInput() {
    if (_phoneController.text.isNotEmpty &&
        (_phoneController.text.trim().length < 7 ||
            _phoneController.text.trim().length > 12)) {
      _correctPhone = false;
    } else {
      _correctPhone = true;
    }
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.trim().length < 6) {
      _correctPassword = false;
    } else {
      _correctPassword = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: new Stack(children: <Widget>[
          new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _checkInput();
              },
              child: new Container(
                decoration: new BoxDecoration(),
              )),
          new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Center(
                  child: new Image.asset(
                    'images/talk_casually.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                  )),
              new Container(
                  width: MediaQuery.of(context).size.width * 0.96,
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: new InputDecoration(
                            hintText: '手机号码',
                            errorText: _correctPhone ? null : '号码的长度应该在7到12位之间',
                            icon: new Icon(
                              Icons.phone,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                          onSubmitted: (value) {
                            _checkInput();
                          },
                        ),
                        new TextField(
                          controller: _passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: new InputDecoration(
                            hintText: '登陆密码',
                            errorText: _correctPassword ? null : '密码的长度应该大于6位',
                            icon: new Icon(
                              Icons.lock_outline,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                          onSubmitted: (value) {
                            _checkInput();
                          },
                        ),
                      ])),
              new Center(
                  child: new FlatButton(
                child: new Container(
                width: 320.0,
                height: 60.0,
    alignment: FractionalOffset.center,
    decoration: new BoxDecoration(
    color: const Color.fromRGBO(247, 64, 106, 1.0),
    borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
    ),
    child: new Text(
      "登 录",
    style: new TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.3,
    ),
      textScaleFactor: 1.1,
    ),
    ),/*new Container(
                  decoration: new BoxDecoration(
                    color: Theme.of(context).buttonColor,
                  ),
                  child: new Center(
                      child: new Text(
                        "登 录",
                        textScaleFactor: 1.1,
                        style: new TextStyle(color: Theme.of(context).primaryColor),
                      )),
                ),*/
                onPressed: () {
                  _handleSubmitted();
                },
              )),
              new Center(
                  child: new FlatButton(
                    child:new Container(
                      width: 320.0,
                      height: 60.0,
                      alignment: FractionalOffset.center,
                      decoration: new BoxDecoration(
                        color: const Color.fromRGBO(247, 64, 106, 1.0),
                        borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
                      ),
                      child: new Text(
                        "没有帐户？ 注册",
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                        ),
                        textScaleFactor: 1.1,
                      ),
                    )/*new Text("没有帐户？ 注册")*/,
                    onPressed: _openSignUp,
                  ))
            ],
          )
        ]));
  }
}