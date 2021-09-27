import 'dart:ui';

import 'package:flutter/material.dart';

class RoomState extends StatelessWidget {
  const RoomState({Key? key, required this.humidity, required this.temp, required this.date, required this.room, this.colored = false}) : super(key: key);

  final double temp;
  final double humidity;
  final DateTime date;
  final String room;
  final bool colored;


  IconData get icon {
    switch(room){
      case "SALON":
        return Icons.tv;
      case "CHAMBRE":
        return Icons.bed;
      default:
        return Icons.not_interested;
    }
  }

  RoomState.fromJSON(Map val):
        temp = double.parse(val['temperature_thr']),
        humidity = double.parse(val['humidity_thr']),
        date = DateTime.parse(val['date_thr']),
        room = val['room_thr'],
        colored = false
  ;

  RoomState clone(bool colored){
    return RoomState(humidity: this.humidity, temp: this.temp, date: this.date, room: this.room, colored: colored,);
  }

  @override
  Widget build(BuildContext context) {
    Color color = room == "SALON" ? Colors.teal: Colors.blue;
    return Container(
        width:240,
        height:240,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color:Colors.white.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                  offset:Offset(0.0, 0.0),
                  spreadRadius: 0,
                  blurRadius: 5.0,
                  color:Colors.black12
              )
            ]
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(this.icon, size:60, color:colored?color:Colors.black12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(temp.toStringAsFixed(1),
                      style:TextStyle(
                          fontSize: 80
                      )
                  ),
                  Text('°',
                      style:TextStyle(
                          color:Colors.black38,
                          fontSize: 60
                      )
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(humidity.toStringAsFixed(1),
                      style:TextStyle(
                          color:Colors.black38,
                          fontSize: 50
                      )
                  ),
                  Text('%',
                      style:TextStyle(
                          color:Colors.black12,
                          fontSize: 30
                      )
                  )
                ],
              )
            ],
          ),
        )
    );
  }
}

