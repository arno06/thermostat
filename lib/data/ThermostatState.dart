import 'package:thermostat/Urls.dart';
import 'package:http/http.dart' as http;

class ThermostatState{

  ThermostatState({required this.id, required this.state, required this.mode, required this.switch_val});

  final int id;

  final String state;

  int mode;

  int switch_val;

  ThermostatState.fromMap(Map value):
    id = int.parse(value['settings']['id_ts']),
    state = value['state'],
    mode = int.parse(value['settings']['manual_switch_ts']),
    switch_val = int.parse(value['settings']['manual_switch_value_ts'])
  ;


  commit() async{
    var client = http.Client();
    var url = Uri.parse(Urls.STATE+"/set/"+(this.mode==0?"auto":"manual")+"/"+this.switch_val.toString());
    await client.get(url);
  }
}