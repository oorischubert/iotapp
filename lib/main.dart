import 'package:flutter/material.dart';
import 'homepage.dart';
import 'usersettings.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSettings.init(); //getting user settings when app boots up!
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: Consumer(builder: (context, UserProvider notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner:
                false, //removes annoying debug banner in debug mode if false
            title: 'iotapp',
            theme: ThemeData(
              brightness: Brightness.dark,
              //primarySwatch: Colors.blue,
            ),
            home: const HomePage(),
          );
        }));
  }
}
