import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_own_frashcards/main.dart';
import 'package:my_own_frashcards/screens/edit_screen.dart';
import '../db/database.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final BannerAd myBanner = BannerAd(
    // テスト用バナーID
    adUnitId: Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print('バナー広告がロードされました'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('バナー広告の読み込みが次の理由で失敗しました: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('バナー広告が開かれました'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('バナー広告が閉じられました'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    ),
  );
  List<Word> wordList = [];

  @override
  void initState() {
    super.initState();
    _getAllWords();
  }

  @override
  Widget build(BuildContext context) {
    myBanner.load();

    return Scaffold(
        appBar: AppBar(
          title: Text("単語一覧"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              tooltip: "暗記済みの単語を下になるようにソート",
              icon: Icon(Icons.swap_vert),
              onPressed: () => _sortWords(),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addNewWord(),
          child: Icon(Icons.create_sharp, color: Colors.black),
          tooltip: "新しい単語の登録",
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: wordList.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Dismissible(
                direction: DismissDirection.endToStart,
                key: Key(wordList.toString()),
                onDismissed: (DismissDirection direction) {
                  setState(() {
                    wordList.removeAt(index + 1);
                  });
                  if (direction == DismissDirection.endToStart) {
                    _deleteWord(wordList[index]);
                  }
                },
                // スワイプ方向がendToStart（画面左から右）の場合のバックグラウンドの設定
                background: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    child: Text(
                      "削除",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    color: Colors.red,
                  ),
                ),

                // スワイプ方向がstartToEnd（画面右から左）の場合のバックグラウンドの設定


                child: Column(
                  children: [
                    InkWell(
                      child: index % 5 == 0
                          ? index == 0
                          ? const SizedBox()
                          : Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          color: Colors.white,
                          height: 230.0,
                          width: double.infinity,
                          child: AdWidget(ad: myBanner),
                        ),
                      )
                          : const SizedBox(),
                    ),
                    InkWell(child: _wordItem(index)),
                  ],
                ),
              );
            },
          ),
        ));
  }

  _addNewWord() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditScreen(
                  status: EditStatus.ADD,
                )));
  }

  void _getAllWords() async {
    // _wordList = await database.allWords;
    wordList = await database.getAllWordsWithStar();
    setState(() {});
  }

  Widget _wordItem(index) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
      color: Colors.white54,
      child: ListTile(
        title: Text("${wordList[index].strQuestion}"),
        subtitle: Text(
          "${wordList[index].strAnswer}",
          style: TextStyle(fontFamily: "Mont"),
        ),
        trailing: (wordList[index].isMemorized)
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                width: 90,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    "暗記済み",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : null,
        onTap: () => _editWord(wordList[index]),
      ),
    );
  }

  _deleteWord(Word selectedWord) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              title: Text("この単語を削除しますか？"),
              content: Text(
                  '『${selectedWord.strQuestion}』',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
              ),
              alignment: Alignment.centerRight,
              actions: <Widget>[
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      fixedSize: Size(185, 40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    child: Text(
                      "はい",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await database.deleteWord(selectedWord);
                      Fluttertoast.showToast(
                        msg: "単語が削除されました",
                        toastLength: Toast.LENGTH_LONG,
                      );
                      _getAllWords();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "キャンセル",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      Fluttertoast.showToast(
                        msg: "キャンセルされました",
                        toastLength: Toast.LENGTH_LONG,
                      );
                      _getAllWords();
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ));
  }

  _editWord(Word selectedWord) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditScreen(
                  status: EditStatus.EDIT,
                  word: selectedWord,
                )));
  }

  _sortWords() async {
    wordList = await database.allWordsSorted;
    setState(() {});
  }
}
