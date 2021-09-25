
class THR
{

  const THR({required this.id, required this.temperature, required this.humidity, required this.date, required this.room});

  final int id;
  final double temperature;
  final double humidity;
  final DateTime date;
  final String room;

  double get(String prop){
    if(prop == "temperature"){
      return temperature;
    }
    else if (prop == "humidity"){
      return humidity;
    }
    return 0.0;
  }

  THR.fromMap(Map pData):
    id = int.parse(pData['id_thr']),
    temperature = double.parse(pData['temperature_thr']),
    humidity = double.parse(pData['humidity_thr']),
    date = DateTime.parse(pData['date_thr']),
    room = pData['room_thr']
  ;
}