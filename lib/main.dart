import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

import 'package:storage_practice/ResultPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Storage Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final birthDateController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var birthDate;
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.json');
  }

  Future<File> writeToFile() async {
    final file = await _localFile;
    if (!file.existsSync()) file.createSync();
    return file.writeAsString(jsonEncode({'birthday': birthDate.toString()}),
        mode: FileMode.writeOnly);
  }

  void saveToStorage() async {
    //add to shared preferences
    final shared_preferences = await SharedPreferences.getInstance();
    shared_preferences.setString('date', birthDate.toString());
    print('dont writing prefs');
    //add to sqlite db
    final database = openDatabase(
      join(await getDatabasesPath(), 'birthday_database.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE IF NOT EXISTS birthday(id INTEGER PRIMARY KEY AUTOINCREMENT, birthdate TEXT)');
      },
      version: 1,
    );
    final db = await database;
    await db.insert('birthday', {'birthdate': birthDate.toString()});
    print('done writing db'); //add to file
    await writeToFile();
    print('done writing file');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'birthday'),
                        readOnly: true,
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now());
                          if (date != null) {
                            setState(() {
                              birthDateController.text =
                                  DateFormat.yMMMMd().format(date);
                              birthDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          saveToStorage();
                        }
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      child: const Text('Save Birthday'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ResultPage()));
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)))),
                child: const Text('See Stored Data'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
