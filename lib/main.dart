import 'package:flutter/material.dart';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';

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
  final data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  NfcApduCommand? nfcApduCommand;

  @override
  void initState() {
    super.initState();

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
        body: nfcState == NfcState.enabled
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Text(
                      'NFC Durumu: ${nfcState.name}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 200,
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
                  ])
            : Center(
                child: Text(
                'Oh no...\nNFC is ${nfcState.name}',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ) // This trailing comma makes auto-formatting nicer for build methods.
                ));
  }
}
