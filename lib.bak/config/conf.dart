import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

Future<Map> readLoginData() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  File file = new File('$dir/LandingInformation');
  String data = await file.readAsString();
  Map json = new JsonDecoder().convert(data);
  return json;
}