import 'package:flutter/material.dart';
import 'package:flutter/src/material/dialog.dart';

//https://qiita.com/matsukatsu/items/e289e30231fffb1e4502   Widget一覧
//https://qiita.com/coka__01/items/dedb569f6357f1b503fd  Widget一覧
//https://qiita.com/coka__01/items/30716f42e4a909334c9f  ボタンデザイン
// メイン関数、実行時に最初に呼ばれる
// runAppメソッドは引数のwidgetをスクリーンにアタッチする
// runAppメソッドの引数のWidgetが画面いっぱいに表示される
void main() => runApp(new MyApp());

// runAppの引数として生成され、最初にインスタンス化されるクラス
class MyApp extends StatelessWidget {
  // このメソッドでリターンしたWidgetがメイン画面になる
  @override
  Widget build(BuildContext context) {
    // MaterialAppで画面のテーマ等を設定できる
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: new HomeWidget(selectScane: 0),
      routes: {
        'GameList' : (BuildContext context) => HomeWidget(selectScane: 0),
        'DataList' : (BuildContext context) => HomeWidget(selectScane: 1),
      },
    );
  }
}

// MaterialAppにセットされるホーム画面 ////*
class HomeWidget extends StatefulWidget {
  final int selectScane;
  const HomeWidget({Key key, this.selectScane}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    switch(selectScane){
    case 0:
      return GameSelect();
      break;
    case 1:
      return DataTypeSelect();
      break;
    default:
      return GameSelect();
      break;
    }
    
  }
}

class GameSelect extends State<HomeWidget> {
  TextEditingController gameTitle = new TextEditingController();
  TextEditingController gameLore = new TextEditingController();
  List<GameData> gameList = new List();

  void _addItem(String title,String lore){
    setState(() {
      gameList.add(GameData(title,lore,DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.lime[100],
      appBar: AppBar(title: Text("ゲーム本体"),),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Text("メニュー")
          ],
        ),
      ),
      body: ListView.builder(
          itemBuilder: (BuildContext context,int index) {
            return InkWell(
              onTap: (){
                Navigator.of(context).pushNamed('DataList');
              },
              child: Card(
                color: Colors.lime[100],
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(gameList[index].gameTitle),
                        leading: Icon(Icons.person),
                        subtitle: Text(gameList[index].gameLore),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Text("最終編集日 " + gameList[index].gameDate.toString())
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: gameList.length,
        ),
        bottomNavigationBar: Stack(
           children: <Widget>[
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  title: Text("設定")
                ),
                BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text("設定")
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            height: 50,
            child: FractionalTranslation(
              translation: Offset(0, -0.5),
              child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (_) => 
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      backgroundColor: Colors.yellow[100],
                      contentPadding: EdgeInsets.all(20),
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text("ゲームのタイトル",textAlign: TextAlign.left),
                            TextField(
                              controller: gameLore,
                              decoration: InputDecoration(
                                hintText: "入力してください。"
                              ),
                            ),
                            Text("ゲームの説明",textAlign: TextAlign.left),
                            TextField(
                              controller: gameLore,
                              decoration: InputDecoration(
                                hintText: "入力してください。"
                              ),
                            ),
                            const SizedBox(height: 30,width: 120),
                            RaisedButton(
                              color: Colors.lightGreen[100],
                              onPressed: (){
                                _addItem(gameTitle.text,gameLore.text);
                                gameTitle.clear();
                                gameLore.clear();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '新しいデータリストを作る',
                                style: TextStyle(fontSize: 20),
                              ),
                             ),
                            ],
                        ),
                      ),
                    ),
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

class DataTypeSelect extends State<HomeWidget> {
  TextEditingController dataTypeTitle = new TextEditingController();
  TextEditingController dataTypeLore = new TextEditingController();
  List<DataType> dataList = new List();
  
  void _addItem(List<modelData> modelType,List<String> dataName,String title,String lore){
    setState(() {
      dataList.add(DataType(modelType,dataName,title,lore));
    });
  }

    @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.lime[100],
      appBar: AppBar(title: Text("データ一覧"),),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Text("メニュー")
          ],
        ),
      ),
      body: ListView.builder(
          itemBuilder: (BuildContext context,int index) {
            return InkWell(
              onTap: (){
                Navigator.of(context).pushNamed('DataList');
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
            );
          },
          itemCount: dataList.length,
        ),
        bottomNavigationBar: Stack(
           children: <Widget>[
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  title: Text("設定")
                ),
                BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text("設定")
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            height: 50,
            child: FractionalTranslation(
              translation: Offset(0, -0.5),
              child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (_) => 
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      backgroundColor: Colors.yellow[100],
                      contentPadding: EdgeInsets.all(20),
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text("データリストの名前",textAlign: TextAlign.left),
                            TextField(
                              controller: dataTypeTitle,
                              decoration: InputDecoration(
                                hintText: "入力してください。"
                              ),
                            ),
                            Text("データリストの説明",textAlign: TextAlign.left),
                            TextField(
                              controller: dataTypeLore,
                              decoration: InputDecoration(
                                hintText: "入力してください。"
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,                                
                                children: <Widget>[
                                  Text("Int",style: TextStyle(fontSize: 25)),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        height: 25,
                                        width: 25,
                                        child: FractionalTranslation(
                                          translation: Offset(0, 0),
                                          child: FloatingActionButton(
                                            onPressed: (){},
                                            backgroundColor: Colors.lime[300],
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(" Float",style: TextStyle(fontSize: 25)),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        height: 25,
                                        width: 25,
                                        child: FractionalTranslation(
                                          translation: Offset(0, 0),
                                          child: FloatingActionButton(
                                            onPressed: (){},
                                            backgroundColor: Colors.lime[300],
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(" Bool",style: TextStyle(fontSize: 25)),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        height: 25,
                                        width: 25,
                                        child: FractionalTranslation(
                                          translation: Offset(0, 0),
                                          child: FloatingActionButton(
                                            onPressed: (){},
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
                                  Text(" String",style: TextStyle(fontSize: 25)),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        height: 25,
                                        width: 25,
                                        child: FractionalTranslation(
                                          translation: Offset(0, 0),
                                          child: FloatingActionButton(
                                            onPressed: (){},
                                            backgroundColor: Colors.lime[300],
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(" Image",style: TextStyle(fontSize: 25)),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        height: 25,
                                        width: 25,
                                        child: FractionalTranslation(
                                          translation: Offset(0, 0),
                                          child: FloatingActionButton(
                                            onPressed: (){},
                                            backgroundColor: Colors.lime[300],
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(" Text",style: TextStyle(fontSize: 25)),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        height: 25,
                                        width: 25,
                                        child: FractionalTranslation(
                                          translation: Offset(0, 0),
                                          child: FloatingActionButton(
                                            onPressed: (){},
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
                                child: new ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context,int index){
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.lightGreen[200],
                                        child: Text("Int"),
                                      ),
                                      title: TextField(
                                        controller: dataTypeLore,
                                        decoration: InputDecoration(
                                          hintText: "入力してください。"
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            //),
                            

                            const SizedBox(height: 30,width: 120),
                            RaisedButton(
                              color: Colors.lightGreen[100],
                              onPressed: (){
                                _addItem(null,null,dataTypeTitle.text,dataTypeLore.text);
                                dataTypeTitle.clear();
                                dataTypeLore.clear();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '新しいゲームを作る',
                                style: TextStyle(fontSize: 20),
                              ),
                             ),
                            ],
                        ),
                      ),
                    ),
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

enum modelData {
    intData,
    floatData,
    boolData,
    stringData,
    imageData,
    textData,
}

class DataType{
  final List<modelData> modelDataList;
  final List<String> dataNameList;
  final String dataTitle;
  final String dataLore;

  DataType(this.modelDataList, this.dataNameList, this.dataTitle, this.dataLore);

}

class GameData{
  final String gameTitle;
  final String gameLore;
  final DateTime gameDate;
  GameData(this.gameTitle, this.gameLore, this.gameDate);
}