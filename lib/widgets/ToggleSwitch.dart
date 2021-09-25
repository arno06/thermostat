import 'package:flutter/material.dart';

class ToggleSwitch extends StatefulWidget {
  const ToggleSwitch({Key? key, required this.values, required this.width, this.height = 30, this.borderSize=2, this.disabled = false, this.onSwitch, this.value=0}) : super(key: key);

  final List<String> values;

  final double width;

  final double height;

  final double borderSize;

  final bool disabled;

  final Function? onSwitch;

  final int value;

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {

  int selectedIndex = 0;

  late double widthItem;

  @override
  Widget build(BuildContext context) {
    widthItem = (this.widget.width / this.widget.values.length) - (this.widget.borderSize);
    List<Widget> buttons = [];

    this.widget.values.forEach((element) {
      var style = TextStyle(color:Colors.black, fontSize: this.widget.height/2);
      if(selectedIndex != this.widget.values.indexOf(element)){
        style = TextStyle(color:Color(0xFF686768), fontSize: this.widget.height/2);
      }
      var ctr = Container(
          width: this.widthItem,
          child:Center(
            child: Text(element, style:style),
          )
      );
      buttons.add(
        this.widget.disabled?ctr:
        InkWell(
            onTap: (){
              setState(() {
                selectedIndex = this.widget.values.indexOf(element);
                if(this.widget.onSwitch != null){
                  this.widget.onSwitch!(selectedIndex, element);
                }
              });
            },
            hoverColor: Color.fromARGB(0, 0, 0, 0),
            highlightColor: Color.fromARGB(0, 0, 0, 0),
            focusColor: Color.fromARGB(0, 0, 0, 0),
            splashColor: Color.fromARGB(0, 0, 0, 0),
            child:ctr
        )
      );
    });

    return Opacity(opacity: this.widget.disabled?0.5:1.0,
        child: Container(
          width: this.widget.width,
          height:this.widget.height,
          padding: EdgeInsets.all(this.widget.borderSize),
          decoration:BoxDecoration(
              borderRadius: BorderRadius.circular(this.widget.height),
              color:Color(0xFFdbd9db)
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                curve: Curves.easeOutExpo,
                duration: Duration(milliseconds: 300),
                top:0,
                left: this.selectedIndex * this.widthItem,
                width: this.widthItem,
                height: this.widget.height - (this.widget.borderSize*2),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(this.widget.height),
                      color:Colors.white,
                      boxShadow: [BoxShadow(
                          color:Colors.black38,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(0.0, 0.0)
                      )]
                  ),
                ),
              ),
              Row(
                children: buttons,
              )
            ],
          ),
        ),
    );
  }
}
