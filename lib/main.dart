import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';
import 'package:shared_preferences/shared_preferences.dart';

late NfcState nfcState;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  nfcState = await NfcHce.checkDeviceNfcState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool apduAdded = false;

  final port = 0;
//Data to transmit
  var data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  NfcApduCommand? nfcApduCommand;

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    NfcHce.stream.listen((command) {
      setState(() => nfcApduCommand = command);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'NFC Durumu: ${nfcState.name}',
                  style: const TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 150,
                  width: 300,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        apduAdded ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ),
                    onPressed: () async {
                      if (apduAdded == false) {
                        await NfcHce.addApduResponse(port, data);
                      } else {
                        await NfcHce.removeApduResponse(port);
                      }
                      setState(() => apduAdded = !apduAdded);
                    },
                    child: FittedBox(
                      child: Text(
                        apduAdded
                            ? 'remove\n$data\nfrom\nport $port'
                            : 'add\n$data\nto\nport $port',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          color: apduAdded ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              ]),
        ));
  }

  getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> uuidString = prefs.getStringList("uuid") ?? [];
    List<int> uuid = [];
    if (uuidString.isEmpty) {
      for (int i = 0; i < 12; i++) {
        int rndNumber = Random().nextInt(100);
        uuid.add(rndNumber);
        uuidString.add(rndNumber.toString());
      }
      await prefs.setStringList("uuid", uuidString);
    } else {
      for (var e in uuidString) {
        uuid.add(int.tryParse(e) ?? 0);
      }
    }
    setState(() {
      data = uuid;
    });
    return uuid;
  }
}
