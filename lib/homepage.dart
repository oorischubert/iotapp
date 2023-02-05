import 'package:flutter/material.dart';
import 'devSettings.dart';
import 'usersettings.dart';
import 'package:provider/provider.dart';
import 'controller.dart';
import 'decor.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final HttpController httpController = HttpController(); //http controller
  bool swValue = false; //init switch value
  bool swLoaded = false; //ProgressIndicator toggler

  ValueNotifier<dynamic> result = ValueNotifier(null);

  setSwitch() async {
    //sets the switch value
    String value = json.decode(UserProvider().deviceList)[UserProvider().device]["key"]; //get the key of the device
    setState(() {
      swLoaded = false;
    });
    final bool newValue = await httpController.getState(key: value);
    setState(() {
      swValue = newValue;
      swLoaded = true;
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); //app state observer
    (json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()]
                ["key"] ==
            "")
        ?
        //does only after widgets are built!
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => devSettings(barrier: true, newDev: true, firstDev: true, context: context, switchSetter: setSwitch))
        : {
            setSwitch()
          };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final unPaused = state == AppLifecycleState.resumed;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) return;

    if (unPaused) {
      setSwitch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, UserProvider notifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: GestureDetector(
              onTap: () {
                setSwitch();
              },
              child: Text(
                  json.decode(notifier.deviceList)[notifier.device]["name"])),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                devSettings(barrier: false, context: context, switchSetter: setSwitch);
              },
              child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Transform.scale(
                      scale: 1.5,
                      child: const Icon(
                        Icons.settings, //refresh_rounded
                      ))),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(
                      "Menu",
                      style: Decor.textStyler(size: 30, color: Colors.white),
                    )
                  ])),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: json.decode(notifier.deviceList).length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:
                          Text(json.decode(notifier.deviceList)[index]["name"]),
                      onTap: () {
                        notifier.device = index;
                        setSwitch();
                        Navigator.pop(context);
                      },
                    );
                  }),
              ElevatedButton(
                  //add new device to deviceList in UserSettings
                  onPressed: () {
                    Navigator.pop(context);
                    devSettings(barrier: false, newDev: true, context: context, switchSetter: setSwitch);
                  },
                  child: Transform.scale(
                      scale: 1.5,
                      child: const Icon(
                        Icons.add,
                      )))
            ],
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: swLoaded
                      ? ScaledBox(
                          height: 500,
                          width: 500,
                          child: Switch(
                              value: swValue,
                              onChanged: (_) {
                                Decor.doubleHaptics();
                                setState(() {
                                  swValue = !swValue;
                                });
                                swValue
                                    ? httpController.setState(
                                        value: "H",
                                        key: json.decode(notifier.deviceList)[
                                            notifier.device]["key"])
                                    : httpController.setState(
                                        value: "L",
                                        key: json.decode(notifier.deviceList)[
                                            notifier.device]["key"]);
                              }))
                      : Transform.scale(
                          scale: 6,
                          child: const CircularProgressIndicator(),
                        )),
            ],
          ),
        ),
      );
    });
  }
}
