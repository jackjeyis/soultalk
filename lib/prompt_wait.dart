import 'package:flutter/material.dart';
import 'dart:async';

void showMessage(BuildContext context, String text) {
  showDialog<Null>(
      context: context,
      child: new AlertDialog(
          title: new Text("提示"),
          content: new Text(text),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('确定'))
          ]));
}

class ShowAwait extends StatefulWidget {
  ShowAwait(this.requestCallback);
  final Future<int> requestCallback;

  @override
  _ShowAwaitState createState() => new _ShowAwaitState();
}

class _ShowAwaitState extends State<ShowAwait> {
  @override
  initState() {
    super.initState();
    new Timer(new Duration(seconds: 1), () {
      widget.requestCallback.then((int onValue) {
        Navigator.of(context).pop(onValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}
var monthsNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "July",
  "Aug",
  "Sept",
  "Oct",
  "Nov",
  "Dec"
];

var weeksNames = [
  "星期一",
  "星期二",
  "星期三",
  "星期四",
  "星期吴",
  "星期六",
  "星期天",
];

String getTimeStamp(DateTime date){
  var minute = "";
  if(date.minute<10){
    minute = "0${date.minute}";
  }else{
    minute = "${date.minute}";
  }
  return "${date.month}月${date.day}日 ${weeksNames[date.weekday-1]} ${date.hour}:${minute}";
}

String ReadableTime(String timestamp) {
  List<String> timeList = timestamp.split(" ");
  List<String> times = timeList[1].split(":");
  String time;
  if (new DateTime.now().toString().split(" ")[0] == timeList[0]) {
    if (int.parse(times[0]) < 6) {
      time = "凌晨${times[0]}:${times[1]}";
    } else if (int.parse(times[0]) < 12) {
      time = "上午${times[0]}:${times[1]}";
    } else if (int.parse(times[0]) == 12) {
      time = "中午${times[0]}:${times[1]}";
    } else {
      time =
      "下午${(int.parse(times[0])- 12).toString().padLeft(2,'0')}:${times[1]}";
    }
  } else {
    time = timeList[0];
  }
  return time;
}