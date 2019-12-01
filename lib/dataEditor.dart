import 'main.dart';

import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class DataEditor extends StatefulWidget {
  final DataType dataType;
  DataEditor({Key key, this.dataType}) : super(key: key);

  @override
  DataEditorState createState() => DataEditorState();
}

class DataType {
  final List<modelData> modelDataList;
  final List<String> dataNameList;
  String dataTitle;
  String dataLore;
  
  DataType(this.modelDataList, this.dataNameList, this.dataTitle, this.dataLore);
}

class DataEditorState extends State<DataEditor> {
  List<List<TextEditingController>> myController;
  List<List<dynamic>> myData;
  int pageCount = 3;
  int showPage = 0;

  int page = 0;
  int maxPage = 0;

  @override
  void initState() {
    super.initState();


    myController = List.generate(
        pageCount,
        (_) => List.generate(widget.dataType.dataNameList.length,
            (_) => TextEditingController()));
    myData = List.generate(
        pageCount,
        (_) =>
            List.generate(widget.dataType.dataNameList.length, (_) => dynamic));
    debugPrint("**" + myController.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime[100],
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushNamed('DataList'),
        ),
        title: Text(widget.dataType.dataTitle),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: PageController(
          initialPage: 0,
        ),
        itemBuilder: (BuildContext context, int page) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Card(
              color: Colors.deepOrangeAccent[100],
              child: pageItem(page, pageCount <= page),
            ),
          );
        },
        itemCount: pageCount + 1,
        onPageChanged: (page) {
          setState(() {
            showPage = page;
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Page' + (showPage + 1).toString() + '/' + maxPage.toString()),
        icon: Icon(Icons.book),
        backgroundColor: Colors.pink.shade100,
      ),
      bottomSheet: Container(
        height: 60,
        width: 140,
        child: RaisedButton.icon(
          icon: Icon(
            Icons.tag_faces,
            color: Colors.white,
          ),
          label: Text("確定"),
          onPressed: () {
            Navigator.of(context).pushNamed('DataList');
          },
          color: Colors.green,
          textColor: Colors.white,
        ),
      ),
    );
  }

  Widget pageItem(int page, bool addPage) {
    if (addPage) {
      return Center(
        child: FloatingActionButton(
            child: new Icon(Icons.add_circle),
            onPressed: () {
              setState(() {
                pageCount++;
                myController.add(List.generate(
                    widget.dataType.dataNameList.length,
                    (_) => TextEditingController()));
              });
            }),
      );
    } else {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: ListTile(
              leading: dataTypeView(index),
              title: Stack(
                children: <Widget>[
                  fieldType(page, index),
                ],
              ),
            ),
          );
        },
        itemCount: widget.dataType.dataNameList.length,
      );
    }
  }

  Widget dataTypeView(int index) {
    switch (widget.dataType.modelDataList[index]) {
      case modelData.boolData:
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.grey.shade800,
            child: Text(
              'Bool',
              style: TextStyle(fontSize: 11),
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          label: Text(widget.dataType.dataNameList[index]),
        );
        break;
      case modelData.floatData:
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.green.shade800,
            child: Text(
              'Float',
              style: TextStyle(fontSize: 10),
            ),
          ),
          backgroundColor: Colors.green.shade100,
          label: Text(widget.dataType.dataNameList[index]),
        );
        break;
      case modelData.imageData:
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.teal.shade800,
            child: Text(
              'Img',
              style: TextStyle(fontSize: 13),
            ),
          ),
          backgroundColor: Colors.teal.shade100,
          label: Text(widget.dataType.dataNameList[index]),
        );
        break;
      case modelData.intData:
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.orange.shade800,
            child: Text('Int'),
          ),
          backgroundColor: Colors.orange.shade100,
          label: Text(widget.dataType.dataNameList[index]),
        );
        break;
      case modelData.stringData:
        return Chip(
          //padding: EdgeInsets.all(30),
          avatar: CircleAvatar(
            radius: 180,
            backgroundColor: Colors.cyan.shade800,
            child: Text('Str'),
          ),
          backgroundColor: Colors.cyan.shade100,
          label: Text(widget.dataType.dataNameList[index]),
        );
        break;
      case modelData.textData:
        return Chip(
          avatar: CircleAvatar(
            minRadius: 100,
            backgroundColor: Colors.blue.shade800,
            child: Text(
              'Text',
              style: TextStyle(fontSize: 12),
            ),
          ),
          backgroundColor: Colors.blue.shade100,
          label: Text(widget.dataType.dataNameList[index]),
        );
        break;
      default:
    }
  }

  Widget fieldType(int page, int index) {
    debugPrint("index:" + index.toString());
    switch (widget.dataType.modelDataList[index]) {
      case modelData.boolData:
        return new Checkbox(key: null, onChanged: checkChanged, value: true);
        break;
      case modelData.floatData:
        return TextFormField(
            keyboardType: TextInputType.number,
            controller: myController[page][index],
            decoration: InputDecoration(
              hintText: '---',
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onFieldSubmitted: (_) => {
                  setState(() {
                    double n;
                    try {
                      n = double.parse(myController[page][index].text);
                    } catch (exception) {
                      n = 0;
                    }
                    myController[page][index].text = n.toString();
                  }),
                });
        break;
      case modelData.imageData:
        return Container(
            child: Card(
          child: Icon(Icons.settings),
        ));
        break;
      case modelData.intData:
        return TextFormField(
            keyboardType: TextInputType.number,
            controller: myController[page][index],
            decoration: InputDecoration(
              hintText: '---',
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onFieldSubmitted: (_) => {
                  setState(() {
                    int n;
                    try {
                      n = int.parse(myController[page][index].text);
                    } catch (exception) {
                      n = 0;
                    }
                    myController[page][index].text = n.toString();
                  }),
                });
        break;
      case modelData.stringData:
        return TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          controller: myController[page][index],
          decoration: InputDecoration(
            hintText: '---',
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
        );
        break;
      case modelData.textData:
        return TextFormField(
          minLines: 3,
          maxLines: 80,
          keyboardType: TextInputType.multiline,
          controller: myController[page][index],
          decoration: InputDecoration(
            hintText: '---',
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
        );
        break;

      default:
    }
  }
  
  void checkChanged(bool value) {
    debugPrint(value.toString());
    value != value;
  }
}