import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ResultPage extends StatefulWidget {
  ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late List<dynamic> dbList;
  Map<String, dynamic> fileList = {};
  Future<void> getDbData() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'birthday_database.db'),
    );
    final db = await database;
    final List birthdays = await db.query('birthday');
    dbList = birthdays;
  }

  getSharedPrefsData() async {
    final shared_prefs = await SharedPreferences.getInstance();
    return shared_prefs.getString('date');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.json');
  }

  Future<void> readFromFile() async {
    final file = await _localFile;
    if (file.existsSync() && file.readAsStringSync().isNotEmpty) {
      fileList = jsonDecode(file.readAsStringSync());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  color: Colors.blue.shade300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'SharedPreferences:',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 100,
                        width: 150,
                        child: Center(
                          child: FutureBuilder(
                            future: getSharedPrefsData(),
                            builder: (context, key) {
                              switch (key.connectionState) {
                                case ConnectionState.waiting:
                                  return CircularProgressIndicator();
                                default:
                                  return key.hasData && key.data != null
                                      ? Text(DateFormat.yMMMMd().format(
                                          DateTime.parse(key.data.toString())))
                                      : Text('no data');
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20.0),
                color: Colors.blue.shade300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'From File: ',
                      textAlign: TextAlign.center,
                      textScaleFactor: 1,
                    ),
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: Center(
                        child: FutureBuilder(
                          future: readFromFile(),
                          builder: (context, key) {
                            switch (key.connectionState) {
                              case ConnectionState.waiting:
                                return CircularProgressIndicator();
                              default:
                                return fileList.length != 0
                                    ? Text(DateFormat.yMMMMd().format(
                                        DateTime.parse(fileList['birthday'])))
                                    : Text('no data');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'From SQlite:',
                  textAlign: TextAlign.center,
                  textScaleFactor: 1,
                ),
              ),
              Card(
                child: SizedBox(
                  height: 250,
                  width: 350,
                  child: FutureBuilder(
                    future: getDbData(),
                    builder: (context, key) {
                      switch (key.connectionState) {
                        case ConnectionState.waiting:
                          return CircularProgressIndicator();
                        default:
                          return Container(
                            color: Colors.blue.shade300,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ListView.builder(
                                itemCount: dbList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: Text(
                                      DateFormat.yMMMMd().format(
                                          DateTime.tryParse(
                                                  dbList[index]['birthdate']) ??
                                              DateTime.now()),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                      }
                    },
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
