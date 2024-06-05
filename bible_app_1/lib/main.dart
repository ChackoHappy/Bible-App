import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

import 'package:bible_app_1/bible/english.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 59, 41, 35)),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Bible App'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<TextSpan> _verses = [
    const TextSpan(text: "TEMP VALUE", style: TextStyle(fontSize: 20))
  ];
  @override
  void initState() {
    startAsyncInit();
    super.initState();
  }

  Future startAsyncInit() async {
    final temp = await _getVerses();
    setState(() {
      _verses = temp;
    });
  }

  String _numToUnicode(int num) {
    String strNum = num.toString();
    List<String> unicode = [];
    for (var i = 0; i < strNum.length; i++) {
      switch (strNum[i]) {
        case '0':
          unicode.add("\u2070");
          break;
        case '1':
          unicode.add("\u00B9");
          break;
        case '2':
          unicode.add("\u00B2");
          break;
        case '3':
          unicode.add("\u00B3");
          break;
        case '4':
          unicode.add("\u2074");
          break;
        case '5':
          unicode.add("\u2075");
          break;
        case '6':
          unicode.add('\u2076');
          break;
        case '7':
          unicode.add("\u2077");
          break;
        case '8':
          unicode.add("\u2078");
          break;
        case '9':
          unicode.add("\u2079");
          break;
        default:
          break;
      }
    }
    return unicode.join();
  }

  Future<List<TextSpan>> _getVerses() async {
    final client = http.Client();
    final jsonResponse = json.decode(await client.read(Uri.http(
        'raw.githubusercontent.com',
        '/kenyonbowers/Bible-JSON/main/JSON/Mark/1.json')));
    List<TextSpan> verses = [];
    for (var i = 0; i < jsonResponse['verses'].length; i++) {
      String currStr = jsonResponse['verses'][i]['text'];
      if (currStr.contains("¶")) {
        verses.add(const TextSpan(text: "\n"));
        currStr = currStr.replaceAll("¶ ", "");
      }
      verses.add(TextSpan(
          text: _numToUnicode(i + 1), style: const TextStyle(fontSize: 20)));
      List<String> tempSplit = currStr.split("<em>");
      for (var k = 0; k < tempSplit.length; k++) {
        if (!tempSplit[k].contains("</em>")) {
          verses.add(TextSpan(text: tempSplit[k]));
        } else {
          //Italicized portion
          List<String> finalSplit = tempSplit[k].split("</em>");
          verses.add(TextSpan(
              text: finalSplit[0],
              style: const TextStyle(fontStyle: FontStyle.italic)));
          verses.add(TextSpan(text: finalSplit[1]));
        }
      }
    }
    return verses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 20),
                children: <TextSpan>[
                  for (var verse in _verses) verse,
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
