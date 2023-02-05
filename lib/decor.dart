import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Decor {
  //function to add border and rounded edges to text form
  static OutlineInputBorder inputformdeco() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(
          width: 1.0, color: Colors.blue, style: BorderStyle.solid),
    );
  }

//custom text styler
  static TextStyle textStyler(
      {required double size, Color color = Colors.black}) {
    return TextStyle(fontSize: size, color: color);
  }

//custom notification logic
  static notification(
      {required String text,
      Color color = Colors.white,
      required context,
      double margin = 20,
      int duration = 3}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(text),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
            //bottom: MediaQuery.of(context).size.height - 200, //(makes notifications appear from top)
            right: margin,
            left: margin),
        behavior: SnackBarBehavior.floating,
        duration:  Duration(seconds: duration),
        backgroundColor: color,
      ));
  }

//makes the haptics feel more realistic
  static doubleHaptics({milliseconds = 250}) {
    HapticFeedback.heavyImpact();
    Future.delayed(Duration(milliseconds: milliseconds))
        .then((value) => HapticFeedback.heavyImpact());
  }

  static Future<bool> verifyPopUp(
      //popup for verification, returns true if button pressed, false if dismissed.
      {required context,
      required String titleText,
      String buttonText = "Ok"}) async {
    bool ret = false; //bool to return
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(titleText)]),
              actions: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Transform.scale(
                      scale: 1.5,
                      child: TextButton(
                          onPressed: <bool>() {
                            Navigator.pop(context, true);
                            Navigator.pop(context, true);
                            ret = true; //make return true
                          },
                          child: Text(
                            buttonText,
                            style: const TextStyle(color: Colors.blue),
                          )))
                ]),
              ],
            ));
    return ret; //return whether or not the user pressed ok
  }
}

class ScaledBox extends StatelessWidget {
  //widget to scale a box
  final Widget child;
  final double height;
  final double width;

  const ScaledBox(
      {Key? key,
      required this.child,
      required this.height,
      required this.width})
      : super(key: key);

  Widget build(BuildContext context) {
    return SizedBox(
        height: height, width: width, child: FittedBox(child: child));
  }
}

//wraps text in an auto expanding enclosure.
class TextWrapper extends StatelessWidget {
  final String text;
  const TextWrapper({Key? key, required this.text})
      : super(
          key: key,
        );
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: null,
      readOnly: true,
      initialValue: text,
      decoration: InputDecoration(
        enabledBorder: Decor.inputformdeco(),
        focusedBorder: Decor.inputformdeco(),
      ),
    );
  }
}
