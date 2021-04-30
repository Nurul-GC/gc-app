import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../model/model.dart';
import '../util/utils.dart';
import '../util/dbhelper.dart';

// Menu item
const menuDelete = "Delete";
final List<String> menuOptions = const <String> [
  menuDelete
];

class TaskDetail extends StatefulWidget {
  final Task task;
  final DbHelper dbh = DbHelper();

  TaskDetail(this.task);

  @override
  State<StatefulWidget> createState() => TaskDetailState();
}

class TaskDetailState extends State<TaskDetail> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final int daysAhead = 5475; // 15 years in the future.
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController expirationCtrl = MaskedTextController(
      mask: '2000-01-01'
  );
  bool freqYearCtrl = true;
  bool freqHalfYearCtrl = true;
  bool freqQuarterCtrl = true;
  bool freqMonthCtrl = true;
  bool freqLessMonthCtrl = true;

  // Initialization code
  void _initCtrls() {
    titleCtrl.text = widget.task.title != null ? widget.task.title : "";
    expirationCtrl.text = widget.task.expiration != null ?
        widget.task.expiration : "";
    freqYearCtrl = widget.task.freqYear != null ?
        Val.intToBool(widget.task.freqYear) : false;
    freqHalfYearCtrl = widget.task.freqHalfYear != null ?
        Val.intToBool(widget.task.freqHalfYear) : false;
    freqQuarterCtrl = widget.task.freqQuarter != null ?
        Val.intToBool(widget.task.freqQuarter) : false;
    freqMonthCtrl = widget.task.freqMonth != null ?
        Val.intToBool(widget.task.freqMonth) : false;
  }

  // Date Picker & Date function
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = DateUtil.convertToDate(initialDateString) ?? now;

    initialDate = (
        initialDate.year >= now.year &&
            initialDate.isAfter(now) ? initialDate : now
    );

    DatePicker.showDatePicker(
        context, showTitleActions: true, onConfirm: (date) {
          setState(() {
            DateTime dt = date;
            String r = DateUtil.formatDateAsStr(dt);
            expirationCtrl.text = r;
          });
        },
        currentTime: initialDate
    );
  }

  // Upper Menu
  void _selectMenu(String value) async {
    switch (value) {
      case menuDelete:
        if (widget.task.id == -1) {
          return;
        }
        _deleteTask(widget.task.id);
    }
  }

  // Delete doc
  void _deleteTask(int id) async {
    // int raw = await widget.dbh.deleteDoc(widget.doc.id);
    widget.dbh.deleteTask(widget.task.id);
    Navigator.pop(context, true);
  }

  // Save doc
  void _saveTask() {
    widget.task.title = titleCtrl.text;
    widget.task.expiration = expirationCtrl.text;
    widget.task.freqYear = Val.boolToInt(freqYearCtrl);
    widget.task.freqHalfYear = Val.boolToInt(freqHalfYearCtrl);
    widget.task.freqQuarter = Val.boolToInt(freqQuarterCtrl);
    widget.task.freqMonth = Val.boolToInt(freqMonthCtrl);

    if (widget.task.id > -1) {
      debugPrint("_update->Task Id: " + widget.task.id.toString());
      widget.dbh.updateTask(widget.task);
      Navigator.pop(context, true);
    }else {
      Future<int> idd = widget.dbh.getMaxId();
      idd.then((result) {
        debugPrint("_insert->Task Id: " + widget.task.id.toString());
        widget.task.id = (result != null) ? result + 1 : 1;
        widget.dbh.insertTask(widget.task);
        Navigator.pop(context, true);
      });
    }
  }

  // Submit form
  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Algum dado inválido. Por favor corrija.');
    } else {
      _saveTask();
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message))
    );
  }

  @override
  void initState() {
    super.initState();
    _initCtrls();
  }

  @override
  Widget build(BuildContext context) {
    const String cStrDays = "Digite a quantidade de dias";
    TextStyle tStyle = Theme.of(context).textTheme.headline6;
    String ttl = widget.task.title;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(ttl != "" ? widget.task.title : "Nova Tarefa"),
        actions: (ttl == "") ? <Widget>[]: <Widget>[
          PopupMenuButton(onSelected: _selectMenu,
            itemBuilder: (BuildContext context) {
              return menuOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice)
                );
              }).toList();
            },
          ),
        ]
      ),
      body: Form(
        key: _formKey, autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              TextFormField (
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]"))
                ], controller: titleCtrl, style: tStyle,
                validator: (val) => Val.validateTitle(val),
                decoration: InputDecoration(
                  icon: const Icon(Icons.title),
                  hintText: 'Digite o nome da tarefa',
                  labelText: 'Nome Tarefa',
                ),
              ),
              Row(children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: expirationCtrl,
                    maxLength: 10,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_today),
                      hintText: 'Data Expiracão (i.e. ' +
                      DateUtil.daysAheadAsStr(daysAhead) + ')',
                      labelText: 'Data Expiracao'
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => DateUtil.isValiDate(val) ?
                    null : 'Não é uma data futura, válida',
                  )
                ),
                IconButton(
                  icon: new Icon(Icons.more_horiz),
                  tooltip: 'Selecionar data',
                  onPressed: (() {
                    _chooseDate(context, expirationCtrl.text);
                  }),
                )
              ]),
              Row(children: <Widget>[
                Expanded(child: Text(' ')),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('a: Alertar em 1 ano')),
                Switch(value: freqYearCtrl, onChanged: (bool value) {
                  setState(() {freqYearCtrl = value;});
                }),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('b: Alertar em 6 meses')),
                Switch(value: freqHalfYearCtrl, onChanged: (bool value) {
                  setState(() {freqHalfYearCtrl = value;});
                }),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('c: Alertar em 3 meses')),
                Switch(value: freqQuarterCtrl, onChanged: (bool value) {
                  setState(() {freqQuarterCtrl = value;});
                }),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('d: Alertar em 1 mes ou menos')),
                Switch(value: freqMonthCtrl, onChanged: (bool value) {
                  setState(() {freqMonthCtrl = value;});
                }),
              ]),
              Container(padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: ElevatedButton(
                  child: Text("Salvar"), onPressed: _submitForm,
                )
              ),
            ],
          ),
        )
      )
    );
  }
}
