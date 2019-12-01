import 'package:cloud_firestore/cloud_firestore.dart' as prefix0;

import 'main.dart';

import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GameSelectLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ゲーム本体"),
        actions: <Widget>[
          Text("user:" + syncUser.displayName),
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill, image: NetworkImage(syncUser.photoUrl))),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Text("メニュー"),
          ],
        ),
      ),
      body: StateHome(key: key, selectScane: scaneType.gameSelect),
    );
  }
}

class GameSelect extends State<StateHome> {
  TextEditingController gameTitle = new TextEditingController();
  TextEditingController gameLore = new TextEditingController();
  //List<GameData> gameList = new List();
  AsyncSnapshot<QuerySnapshot> syncSnap;
  String sendRoomIdentity = "";

  //データを追加
  void _addItem(
      String title, String lore, int index, AsyncSnapshot<QuerySnapshot> snap) {
    if (index == -1) {
      //データ追加
      Firestore.instance
          .collection("Room")
          .add({
            "member": "",
            "gameData": DateTime.now(),
            "gameLore": lore,
            "gameName": title,
            "roomKey": "key",
            "password": "pass",
          })
          .then((doc) => {
                sendRoomIdentity = doc.documentID,
              })
          .whenComplete(() => {
                setState(() {
                  roomIdentity.add(sendRoomIdentity);
                  gameTitleList.add(title);
                  gameLoreList.add(lore);
                  gameDataList.add(new Timestamp(1, 1));
                }),
              });

      //データを追加すると同時に、キーも持たせてあげる。
      Firestore.instance
          .collection("User")
          .document(syncUser.uid)
          .collection("RoomKey")
          .add({
        "roomKey": "key",
      });
      debugPrint("add");
    } else {
      //データ編集
      debugPrint("B");
      Firestore.instance
          .collection("Room")
          .document(roomIdentity[index])
          .setData({
        "member": "",
        "gameData": DateTime.now(),
        "gameLore": lore,
        "gameName": title,
        "roomKey": "key",
        "password": "pass",
      });
      gameTitleList[index] = title;
      gameLoreList[index] = lore;
      gameDataList[index] = new Timestamp(1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //表示したいFireStoreの保存先を指定。
      stream: Firestore.instance.collection('Room').snapshots(),
      //streamが更新されるたびに呼ばれる
      builder: (context, snapshot) {
        syncSnap = snapshot;

        //データが取れていない時の処理
        if (!snapshot.hasData) return LinearProgressIndicator();
        snapshot.data.documents.forEach((var docu) {});
        debugPrint(gameTitleList.length.toString());
        return Scaffold(
          backgroundColor: Colors.lime[100],
          body: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
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
                    Firestore.instance
                        .collection("User")
                        .document(syncUser.uid)
                        .collection("RoomKey")
                        .document(roomIdentity[index]).delete();
                    snapshot.data.documents.removeAt(index);
                    gameTitleList.removeAt(index);
                    gameLoreList.removeAt(index);
                    gameDataList.removeAt(index);
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
                    selectRoom = Firestore.instance
                        .collection('Room')
                        .document(roomIdentity[index]);
                    Navigator.of(context).pushNamed('DataList');
                  },
                  child: Card(
                    color: Colors.lime[100],
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(gameTitleList[index]),
                            leading: Icon(Icons.person),
                            subtitle: Text(gameLoreList[index]),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child:
                              Text("最終編集日 " + gameDataList[index].toString()),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: gameTitleList.length,
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
  }

  Widget setDialog(bool t, int index) {
    //表示するダイアログ
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
    //ボタンの種類
    if (t) {
      return RaisedButton(
        color: Colors.lightGreen[100],
        onPressed: () {
          _addItem(gameTitle.text, gameLore.text, index, syncSnap);
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
      gameTitle.text = syncSnap.data.documents[index].data['gameName'];
      gameLore.text = syncSnap.data.documents[index].data['gameLore'];
      return RaisedButton(
        color: Colors.lightGreen[100],
        onPressed: () {
          _addItem(gameTitle.text, gameLore.text, index, syncSnap);
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
