import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";

//https://qiita.com/matsukatsu/items/e289e30231fffb1e4502   Widget一覧
//https://qiita.com/coka__01/items/dedb569f6357f1b503fd  Widget一覧
//https://qiita.com/coka__01/items/30716f42e4a909334c9f  ボタンデザイン
// メイン関数、実行時に最初に呼ばれる
// runAppメソッドは引数のwidgetをスクリーンにアタッチする
// runAppメソッドの引数のWidgetが画面いっぱいに表示される
//Shift+Option+F でインデント整理

//record.reference.updateData({'votes': record.votes + 1}) 更新
//
//

void main() => runApp(new MyApp());

// runAppの引数として生成され、最初にインスタンス化されるクラス
class MyApp extends StatelessWidget {
//   // このメソッドでリターンしたWidgetがメイン画面になる
  @override
  Widget build(BuildContext context) {
    // MaterialAppで画面のテーマ等を設定できる
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: new HomeWidget(selectScane: scaneType.gameSelect),
      routes: {
        'GameList': (BuildContext context) =>
            HomeWidget(selectScane: scaneType.gameSelect),
        'DataList': (BuildContext context) =>
            HomeWidget(selectScane: scaneType.dataTypeSelect),
        'DataEditor': (BuildContext context) =>
            HomeWidget(selectScane: scaneType.dataEditor),
      },
    );
  }
}

class HomeWidget extends StatelessWidget {
  final scaneType selectScane;
  const HomeWidget({Key key, this.selectScane}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (selectScane) {
      case scaneType.gameSelect:
        return GameSelectLayout();
        break;
      case scaneType.dataTypeSelect:
        return DataSelectLayout();
        break;
      default:
        return GameSelectLayout();
        break;
    }
  }
}

// MaterialAppにセットされるホーム画面 ////*
class StateHome extends StatefulWidget {
  final scaneType selectScane;
  const StateHome({Key key, this.selectScane}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    switch (selectScane) {
      case scaneType.gameSelect:
        return GameSelect();
        break;
      case scaneType.dataTypeSelect:
        return DataTypeSelect();
        break;
      default:
        return GameSelect();
        break;
    }
  }
}

class GameSelectLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ゲーム本体"),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[Text("メニュー")],
        ),
      ),
      body: StateHome(key: key, selectScane: scaneType.gameSelect),
    );
  }
}

class GameData {
  final String gameTitle;
  final String gameLore;
  final DateTime gameDate;
  final DocumentReference reference;
  
  GameData.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['gameTitle'] != null),
       assert(map['gameLore'] != null),
       assert(map['gameDate'] != null),
       gameTitle = map['gameTitle'],
       gameLore = map['gameLore'],
       gameDate = map['gameDate'];

  GameData.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);
}

class GameSelect extends State<StateHome> {
  TextEditingController gameTitle = new TextEditingController();
  TextEditingController gameLore = new TextEditingController();
  //List<GameData> gameList = new List();
  AsyncSnapshot<QuerySnapshot> syncSnap;
  List<String> documentKey = new List<String>();

  void _addItem(String title, String lore, int index,AsyncSnapshot<QuerySnapshot> snap) {
    setState(() {
      if (index == -1) {
        debugPrint("A");
        Firestore.instance.collection("gameData").add({
          "gameTitle" : title,
          "gameLore" : lore,
          "gameData" : DateTime.now(),
        });
      } else {
        debugPrint("B");
        Firestore.instance.collection("gameData").document(documentKey[index]).setData({
          "gameTitle" : title,
          "gameLore" : lore,
          "gameData" : DateTime.now(),
        });
      }
    });
  }


  
  @override
  Widget build(BuildContext context) {
    Widget main = StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('gameData' /*FireBase:コレクション名*/)
          .snapshots(),
      builder: (context, snapshot) {
        syncSnap = snapshot;
        
        if (!snapshot.hasData) return LinearProgressIndicator();
        //return (context, snapshot.data.documents);
        debugPrint("1");
        return Scaffold(
          backgroundColor: Colors.lime[100],
          body: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              debugPrint("2");
              return Dismissible(
                background: Container(
                  color: Colors.yellow,
                  child: Icon(Icons.change_history),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  child: Icon(Icons.close),
                ),
                key: Key(""),
                onDismissed: (direction) {
                  setState(() {
                    snapshot.data.documents.removeAt(index);
                    //gameList.removeAt(index);
                  });
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("削除")));
                },
                child: InkWell(
                  onLongPress: () {
                        debugPrint("build" + index.toString());

                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            setDialog(false, index));
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text("登録")));
                  },
                  onTap: () {
                    Navigator.of(context).pushNamed('DataList');
                  },
                  child: Card(
                    color: Colors.lime[100],
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(snapshot.data.documents[index].data['gameTitle'].toString()),
                            leading: Icon(Icons.person),
                            subtitle: Text(snapshot.data.documents[index].data['gameLore'].toString()),
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Text(
                                "最終編集日 " + snapshot.data.documents[index].data['gameDate'].toString()))
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: snapshot.data.documents.length,
          ),
          bottomNavigationBar: Stack(
            children: <Widget>[
              BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), title: Text("設定")),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), title: Text("設定")),
                ],
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
                          builder: (BuildContext context) =>
                              setDialog(true, -1));
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      
    );
    setKey(syncSnap);
    return main;
  }

  void setKey(AsyncSnapshot<QuerySnapshot> snapshot) async {
    debugPrint("call");
    while(snapshot == null){
      await new Future.delayed(new Duration(seconds: 1));
      debugPrint("null");
    }
    documentKey.clear();
    snapshot.data.documents.forEach((var d){
      debugPrint("***:::::" + d.documentID);
      documentKey.add(d.documentID);
    });
    
  }

  Widget setDialog(bool t, int index) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      backgroundColor: Colors.yellow[100],
      contentPadding: EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text("ゲームのタイトル", textAlign: TextAlign.left),
            TextField(
              controller: gameTitle,
              decoration: InputDecoration(hintText: "入力してください。"),
            ),
            Text("ゲームの説明", textAlign: TextAlign.left),
            TextField(
              controller: gameLore,
              decoration: InputDecoration(hintText: "入力してください。"),
            ),
            buttonType(t, index),
          ],
        ),
      ),
    );
  }

  Widget buttonType(bool t, int index) {
    if (t) {
      return RaisedButton(
        color: Colors.lightGreen[100],
        onPressed: () {
          _addItem(gameTitle.text, gameLore.text, index,syncSnap);
          
          gameTitle.clear();
          gameLore.clear();
          Navigator.of(context).pop();
        },
        child: Text(
          '新しいデータリストを作る',
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      gameTitle.text = syncSnap.data.documents[index].data['gameTitle'];
      gameLore.text = syncSnap.data.documents[index].data['gameLore'];
      return RaisedButton(
        color: Colors.lightGreen[100],
        onPressed: () {
          _addItem(gameTitle.text, gameLore.text, index,syncSnap);
          gameTitle.clear();
          gameLore.clear();
          Navigator.of(context).pop();
        },
        child: Text(
          '設定を変更する',
          style: TextStyle(fontSize: 20),
        ),
      );
    }
  }
}

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
  static DataType arriveData = null;

  void _addItem(List<modelData> modelType, List<String> dataName, String title,
      String lore, int index) {
    arriveData = DataType(modelType, dataName, title, lore);
    debugPrint("a" + arriveData.toString());
    //setState(() {
    //});
  }

  @override
  void initState() {
    // TODO: implement initState
    debugPrint("init");
    debugPrint("a" + arriveData.toString());

    if (arriveData != null) {
      setState(() {
        debugPrint("arrive:" + arriveData.toString());
        dataList.add(arriveData);
      });
    }
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
    menuDataType = new DataType(
        new List<modelData>(), new List<String>(), "dataTitle", "dataLore");
    super.initState();
  }

  Widget _buildButton(int index) {
    return RaisedButton(
      color: Colors.lightGreen[100],
      onPressed: () {
        dataLore.forEach((TextEditingController f) {
          menuDataType.dataNameList.add(f.text);
        });
        DataTypeSelect()._addItem(
            menuDataType.modelDataList,
            menuDataType.dataNameList,
            dataTypeTitle.text,
            dataTypeLore.text,
            index);
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

class DataEditor extends StatefulWidget {
  final DataType dataType;
  DataEditor({Key key, this.dataType}) : super(key: key);

  @override
  DataEditorState createState() => DataEditorState();
}

class DataEditorState extends State<DataEditor> {
  List<List<TextEditingController>> myController;
  List<List<dynamic>> myData;
  int pageCount = 3;
  int showPage = 0;

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
    //pageCount = myController.length;
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
      floatingActionButton: viewPage(
        page: showPage,
        maxPage: pageCount,
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

class viewPage extends StatefulWidget {
  viewPage({Key key, this.page, this.maxPage}) : super(key: key);
  final int page;
  final int maxPage;
  @override
  viewPageState createState() => viewPageState();
}

class viewPageState extends State<viewPage> {
  int page;
  int maxPage;

  @override
  void initState() {
    page = widget.page;
    maxPage = widget.maxPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text('Page' +
          (widget.page + 1).toString() +
          '/' +
          widget.maxPage.toString()),
      icon: Icon(Icons.book),
      backgroundColor: Colors.pink.shade100,
    );
  }
}

enum scaneType {
  gameSelect,
  dataTypeSelect,
  dataEditor,
}

enum modelData {
  intData,
  floatData,
  boolData,
  stringData,
  imageData,
  textData,
}

class DataType {
  final List<modelData> modelDataList;
  final List<String> dataNameList;
  String dataTitle;
  String dataLore;

  DataType(
      this.modelDataList, this.dataNameList, this.dataTitle, this.dataLore);
}


