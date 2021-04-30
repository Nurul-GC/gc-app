import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:io';

import '../model/model.dart';

class DbHelper{
  // Tables
  static String tableTasks = "Docs";

  // Fields of the 'docs' table.
  String taskId = "id";
  String taskTitle = "title";
  String taskExpiration = "expiration";

  String freqYear = "freqYear";
  String freqHalfYear = "freqHalfYear";
  String freqQuarter = "freqQuarter";
  String freqMonth = "freqMonth";

  // Singleton
  static final DbHelper _dbHelper = DbHelper._internal();

  // Factory constructor
  DbHelper._internal();
  factory DbHelper(){
    return _dbHelper;
  }

  // Database entry point
  static Database _db;

  Future<Database> get db async{
    if (_db == null){
      _db = await initializeDb();
    }
    return _db;
  }

  // Initialize the database
  Future<Database> initializeDb() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "/taskexpire.db";
    var db = await openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  // Create database table
  void _createDb(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableTasks($taskId INTEGER PRIMARY KEY, $taskTitle TEXT, " +
        "$taskExpiration TEXT, $freqYear INTEGER, $freqHalfYear INTEGER, " +
        "$freqQuarter INTEGER, $freqMonth INTEGER)"
    );
  }

  // Insert a new doc
  Future<int> insertTask(Task task) async {
    var raw;
    Database db = await this.db;
    try {
      raw = await db.insert(tableTasks, task.toMap());
    } catch (erro) {
      debugPrint("insertTask: " + erro.toString());
    }
    return raw;
  }

  // Get the list of docs.
  Future<List> getTasks() async {
    Database db = await this.db;
    var raw = await db.rawQuery("SELECT * FROM $tableTasks ORDER BY $taskExpiration ASC");
    return raw;
  }

  // Gets a Doc based on the id.
  Future<List> getTask(int id) async{
    Database db = await this.db;
    var raw = await db.rawQuery(
        "SELECT * FROM $tableTasks WHERE $taskId = " + id.toString() + "");
    return raw;
  }

  // Gets a Doc based on a String payload
  Future<List> getTaskFromStr(String payload) async{
    List<String> pload = payload.split("|");
    if (pload.length == 2){
      Database db = await this.db;
      var raw = await db.rawQuery(
          "SELECT * FROM $tableTasks WHERE $taskId = " + pload[0] +
          " AND $taskExpiration = '" + pload[1] + "'");
      return raw;
    } else
        return null;
  }

  // Get the number of docs.
  Future<int> getTasksCount() async{
    Database db = await this.db;
    var raw = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tableTasks")
    );
    return raw;
  }

  // Get the max document id available on the database.
  Future<int> getMaxId() async{
    Database db = await this.db;
    var raw = Sqflite.firstIntValue(
        await db.rawQuery("SELECT MAX(id) FROM $tableTasks")
    );
    return raw;
  }

  // Update a doc.
  Future<int> updateTask(Task task) async{
    var db = await this.db;
    var raw = await db.update(
        tableTasks,
        task.toMap(),
        where: "$taskId = ?",
        whereArgs: [task.id]
    );
    return raw;
  }

  // Delete a doc.
  Future<int> deleteTask(int id) async{
    var db = await this.db;
    int raw = await db.rawDelete("DELETE FROM $tableTasks WHERE $taskId = $id");
    return raw;
  }

  // Delete all docs.
  Future<int> deleteRows(String table) async{
    var db = await this.db;
    int raw = await db.rawDelete("DELETE FROM $table");
    return raw;
  }
}
