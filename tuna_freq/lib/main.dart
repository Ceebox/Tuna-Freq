import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';

void main() => runApp(Application());

class Application extends StatefulWidget {
  @override
  ApplicationState createState() => ApplicationState();
}

class ApplicationState extends State<Application> {
  Color gray = const Color(0xFF1A1A1A);

  double? frequency;
  String? note;
  int? octave;
  bool? isRecording;

  FlutterFft flutterFft = FlutterFft();

  _initialize() async {
    // Keep asking for mic permission until it is accepted
    while (!(await flutterFft.checkPermission())) {
      flutterFft.requestPermission();
    }

    // await flutterFft.checkPermissions();
    await flutterFft.startRecorder();
    setState(() => isRecording = flutterFft.getIsRecording);

    flutterFft.onRecorderStateChanged.listen(
            (data) => {
          setState(() => {
              frequency = data[1] as double,
              note = data[2] as String,
              octave = data[5] as int,
            },
          ),
          flutterFft.setNote = note!,
          flutterFft.setFrequency = frequency!,
          flutterFft.setOctave = octave!,
        });
  }

  @override
  void initState() {
    isRecording = flutterFft.getIsRecording;
    frequency = flutterFft.getFrequency;
    note = flutterFft.getNote;
    octave = flutterFft.getOctave;

    flutterFft.setSubscriptionDuration = 0.08; //Faster update

    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Tuna Freq",
        theme: ThemeData.dark(),
        color: Colors.blue,
        home: Scaffold(
          backgroundColor: gray,
          body: Column(
            children: [
              AppBody(),
            ],
          )
        ));
  }

  Center AppBody()
  {
    return Center(
      heightFactor: 5,
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: isRecording!
                  ? Text("Current note: ${note!} : ${octave!.toString()}",
                  style: TextStyle(fontSize: 30, color: gray))
                  : Text("Not Recording", style: TextStyle(fontSize: 35, color: gray)),
            ),
            Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: isRecording!
                    ? Text(
                  "Current frequency:            \n ${frequency!.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 30, color: gray),
                  textAlign: TextAlign.center,)
                    : Text("Not Recording", style: TextStyle(fontSize: 35, color: gray))
            )
          ].map((e) => Padding(padding: const EdgeInsets.all(10), child: e)).toList(),
        )
    );
  }
}