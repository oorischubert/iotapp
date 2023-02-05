import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'decor.dart';
import 'usersettings.dart';

String uid = ""; //uid of the tag
String devName = ""; //name of the device
ValueNotifier<dynamic> result = ValueNotifier(null); //value notifier for the result of the nfc scan

Future devSettings(
    {required bool barrier,
    bool newDev = false,
    bool firstDev = false,
    required context,
    required Function switchSetter}) async {
  if (newDev) {
    devName = "";
    uid = "";
  } else {
    uid = json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()]
        ['key']; //reset uid
    devName =
        json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()]
            ['name']; //reset devName
  }
  showDialog(
      barrierDismissible: !barrier,
      context: context,
      builder: (context) =>
          Consumer(builder: (context, UserProvider notifier, child) {
            return AlertDialog(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!newDev)
                      const Text('Settings')
                    else
                      const Text('Add Device')
                  ]),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  initialValue: devName,
                  decoration: InputDecoration(
                    labelText: 'Device Name:',
                    enabledBorder: Decor.inputformdeco(),
                    focusedBorder: Decor.inputformdeco(),
                  ),
                  onChanged: (value) {
                    devName = value.trim();
                  },
                ),
                const SizedBox(height: 20),
                ScaledBox(
                  height: 75,
                  width: 75,
                  child: FloatingActionButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      tagRead(ctx: context, initUid: uid);
                    },
                    child: const ScaledBox(
                        height: 75,
                        width: 75,
                        child: Icon(
                          Icons.contactless_outlined,
                        )),
                  ),
                )
              ]),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Spacer(),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            if (uid != "" &&
                                uid !=
                                    json.decode(notifier.deviceList)[
                                        notifier.device]["key"] &&
                                !newDev) {
                              List newList = json.decode(notifier.deviceList);
                              newList[notifier.device]["key"] = uid;
                              notifier.deviceList = json.encode(newList);
                            }
                            if (devName != "" &&
                                devName !=
                                    json.decode(notifier.deviceList)[
                                        notifier.device]["name"] &&
                                !newDev) {
                              List newList = json.decode(notifier.deviceList);
                              newList[notifier.device]["name"] = devName;
                              notifier.deviceList = json.encode(newList);
                            }
                            if (uid != "" && devName != "") {
                              if (newDev) {
                                List newList = json.decode(notifier.deviceList);
                                if (firstDev) {
                                  //if first device need to replace empty device with info
                                  newList = [
                                    {"name": devName, "key": uid}
                                  ];
                                  notifier.deviceList = json.encode(newList);
                                } else {
                                  //if nto first device add to end and increade device list length
                                  newList.add({"name": devName, "key": uid});
                                  notifier.deviceList = json.encode(newList);
                                  notifier.device = newList.length - 1;
                                }
                              }
                              switchSetter();
                              Navigator.pop(context);
                            }
                            if (devName == "") {
                              Decor.notification(
                                  text: 'Please input device name!',
                                  context: context);
                            }
                            if (uid == "") { 
                              Decor.notification(
                                  text: 'Please input device key!',
                                  context: context);
                            }
                          },
                          child: Transform.scale(
                              scale: 1.5, child: const Text('Save'))),
                      const Spacer(),
                      if (!newDev)
                        TextButton(
                          onPressed: () async {
                            bool delete = await Decor.verifyPopUp(
                                context: context,
                                titleText:
                                    "Delete ${json.decode(notifier.deviceList)[notifier.device]["name"]}?");
                            if (delete) {
                              //delete device from deviceList in UserSettings
                              List newList = json.decode(notifier.deviceList);
                              newList.removeAt(notifier.device);
                              notifier.deviceList = json.encode(newList);
                              if (notifier.device > 0) {
                                notifier.device -= 1;
                              } else if (newList.isEmpty) {
                                notifier.deviceList = json.encode([
                                  {"name": "", "key": ""}
                                ]);
                                devSettings(
                                    barrier: true,
                                    newDev: true,
                                    firstDev: true,
                                    context: context,
                                    switchSetter: switchSetter);
                              }
                            }
                          },
                          child: Transform.scale(
                              scale: 1.5,
                              child: const Icon(
                                Icons.delete, //refresh_rounded
                              )),
                        )
                      else
                        const Spacer(),
                    ]),
              ],
            );
          }));
}

//NFC reading function
void tagRead({required ctx, required initUid}) {
  String nfcUid = "";
  Map uidInfo = {};
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    result.value = tag.data;
    uidInfo = await result.value;
    NfcManager.instance.stopSession();
    if (uidInfo[uidInfo.keys.toList()[0]]['identifier'] != null) {
      nfcUid = uidInfo[uidInfo.keys.toList()[0]]['identifier']
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');
    } else if (uidInfo[uidInfo.keys.toList()[1]]['identifier'] != null) {
      nfcUid = uidInfo[uidInfo.keys.toList()[1]]['identifier']
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');
    }
    if (nfcUid == "") {
      Decor.notification(
          text: 'Tag not scanned, please try again!', context: ctx);
    } else {
      uid = nfcUid;
    }
  });
}
