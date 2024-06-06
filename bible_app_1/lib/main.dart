import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

import 'package:bible_app_1/bible.dart';
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
    const TextSpan(text: "Loading...", style: TextStyle(fontSize: 20))
  ];

  int bookIndx = 1;
  int chapterIndx = 1;

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

  //Fetches verses and places them in a List of TextSpans
  Future<List<TextSpan>> _getVerses() async {
    final client = http.Client();
    //Get JSON
    final jsonResponse = json.decode(await client.read(Uri.http(
        'raw.githubusercontent.com',
        '/kenyonbowers/Bible-JSON/main/JSON/${Bible.books[bookIndx - 1]}/$chapterIndx.json')));
    List<TextSpan> verses = [];
    //Build List
    for (var i = 0; i < jsonResponse['verses'].length; i++) {
      String currStr = jsonResponse['verses'][i]['text'];
      //Add newline if verse has ¶
      if (currStr.contains("¶")) {
        verses.add(const TextSpan(text: "\n"));
        currStr = currStr.replaceAll("¶ ", "");
      }
      //Add verse number
      verses.add(TextSpan(
          text: " ${_numToUnicode(i + 1)} ",
          style: const TextStyle(fontSize: 20)));
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // Dropdown for selecting the book
              DropdownButton<String>(
                value: Bible.books[bookIndx - 1],
                onChanged: (newValue) async {
                  bookIndx = Bible.books.indexOf(newValue!) + 1;
                  chapterIndx = 1;
                  final temp = await _getVerses();
                  setState(() {
                    _verses = temp;
                  });
                },
                items: Bible.books.map<DropdownMenuItem<String>>((String book) {
                  return DropdownMenuItem<String>(
                    value: book,
                    child: Text(book),
                  );
                }).toList(),
              ),
              // Dropdown for selecting the chapter
              DropdownButton<String>(
                value: chapterIndx.toString(),
                onChanged: (newValue) async {
                  chapterIndx = int.parse(newValue!);
                  final temp = await _getVerses();
                  setState(() {
                    _verses = temp;
                  });
                },
                items: List<int>.generate(
                        Bible.bookLengths[chapterIndx], (i) => i + 1)
                    .map<DropdownMenuItem<String>>((int chapter) {
                  return DropdownMenuItem<String>(
                    value: chapter.toString(),
                    child: Text(chapter.toString()),
                  );
                }).toList(),
              ),
            ]),
            // Display contents of the chapter
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    children: <TextSpan>[
                      for (var verse in _verses) verse,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
