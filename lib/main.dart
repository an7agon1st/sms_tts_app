import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sms/sms.dart';
import 'dart:async';
import 'dart:io';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String smsMessage;

  @override
  void initState() {
    receiver.onSmsReceived.listen((SmsMessage msg) {
      setState(() {
        smsMessage = msg.body;
      });
      return print(msg.body);
    });
    super.initState();
  }

  SmsReceiver receiver = new SmsReceiver();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Sms Reader'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text(smsMessage == null ? 'No Message Recieved' : smsMessage),
            ),
          ),
          TextToSpeech(),
        ],
      ),
    );
  }
}

class TextToSpeech extends StatefulWidget {
  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech> {
  String smsMessage;
  List<String> smsMessages = [];

  FlutterTts flutterTts = new FlutterTts();
  @override
  void initState() {
    receiver.onSmsReceived.listen((SmsMessage msg) {
      setState(() {
        smsMessages.add(msg.body);
        smsMessage = msg.body;
      });
      _speak();
      return print(msg.body);
    });
    super.initState();
  }

  SmsReceiver receiver = new SmsReceiver();

  Future _speak() async {
    List<dynamic> languages = await flutterTts.getLanguages;

    await flutterTts.setLanguage("en-IN");

    await flutterTts.setSpeechRate(1.0);

    await flutterTts.setVolume(1.0);

    await flutterTts.setPitch(1.0);

    await flutterTts.isLanguageAvailable("en-IN");
    await flutterTts
        .speak(smsMessage == null ? 'No message recieved' : smsMessage);
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _speakThis(String message) async {
    List<dynamic> languages = await flutterTts.getLanguages;

    await flutterTts.setLanguage("en-IN");

    await flutterTts.setSpeechRate(1.0);

    await flutterTts.setVolume(1.0);

    await flutterTts.setPitch(1.0);

    await flutterTts.isLanguageAvailable("en-IN");
    await flutterTts.speak(message);
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    await flutterTts.stop();
    // if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Container(
            color: Colors.amber[50],
            child: smsMessages.length == 0
                ? Center(
                    child: Text('SMSes you recieve will show up here'),
                  )
                : ListView.builder(
                    itemCount: smsMessages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color:
                            index % 2 == 0 ? Colors.amber[50] : Colors.yellow[50],
                        child: ListTile(
                          leading: Icon(Icons.message),
                          title: Text(smsMessages[index]),
                          onTap: () {
                            smsMessage = smsMessages[index];
                            _speakThis(smsMessages[index]);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              color: Colors.yellow,
              child: Text('Speak'),
              onPressed: _speak,
            ),
            RaisedButton(
              onPressed: _stop,
              child: Text('Stop'),
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }
}
