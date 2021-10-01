import 'package:flutter/material.dart';
import 'package:thermostat/Urls.dart';
import 'package:http/http.dart' as http;

class Setting
{
  Setting({required this.id, required this.room, required this.temp, required this.start_at, required this.end_at});

  final int id;
  final String room;
  double temp;
  final String start_at;
  final String end_at;

  IconData get icon{
    return this.room == 'CHAMBRE'?Icons.bed:Icons.tv;
  }
  
  Setting.fromMap(Map value):
      this.id = int.parse(value['id_ts']),
      this.room = value['auto_room_ts'],
      this.temp = double.parse(value['auto_temp_ts']),
      this.start_at = (value['start_time_ts'] as String).split(':').sublist(0, 2).join(":"),
      this.end_at = (value['end_time_ts'] as String).split(':').sublist(0, 2).join(":")
  ;

  commit() async{
    var client = http.Client();
    var url = Uri.parse(Urls.SETTINGS+"/"+this.id.toString());
    await client.post(url, body: <String, dynamic>{'temperature':this.temp.toString()});
  }
}