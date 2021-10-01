import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thermostat/Urls.dart';
import 'package:thermostat/data/Setting.dart';
import 'package:thermostat/data/THR.dart';
import 'package:thermostat/data/ThermostatState.dart';
import 'package:thermostat/painters/GraphPainter.dart';

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
  List<Setting> settings = [];
  ThermostatState? currentState;

  Map<String, List> weeklyData = {"SALON":[], "CHAMBRE":[]};

  late String _imageUrl;
  String _dimensions = '700x480';

  @override
  void initState() {
    super.initState();
    this.update();
    Timer.periodic(const Duration(minutes: 15), (timer) {
      this.update();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    _dimensions = w.toInt().toString()+'x'+h.toInt().toString();
  }

  void update(){
    updateTemps();
    updateWeeklyReadings();
    updateStatusInfo();
    updateSettings();
    _generateImageUrl();
    setState(() {});
  }

  tabSelectedHandler(int index){
    setState((){
      selectedIndex = index;
    });
  }

  updateSettings() async{
    var client = http.Client();
    var url = Uri.parse(Urls.SETTINGS);
    var response = await client.get(url);
    List<Map> results = (json.decode(response.body)['settings'] as List).cast<Map<String, dynamic>>().toList();
    settings.clear();
    results.forEach((element) {
      settings.add(Setting.fromMap(element));
    });
    settings.sort((elementA, elementB){
      return elementA.start_at.compareTo(elementB.start_at);
    });
  }

  updateStatusInfo() async{
    var client = http.Client();
    var url = Uri.parse(Urls.STATE);
    var response = await client.get(url);
    Map<String, dynamic> results = (json.decode(response.body));
    currentState = ThermostatState.fromMap(results);
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

  updateWeeklyReadings() async{
    var response = await http.read(Uri.parse(Urls.WEEKLY_DATA));
    Map weekly = jsonDecode(response) as Map<String, dynamic>;

    List<THR> emptyTHRList = [];

    if(!mounted)
      return;

    setState((){
      weeklyData = {"SALON":emptyTHRList, "CHAMBRE":emptyTHRList};
      if(weekly.containsKey("SALON")){
        weeklyData["SALON"] = _parseTHRList(weekly["SALON"]);
      }
      if(weekly.containsKey("CHAMBRE")){
        weeklyData["CHAMBRE"] = _parseTHRList(weekly["CHAMBRE"]);
      }
    });
  }

  List<THR> _parseTHRList(List list){
    List<THR> r = [];
    list.forEach((e){
      r.add(THR.fromMap(e));
    });
    return r;
  }

  void colorRooms(bool colored){
    List<RoomState> r = [];
    rooms.forEach((element) {
      r.add(element.clone(colored));
    });
    rooms.clear();
    rooms.addAll(r);
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

    Widget secondary = settingsScreen();
    switch(selectedIndex){
      case 0:
        colorRooms(false);
        break;
      case 1:
        colorRooms(true);
        secondary = temps();
        break;
      case 2:
        colorRooms(true);
        secondary = humidity();
        break;
    }

    return Scaffold(
      body: DecoratedBox(
        decoration:BoxDecoration(
            image:DecorationImage(
                image: NetworkImage(_imageUrl)
            )
        ),
        child: Column(
          children: [
            Container(
              height:30,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: (){
                      DesktopWindow.toggleFullScreen();
                    },
                    icon: Icon(Icons.fullscreen),
                  ),
                  InkWell(
                      onTap:(){
                        this.update();
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
              height:240,
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
      ),
    );
  }

  Widget settingsScreen(){

    List<Widget> set = [];

    settings.forEach((element){
      var time = element.start_at;
      time += ' - ';
      time += element.end_at;
      set.add(
        InkWell(
          onTap:(){
            showDialog(context: context, builder: (BuildContext){
              var val = element.temp;
              return StatefulBuilder(builder: (context, sstate){
                return AlertDialog(
                  title:Center(child:Text(time)),
                  content:Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: (){
                          val += 0.5;
                          sstate((){});
                        },
                        iconSize: 70.0,
                        icon: Icon(Icons.keyboard_arrow_up),
                      ),
                      Text(
                        val.toString()+'°',
                        style: TextStyle(
                          fontSize: 40.0
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          val -= 0.5;
                          sstate((){});
                        },
                        iconSize: 70.0,
                        icon: Icon(Icons.keyboard_arrow_down)
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          element.temp = val;
                          element.commit();
                        });
                      },
                      child: Text("Enregistrer"),
                    ),
                  ],
                );
              });
            });
          },
          child: Container(
            padding:EdgeInsets.all(10.0),
            child: Row(
              children: [
                Icon(element.icon),
                Container(width:10.0),
                Text(time),
                Spacer(),
                Text(element.temp.toString()+"°"),
              ],
            ),
          ),
        )
      );

      set.add(
        Center(
          child: Container(
            decoration: BoxDecoration(
              color:Colors.black.withOpacity(.1)
            ),
            height:1.0,
          ),
        )
      );
    });

    var mode = 0;
    if(this.currentState != null){
      mode = this.currentState!.mode;
    }
    var val = 0;
    if(this.currentState != null){
      val = this.currentState!.switch_val;
    }
    return Column(
      children: [
        Row(
          children: [
            ToggleSwitch(values: ['Automatique', 'Manuel'], value:mode, width: 250, height:35, onSwitch:(index, val){
              setState(() {
                this.currentState?.mode = index;
                this.currentState?.commit();
                this.disabled = index==0;
              });
            }),
            Container(width:20),
            ToggleSwitch(values: ['Off', 'On'], value:val, width: 125, height:35, disabled: this.disabled, onSwitch: (index, val){
              this.currentState?.switch_val = index;
              this.currentState?.commit();
              runRelayCommand([this.currentState?.switch_val==0?"off":"on"]);
            }),
            Spacer(),
            Opacity(
              opacity: currentState?.mode == "on"?1:0,
              child:Icon(Icons.fireplace_outlined, color: Colors.green,)
            )
          ],
        ),
        Container(height:10),
        Column(
          children: set,
        )
      ],
    );
  }

  Widget temps(){
    return graph("temperature", 15, 30, 1, 5);
  }

  Widget humidity(){
    return graph("humidity", 0, 100, 10, 50);
  }

  Widget graph(String propPainter, yMinPainter, yMaxPainter, stepPainter, majorStepPainter){
    return new Container(
      width: MediaQuery.of(context).size.width,
      height: 200.0,
      child: new CustomPaint(
        painter: new GraphPainter(
            data: weeklyData,
            propValue:propPainter,
            yMin:yMinPainter,
            yMax:yMaxPainter,
            step:stepPainter,
            majorStep:majorStepPainter
        ),
      ),
    );
  }

  void _generateImageUrl(){
    setState((){
      _imageUrl = 'https://source.unsplash.com/random/'+_dimensions+'?city,weather&'+DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  Future<ProcessResult> runRelayCommand(List<String> parameters){
    List<String> params = ['/home/arno/relay.py'];
    params.addAll(parameters);
    return Process.run('/usr/bin/python3', params).then((ProcessResult results){
      if(results.exitCode != 0){

      }
      return results;
    });
  }
}
