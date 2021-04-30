import 'dart:async';
import 'package:flutter/material.dart';

import '../model/model.dart';
import '../util/dbhelper.dart';
import '../util/utils.dart';
import './taskdetail.dart';

// Menu item
const menuReset = "Restaurar dados locais";
List<String> menuOptions = const <String> [menuReset];

class TaskList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  DbHelper dbh = DbHelper();
  List<Task> tasks;
  int count = 0;
  DateTime cDate;

  @override
  void initState(){
    super.initState();
  }

  Future getData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then(
      // result here is the actual reference to the database object.
      (result) {
        final tasksFuture = dbh.getTasks();
        tasksFuture.then(
          // result here is the list of tasks in the database.
          (result) {
            if (result.length >= 0) {
              List<Task> taskList = [];
              var count = result.length;
              for (int i = 0; i <= count - 1; i++) {
                taskList.add(Task.fromOject(result[i]));
              }
              setState(() {
                if (this.tasks.length > 0) {this.tasks.clear();}
                this.tasks = taskList;
                this.count = count;
              });
            }
          }
        );
      }
    );
  }

  void _checkDate() {
    const secs = const Duration(seconds: 10);
    new Timer.periodic(secs, (Timer t) {
      DateTime nw = DateTime.now();
      if (cDate.day != nw.day ||
          cDate.month != nw.month ||
          cDate.year != nw.year) {
        getData();
        cDate = DateTime.now();
      }
    });
  }

  void navigateToDetail(Task task) async {
    bool r = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => TaskDetail(task))
    );
    if (r == true) {
      getData();
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Restaurar"),
          content: new Text("Deseja apagar todos os dados locais?"),
          actions: <Widget>[
            TextButton(
              child: new Text("Cancelar"),
              onPressed: () {Navigator.of(context).pop();},
            ),
            TextButton(
              child: new Text("Sim"),
              onPressed: () {
                Future f = _resetLocalData();
                f.then((result) {Navigator.of(context).pop();});
              },
            ),
          ],
        );
      },
    );
  }

  Future _resetLocalData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result) {
      final dTasks = dbh.deleteRows(DbHelper.tableTasks);
      dTasks.then((result) {
        setState(() {
          this.tasks.clear();
          this.count = 0;
        });
      });
    });
  }

  void _selectMenu(String value) async {
    switch (value) {
      case menuReset:
        _showResetDialog();
    }
  }

  ListView taskListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        String dd = Val.getExpiryStr(this.tasks[position].expiration);
        String dl = (dd != "1") ? " dias restantes" : " dia restante";
        return Card(
          color: Colors.white,
          elevation: 1.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
              (Val.getExpiryStr(this.tasks[position].expiration) != "0") ?
              Colors.blue : Colors.red,
              child: Text(
                this.tasks[position].id.toString(),
              ),
            ),
            title: Text(this.tasks[position].title),
            subtitle: Text(
              Val.getExpiryStr(this.tasks[position].expiration) + dl + "\nExp: "
              + DateUtil.convertToDateFull(this.tasks[position].expiration)
            ),
            onTap: () {
              navigateToDetail(this.tasks[position]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    this.cDate = DateTime.now();
    if (this.tasks == null) {
      this.tasks = [];
      getData();
    }
    _checkDate();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("TaskExpire"),
        actions: <Widget>[PopupMenuButton(
          onSelected: _selectMenu,
          itemBuilder: (BuildContext context) {
            return menuOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        )]
      ),
      body: Center(child: Scaffold(
        body: Stack(children: <Widget>[taskListItems()]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetail(Task.withId(-1, "", "", 1, 1, 1, 1));
          },
          tooltip: "Add new doc",
          child: Icon(Icons.add)
        )
      ))
    );
  }
}
