import 'dart:developer';
import "dart:async";

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'gameList.dart';
import 'dataType.dart';
import 'dataEditor.dart';

//https://qiita.com/matsukatsu/items/e289e30231fffb1e4502   Widget一覧
//https://qiita.com/coka__01/items/dedb569f6357f1b503fd  Widget一覧
//https://qiita.com/coka__01/items/30716f42e4a909334c9f  ボタンデザイン
// メイン関数、実行時に最初に呼ばれる
// runAppメソッドは引数のwidgetをスクリーンにアタッチする
// runAppメソッドの引数のWidgetが画面いっぱいに表示される
//Shift+Option+F でインデント整理
//export PATH="$PATH:/Users/kota/flutter/bin"
//record.reference.updateData({'votes': record.votes + 1}) 更新

DocumentReference selectRoom;
FirebaseUser syncUser;

  //ログイン後に値を引き継ぐ
  List<String> roomIdentity = new List(); 
  List<String> gameTitleList = new List();
  List<String> gameLoreList = new List();
  List<Timestamp> gameDataList = new List();
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
      home: syncUser == null
          ? new GoogleLogin()
          : new HomeWidget(selectScane: scaneType.gameSelect),
      routes: {
        'GameList': (BuildContext context) =>
            HomeWidget(selectScane: scaneType.gameSelect),
        'DataList': (BuildContext context) =>
            HomeWidget(selectScane: scaneType.dataTypeSelect),
        'DataEditor': (BuildContext context) =>
            HomeWidget(selectScane: scaneType.dataEditor),
        'Error': (BuildContext context) =>
            HomeWidget(selectScane: scaneType.error),
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
        case scaneType.error:
        return ErrorLayOut();
        break;
      default:
        return GameSelectLayout();
        break;
    }
  }
}

class ErrorLayOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: Text("Error"),),
    );
  }
}

class GoogleLogin extends StatefulWidget {
  GoogleLogin({Key key, this.title}) : super(key: key);
  final String title;
  @override
  GoogleLoginState createState() => GoogleLoginState();
}

class GoogleLoginState extends State<GoogleLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: RaisedButton(
            child: Text("Google Sign In"),
            onPressed: () {
              SignInWithGoogle(context);
            },
          )),
        ],
      ),
    );
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> SignInWithGoogle(BuildContext context) async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  debugPrint(currentUser.uid);
  assert(user.uid == currentUser.uid);
  syncUser = user;
  
        CollectionReference userData = Firestore.instance.collection("User");
        userData.document(syncUser.uid).setData({//アカウントデータを設定
          "accountData:" : "",
        });
        debugPrint("clear1");
        bool deleteKey;
        userData.document(syncUser.uid).collection("RoomKey").getDocuments()
        .then((documentList) => {
          documentList.documents.forEach((doc) => {//ルームキーをListに登録
            debugPrint(doc.data["roomKey"].toString()),
            deleteKey = true,
            Firestore.instance.collection('Room').getDocuments().then((dl) => {
              dl.documents.forEach((snapDoc) => {
                debugPrint(snapDoc.data["roomKey"]),
              //一致するキーのデータを取得
              if(snapDoc.data["roomKey"] == doc.data["roomKey"]){
                deleteKey = false,
                debugPrint(":" + snapDoc.data["gameName"]),
                roomIdentity.add(snapDoc.documentID),
                gameTitleList.add(snapDoc.data["gameName"]),
                gameLoreList.add(snapDoc.data["gameLore"]),
                gameDataList.add(snapDoc.data["gameData"]),
              },
              if(deleteKey){//一致しないキーがあった場合は消去
                Firestore.instance.collection("User").document(syncUser.uid).collection("RoomKey").document(doc.documentID).delete()
              },
              debugPrint("Complete" + gameTitleList.length.toString()),
            }),
            }),
            
          }),
        })
        .catchError((onError) => Navigator.of(context).pushNamed('Error'))
        .whenComplete(() => Navigator.of(context).pushNamed('GameList'));

  return 'signInWithGoogle succeeded: $user';
}

void SignOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
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

enum scaneType {
  gameSelect,
  dataTypeSelect,
  dataEditor,
  error
}

enum modelData {
  intData,
  floatData,
  boolData,
  stringData,
  imageData,
  textData,
}