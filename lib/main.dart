import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sms/sms.dart';
import 'dart:async';
import 'package:translator/translator.dart';
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Sms Reader'),
        centerTitle: true,
      ),
      body: TextToSpeech(),
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
  List<String> smsMessagesHindi = [];
  List<SmsMessage> allMessages = [];

  FlutterTts flutterTts = new FlutterTts();
  final translator = new GoogleTranslator();
  SmsQuery query = new SmsQuery();

  _getSMSMessages() async {
    allMessages = await query.querySms(count: 50);
    // translator.translate('hello', from: 'en', to: 'hi').then((value) {
    //   print("translated $value");
    // });
    setState(() {});
  }

  @override
  void initState() {
    _getSMSMessages();
    receiver.onSmsReceived.listen((SmsMessage msg) {
      setState(() {
        allMessages.add(msg);
        smsMessages.add(msg.body);
        smsMessage = msg.body;
      });
      _speakThis(smsMessage);
      return print(msg.body);
    });
    super.initState();
  }

  SmsReceiver receiver = new SmsReceiver();

  Future _speakThis(String message) async {
    // List<dynamic> languages = await flutterTts.getLanguages;

    await flutterTts.setLanguage("en-IN");

    await flutterTts.setSpeechRate(0.8);

    await flutterTts.setVolume(1.0);

    await flutterTts.setPitch(1.0);

    await flutterTts.isLanguageAvailable("en-IN");

    if (message.split('-').length == 3) {
      await flutterTts.speak(
          '${message.split('-')[0]} has dedicated the song ${message.split('-')[2]} to ${message.split('-')[1]}');
    } else
      await flutterTts.speak(message);
  }

  Future _speakThisInHindi(String message) async {
    // List<dynamic> languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage("hi-IN");

    await flutterTts.setSpeechRate(0.7);

    await flutterTts.setVolume(1.0);

    await flutterTts.setPitch(1.0);

    await flutterTts.isLanguageAvailable("hi-IN");

    if (message.split('-').length == 3) {
      await flutterTts.speak(
          '${message.split('-')[0]} ने ${message.split('-')[1]} को ${message.split('-')[2]} गाना समर्पित किया है');
    } else
      await flutterTts.speak(message);
  }

  Future _stop() async {
    await flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.amber[50],
            child: allMessages.length == 0
                ? Center(
                    child: Text('SMSes you recieve will show up here'),
                  )
                : ListView.builder(
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: index % 2 == 0
                            ? Colors.amber[50]
                            : Colors.yellow[50],
                        child: FutureBuilder<String>(
                            future: translator.translate(
                                allMessages[index].body,
                                from: 'en',
                                to: 'hi'),
                            builder: (context, translatedText) {
                              return ListTile(
                                leading: Icon(Icons.message),
                                title: Text(allMessages[index].body),
                                subtitle: Text(translatedText.data == null
                                    ? 'Translating'
                                    : translatedText.data),
                                onTap: () {
                                  smsMessage = allMessages[index].body;
                                  _speakThis(allMessages[index].body);
                                },
                                onLongPress: () {
                                  _speakThisInHindi(translatedText.data == null
                                      ? 'Cannot translate'
                                      : translatedText.data);
                                },
                              );
                            }),
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
              onPressed: () {
                _speakThis(smsMessage);
              },
            ),
            RaisedButton(
              onPressed: _stop,
              child: Text('Stop'),
              color: Colors.amber,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Text('Tap for english, Long tap for hindi\nName-DedicatedToName-SongName'),
        )
      ],
    );
  }
}
