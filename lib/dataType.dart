import 'main.dart';
import 'dataTypeDialog.dart';
import 'dataEditor.dart';
import 'dataType.dart';

import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

List<String> dataTypeDocuments = List();
class DataSelectLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushNamed('GameList'),
        ),
        title: Text("データ一覧"),
        centerTitle: true,
      ),
      body: StateHome(key: key, selectScane: scaneType.dataTypeSelect),
    );
  }
}

class DataTypeSelect extends State<StateHome> {
  final List<DataType> dataList = new List();

  void addItem(List<modelData> modelType, List<String> dataName, String title,
      String lore, int index) {
    List<int> dataTypeNumber = new List();
    modelType.forEach((modelData dt) {
        dataTypeNumber.add(dt.index);
      });
    if (index == -1) {
      selectRoom.collection("dataSelect").add({
        "dataLore": lore,
        "dataName": title,
        "dataNameList": dataName,
        "modelDataList": dataTypeNumber,
      }).then((col)=>{
        dataTypeDocuments.add(col.documentID),
      });
    } else {
      selectRoom.collection("dataSelect").document(dataTypeDocuments[index]).setData({
        "dataLore": lore,
        "dataName": title,
        "dataNameList": dataName,
        "modelDataList": dataTypeNumber,
      });
    }
  }

  @override
  void initState() {
    debugPrint("debug");
    List<modelData> modelList = List(); //Dart List<T>　変換できない？
    selectRoom
        .collection("dataSelect")
        .getDocuments()
        .then((qs) => {
              qs.documents.forEach((doc) {
                modelList.clear();
                debugPrint("clear!");
                doc.data["modelDataList"].forEach((f) {
                  modelList.add(modelData.values[f]);
                                  debugPrint(modelData.values[f].toString() + ";;");
                });
                debugPrint(modelList.toString() + "`@`");
                dataList.add(DataType(
                    modelList,
                    (doc.data["dataNameList"] as List)
                        .map((s) => (s as String).toUpperCase())
                        .toList(),
                    doc.data["dataName"],
                    doc.data["dataLore"]));
                dataTypeDocuments.add(doc.documentID);
                debugPrint(doc.documentID);
                
              }),
              dataList.forEach((f){
                  f.modelDataList.forEach((f){
                    debugPrint(f.toString() + "*+*+*+");
                  });
                }),

                dataList.forEach((f){
                  f.modelDataList.forEach((f){
                    debugPrint("*****" + f.toString());
                  });
                }),
            })
        .whenComplete(() => {
              setState(() {}),
            });
            

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime[100],
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            background: Container(color: Colors.red),
            key: Key(""),
            onDismissed: (direction) {
              setState(() {
                dataList.removeAt(index);
              });
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("削除")));
            },
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('DataEditor');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataEditor(
                      key: Key("value"),
                      dataType: dataList[index],
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      dataDialog(index: index, arriveData: dataList[index]),
                );
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("登録")));
              },
              child: Card(
                color: Colors.green[100],
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(dataList[index].dataTitle),
                        leading: Icon(Icons.person),
                        subtitle: Text(dataList[index].dataLore),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Text("最終編集日 "),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: dataList.length,
      ),
      bottomNavigationBar: Stack(
        children: <Widget>[
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text("戻る"),
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), title: Text("設定")),
            ],
            onTap: (int index) {
              switch (index) {
                case 0:
                  Navigator.pop(context);
                  break;
                case 1:
                  break;
                default:
                  break;
              }
            },
          ),
          Container(
            alignment: Alignment.center,
            height: 50,
            child: FractionalTranslation(
              translation: Offset(0, -0.5),
              child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => dataDialog(index: -1),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class dataDialog extends StatefulWidget {
  dataDialog({Key key, this.index, this.arriveData}) : super(key: key);
  final DataType arriveData;
  final int index;
  @override
  dataDialogState createState() => dataDialogState();
}
