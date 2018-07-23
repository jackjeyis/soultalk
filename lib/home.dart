import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:sqflite/sqflite.dart';
import 'group_chat_list.dart';
import 'search_page.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'sign_in.dart';
import 'package:soultalk/im/im.dart';
import 'edit_page.dart';



class HomePage extends StatefulWidget {
  HomePage({Key key, this.title,this.landing,}) : super(key: key);
  final String title;
  final bool landing;

  @override
  _HomePageState createState() => new _HomePageState();
}
PageController pageController;

class _HomePageState extends State<HomePage> {
  int _page = 0;
  var appBarTitles = ['消息','主页','我'];

  Widget getTabIcon(int curIdx){
    if(_page == curIdx){
        return icons[curIdx][1];
    }else{
      return icons[curIdx][0];
    }
  }

  Widget getTabTitle(int curIdx){
    if(_page == curIdx){
      return new Text(appBarTitles[curIdx],style:new TextStyle(color: Colors.green));
    }else{
      return new Text(appBarTitles[curIdx],style:new TextStyle(color: Colors.grey));
    }
  }

  var icons = [
    [
      new Icon(Icons.message, color: Colors.grey[400]),
      new Icon(Icons.message, color: Colors.green)
    ],
      [new Icon(Icons.add_circle, color: Colors.grey[400]),
      new Icon(Icons.add_circle, color: Colors.green),
      ],
    [new Icon(Icons.person_outline, color: Colors.grey[400]),
    new Icon(Icons.person_outline, color: Colors.green)
    ]
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.landing ?
    new Scaffold(
        body: new PageView(
          children: [
            new Container(
              color: Colors.white,
              child: new GroupChatList(),
            ),
            new Container(color: Colors.white, child: new SearchPage()),

            new Container(
                color: Colors.green,
                child: new ProfilePage(
                  userId: "jack",
                )),
          ],
          controller: pageController,
          physics: new AlwaysScrollableScrollPhysics(),
          onPageChanged: onPageChanged,
        ),
        bottomNavigationBar: new BottomNavigationBar(
          fixedColor: Colors.blue,
          items: [
            new BottomNavigationBarItem(

                icon: getTabIcon(0),
                title: getTabTitle(0),
                backgroundColor: Colors.white),

            new BottomNavigationBarItem(
                icon: new FlatButton(
                    highlightColor: Theme.of(context).buttonColor,
                    onPressed: (){
                      Navigator
                          .of(context)
                          .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
                        return new MyHomePage();
                      }));
                    },
                    child: getTabIcon(1),
                ),
                title: new Container(),
                backgroundColor: Colors.white),

            new BottomNavigationBarItem(
                icon: getTabIcon(2),
                title: getTabTitle(2),
                backgroundColor: Colors.white),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
          type: BottomNavigationBarType.fixed,
        )
    ) : new SignIn();
  }
  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }
  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
  @override
  void initState() {
    super.initState();
    IMManager.instance().getChannel();
    pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}