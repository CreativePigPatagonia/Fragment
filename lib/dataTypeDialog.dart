import 'main.dart';
import 'dataType.dart';
import 'dataEditor.dart';

import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class dataDialogState extends State<dataDialog> {
  TextEditingController dataTypeTitle = new TextEditingController();
  TextEditingController dataTypeLore = new TextEditingController();
  List<TextEditingController> dataLore = new List();
  DataType menuDataType;
  String modelText = "";
  

  void _addMenuItem(modelData md) {
    setState(() {
      dataLore.add(new TextEditingController());
      menuDataType.modelDataList.add(md);
    });
  }

  @override
  void initState() {
    debugPrint("init:" + widget.index.toString());
    
    menuDataType = new DataType(
    new List<modelData>(), new List<String>(), "dataTitle", "dataLore");
    widget.arriveData.modelDataList.forEach((f){
      debugPrint(f.toString());
    });
    widget.arriveData.dataNameList.forEach((f){
      debugPrint(f.toString());
    });
    
    super.initState();
  }

  Widget _buildButton(int index) {
    return RaisedButton(
      color: Colors.lightGreen[100],
      onPressed: () {
        dataLore.forEach((TextEditingController f) {
          menuDataType.dataNameList.add(f.text);
        });
        DataTypeSelect().addItem(
            menuDataType.modelDataList,
            menuDataType.dataNameList,
            dataTypeTitle.text,
            dataTypeLore.text,
            index
        );

        dataTypeTitle.clear();
        dataTypeLore.clear();
        Navigator.pop(context);
        Navigator.of(context).pushNamed('DataList');
      },
      child: Text(
        '新しいデータリストを作る',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      backgroundColor: Colors.yellow[100],
      contentPadding: EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: dataShowDialog(),
      ),
    );
  }

  Widget dataShowDialog() {
    if (widget.arriveData != null) {
      dataTypeTitle.text = widget.arriveData.dataTitle;
      dataTypeLore.text = widget.arriveData.dataLore;
      for (int i = 0; i < widget.arriveData.dataNameList.length; i++) {
        _addMenuItem(widget.arriveData.modelDataList[i]);
        dataLore[i].text = widget.arriveData.dataNameList[i];
      }
    }
    return Column(
      children: <Widget>[
        Text("データリストの名前", textAlign: TextAlign.left),
        TextField(
          controller: dataTypeTitle,
          decoration: InputDecoration(hintText: "入力してください。"),
        ),
        Text("データリストの説明", textAlign: TextAlign.left),
        TextField(
          controller: dataTypeLore,
          decoration: InputDecoration(hintText: "入力してください。"),
        ),
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Int", style: TextStyle(fontSize: 25)),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 25,
                    width: 25,
                    child: FractionalTranslation(
                      translation: Offset(0, 0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _addMenuItem(modelData.intData);
                        },
                        backgroundColor: Colors.lime[300],
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
              Text(" Float", style: TextStyle(fontSize: 25)),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 25,
                    width: 25,
                    child: FractionalTranslation(
                      translation: Offset(0, 0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _addMenuItem(modelData.floatData);
                        },
                        backgroundColor: Colors.lime[300],
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
              Text(" Bool", style: TextStyle(fontSize: 25)),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 25,
                    width: 25,
                    child: FractionalTranslation(
                      translation: Offset(0, 0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _addMenuItem(modelData.boolData);
                        },
                        backgroundColor: Colors.lime[300],
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(" String", style: TextStyle(fontSize: 25)),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 25,
                    width: 25,
                    child: FractionalTranslation(
                      translation: Offset(0, 0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _addMenuItem(modelData.stringData);
                        },
                        backgroundColor: Colors.lime[300],
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
              Text(" Image", style: TextStyle(fontSize: 25)),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 25,
                    width: 25,
                    child: FractionalTranslation(
                      translation: Offset(0, 0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _addMenuItem(modelData.imageData);
                        },
                        backgroundColor: Colors.lime[300],
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
              Text(" Text", style: TextStyle(fontSize: 25)),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 25,
                    width: 25,
                    child: FractionalTranslation(
                      translation: Offset(0, 0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _addMenuItem(modelData.textData);
                        },
                        backgroundColor: Colors.lime[300],
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //Expanded(
        Container(
          height: 270,
          width: 350,
          decoration: new BoxDecoration(
            color: Colors.lightGreen[100],
            borderRadius: new BorderRadius.circular(10.0),
          ),
          child: setListTile(),
        ),
        //),

        const SizedBox(height: 30, width: 120),
        _buildButton(widget.index),
      ],
    );
  }

  Widget setListTile() {
    return ListView.builder(
      itemCount: menuDataType.modelDataList.length,
      itemBuilder: (context, int index) {
        switch (menuDataType.modelDataList[index]) {
          case modelData.intData:
            modelText = "Int";
            break;
          case modelData.floatData:
            modelText = "Float";
            break;
          case modelData.boolData:
            modelText = "Bool";
            break;
          case modelData.stringData:
            modelText = "String";
            break;
          case modelData.imageData:
            modelText = "Image";
            break;
          case modelData.textData:
            modelText = "Text";
            break;
          default:
            break;
        }
        return Dismissible(
          background: Container(
            color: Colors.red,
            child: Icon(Icons.cancel),
          ),
          key: Key(""),
          onDismissed: (direction) {
            setState(() {
              log("dataLoreCount:" + dataLore.length.toString());
              //dataLore.removeAt(index);
              //widget.arriveData.dataNameList.removeAt(index);
              //widget.arriveData.modelDataList.removeAt(index);

              menuDataType.dataNameList.removeAt(index);
              menuDataType.modelDataList.removeAt(index);
            });
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("削除")));
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.lightGreen[200],
              child: Text(modelText),
            ),
            title: TextField(
              controller: dataLore[index],
              decoration: InputDecoration(hintText: "入力してください。"),
            ),
          ),
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }
}