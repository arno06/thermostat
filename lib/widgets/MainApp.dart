import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thermostat/Urls.dart';

import 'package:thermostat/widgets/RoomState.dart';
import 'package:thermostat/widgets/Sidebar.dart';
import 'package:thermostat/widgets/ToggleSwitch.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  bool disabled = true;
  bool loading = false;

  int selectedIndex = 0;

  List<RoomState> rooms = [];

  @override
  void initState() {
    super.initState();
    updateTemps();
  }

  tabSelectedHandler(int index){
    setState((){
      selectedIndex = index;
    });
  }

  updateTemps() async{
    setState(() {
      loading = true;
    });
    var client = http.Client();

    var url = Uri.parse(Urls.TEMPS);
    var response = await client.get(url);
    List<Map> results = (json.decode(response.body) as List).cast<Map<String, dynamic>>().toList();
    rooms.clear();
    results.forEach((element) {
      rooms.add(
        RoomState.fromJSON(element)
      );
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var d = '...';
    if(rooms.length>0){
      var h = rooms[0].date.hour.toString();
      if(rooms[0].date.hour<10){
        h = "0"+h;
      }
      var m = rooms[0].date.minute.toString();
      if(rooms[0].date.minute<10){
        m = "0"+m;
      }
      d = h+':'+m;
    }

    Widget secondary = settings();
    switch(selectedIndex){
      case 1:
        secondary = temps();
        break;
      case 2:
        secondary = humidity();
        break;
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            height:30,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap:(){
                    this.updateTemps();
                  },
                  child: Row(
                    children: [
                      Container(width:5),
                      (loading?
                      Container(
                        width:25,
                        height:25,
                        child: CircularProgressIndicator(),
                      ):Icon(
                        Icons.refresh,
                        size: 30,
                      )
                      ),
                      Container(width:5),
                      Text(d),
                      Container(width:5),
                    ],
                  )
                ),
              ],
            ),
          ),
          Container(
            height:280,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rooms,
            ),
          ),
          Container(
              height:20
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset:Offset(0.0, 0.0),
                      spreadRadius: 0,
                      blurRadius: 5.0,
                      color:Colors.black12
                  )
                ],
              ),
              child:Row(
                children: [
                  SideBar(onSelected: tabSelectedHandler),
                  Expanded(
                    child: Container(
                      padding:EdgeInsets.all(5.0),
                      decoration:BoxDecoration(
                          color:Colors.white
                      ),
                      child:secondary
                    ),
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  Widget settings(){
    return Column(
      children: [
        Row(
          children: [
            ToggleSwitch(values: ['Automatique', 'Manuel'], width: 250, height:35, onSwitch:(index, val){
              setState(() {
                this.disabled = index==0;
              });
            }),
            Container(width:20),
            ToggleSwitch(values: ['On', 'Off'], width: 125, height:35, disabled: this.disabled,),
          ],
        ),
        Container(
            height:20
        ),
      ],
    );
  }

  Widget temps(){
    return Text("Temperatures");
  }

  Widget humidity(){
    return Text("Humidity");
  }
}
