import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  _SearchPage createState() => new _SearchPage();
}

class _SearchPage extends State<SearchPage> {

  static Card cd = new Card(
    child: new InkWell(
      onTap: () => {},
      child: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Stack(
          children: [
            new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text(
                  "hello",
                ),
                new Container(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: new Text("nihao")),
                new DefaultTextStyle(
                  style:
                  const TextStyle(color: Colors.red),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  child: new Padding(
                    child: new Text('''
  sdfasdfadsfsdf
  werwerwer
  weterwtwrt
  '''),
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  ),
                ),
                new Row(
                  children: [
                    new Container(
                      width: 24.0,
                      height: 24.0,
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: new BoxDecoration(
                      ),
                    ),
                    new Expanded(
                      child: new Text(
                          "huahuidf"
                      ),
                    ),
                  ],
                ),
                new Padding(
                  child: new Column(
                    children: [],
                  ),
                  padding: const EdgeInsets.only(top: 8.0),
                )
              ],
            ),
            new Positioned(
              bottom: -8.0,
              right: -8.0,
              child: new FlatButton(onPressed: (){}, child: new Icon(Icons.add)),
            ),
          ],
        ),
      ),
    ),
  );
  List<Card> cards = [cd,cd,];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Message',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 20.0)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: new ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          itemBuilder: (_, int idx) {
            return new Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: cards[idx],
            );
          },
          itemCount: 2,
      )
    );
  }
}