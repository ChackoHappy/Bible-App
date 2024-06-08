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
  List<int> _items = [];

  @override
  void initState() {
    startAsyncInit();
    super.initState();
    _updateItems();
  }

  Future startAsyncInit() async {
    final temp = await _getVerses();
    setState(() {
      _verses = temp;
    });
  }

  void _updateItems() {
    setState(() {
      _items =
          List<int>.generate(Bible.bookLengths[bookIndx - 1], (i) => i + 1);
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
      bool redCheck = false;
      bool emphCheck = false;
      int startIndx = 0;
      for (var k = 0; k < currStr.length; k++) {
        if (currStr[k] == '<') {
          //BEGIN RED
          if (currStr[k + 1] == 's') {
            if (emphCheck == true) {
              //ITALICS
              verses.add(TextSpan(
                  text: currStr.substring(startIndx, k),
                  style: const TextStyle(fontStyle: FontStyle.italic)));
            } else {
              //PLAIN
              verses.add(TextSpan(text: currStr.substring(startIndx, k)));
            }
            k += 25;
            startIndx = k;
            redCheck = true;
            //BEGIN ITALICS
          } else if (currStr[k + 1] == 'e') {
            if (redCheck == true) {
              //RED
              verses.add(TextSpan(
                  text: currStr.substring(startIndx, k),
                  style: const TextStyle(color: Colors.red)));
            } else {
              //PLAIN
              verses.add(TextSpan(text: currStr.substring(startIndx, k)));
            }
            k += 4;
            startIndx = k;
            emphCheck = true;
            //END RED
          } else if (currStr[k + 2] == 's') {
            if (emphCheck == true) {
              //RED AND ITALICS
              verses.add(TextSpan(
                  text: currStr.substring(startIndx, k),
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.red)));
            } else {
              //RED
              verses.add(TextSpan(
                  text: currStr.substring(startIndx, k),
                  style: const TextStyle(color: Colors.red)));
            }
            k += 7;
            startIndx = k;
            redCheck = false;
            //END ITALICS
          } else if (currStr[k + 2] == 'e') {
            if (redCheck == true) {
              //RED AND ITALICS
              verses.add(TextSpan(
                  text: currStr.substring(startIndx, k),
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.red)));
            } else {
              //ITALICS
              verses.add(TextSpan(
                  text: currStr.substring(startIndx, k),
                  style: const TextStyle(fontStyle: FontStyle.italic)));
            }
            k += 5;
            startIndx = k;
            emphCheck = false;
          }
        }
      }
      if (startIndx != currStr.length - 1) {
        verses
            .add(TextSpan(text: currStr.substring(startIndx, currStr.length)));
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
              DropdownMenu<String>(
                initialSelection: Bible.books[bookIndx - 1],
                label: const Text('Book'),
                onSelected: (String? newValue) async {
                  bookIndx = Bible.books.indexOf(newValue!) + 1;
                  chapterIndx = 1;
                  final temp = await _getVerses();
                  setState(() {
                    _verses = temp;
                  });
                  _updateItems();
                },
                dropdownMenuEntries:
                    Bible.books.map<DropdownMenuEntry<String>>((String book) {
                  return DropdownMenuEntry<String>(
                    value: book,
                    label: book,
                  );
                }).toList(),
              ),
              // Dropdown for selecting the chapter
              DropdownMenu<String>(
                initialSelection: chapterIndx.toString(),
                label: const Text("Chapter"),
                onSelected: (newValue) async {
                  chapterIndx = int.parse(newValue!);
                  final temp = await _getVerses();
                  setState(() {
                    _verses = temp;
                  });
                },
                dropdownMenuEntries:
                    _items.map<DropdownMenuEntry<String>>((int number) {
                  return DropdownMenuEntry<String>(
                    value: number.toString(),
                    label: number.toString(),
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
