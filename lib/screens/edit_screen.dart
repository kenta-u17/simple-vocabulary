import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_own_frashcards/db/database.dart';
import 'package:my_own_frashcards/main.dart';
import 'package:my_own_frashcards/screens/word_list_screen.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;
  final Word? word;

  EditScreen({required this.status, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
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

  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = "";

  bool _isQuestionEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.status == EditStatus.ADD) {
      _isQuestionEnabled = true;
      _titleText = "新しい単語の追加";
      questionController.text = "";
      answerController.text = "";
    } else {
      _isQuestionEnabled = false;
      _titleText = "登録した単語の編集";
      questionController.text = widget.word!.strQuestion;
      answerController.text = widget.word!.strAnswer;
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myBanner.load();
    return WillPopScope(
      onWillPop: () => _backToWordListScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () => _onWordRegistered(),
              icon: Icon(Icons.done),
              tooltip: "登録",
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 12.0,
              ),
              Center(
                child: Text(
                  "問題と答えを入力して「登録」ボタンを押して下さい",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              _questionInputPart(),
              SizedBox(
                height: 30.0,
              ),
              _answerInputpart(),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.white,
                    height: 250.0,
                    width: double.infinity,
                    child: AdWidget(ad: myBanner),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Column(
      children: <Widget>[
        Text(
          "もんだい",
          style: TextStyle(fontSize: 24.0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
            maxLength: 30,
          ),
        ),
      ],
    );
  }

  Widget _answerInputpart() {
    return Column(
      children: <Widget>[
        Text(
          "こたえ",
          style: TextStyle(fontSize: 24.0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
            maxLength: 30,
          ),
        ),
      ],
    );
  }

  Future<bool> _backToWordListScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
    return Future.value(false);
  }

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
        msg: "問題と答えの両方を入力しないと登録できません。",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("登録"),
              content: Text("登録してもいいですか？"),
              actions: <Widget>[
                TextButton(
                  child: Text("はい"),
                  onPressed: () async {
                    var word = Word(
                      strQuestion: questionController.text,
                      strAnswer: answerController.text,
                      isMemorized: false,
                    );

                    try {
                      await database.addWord(word);
                      questionController.clear();
                      answerController.clear();
                      // 登録完了メッセージ
                      Fluttertoast.showToast(
                        msg: "登録完了しました",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } on SqliteException catch (e) {
                      Fluttertoast.showToast(
                        msg: "この問題は既に登録されていますので登録出来ません。",
                        toastLength: Toast.LENGTH_LONG,
                      );
                      return;
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                ),
                TextButton(
                  child: Text("いいえ"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  _onWordRegistered() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
        msg: "問題と答えの両方を入力しないと登録できません。",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("「${questionController.text}」の変更"),
              content: Text("変更してもよろしいですか？"),
              actions: <Widget>[
                Center(
                  child: TextButton(
                    child: Text(
                      "はい",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      var word = Word(
                        strQuestion: questionController.text,
                        strAnswer: answerController.text,
                        isMemorized: false,
                      );

                      try {
                        await database.updateWord(word);
                        Navigator.pop(context);
                        _backToWordListScreen();
                        Fluttertoast.showToast(
                          msg: "修正が完了しました。",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                        );
                      } on SqliteException catch (e) {
                        Fluttertoast.showToast(
                          msg: "何らかの問題が発生して登録出来ませんでした。: $e",
                          toastLength: Toast.LENGTH_LONG,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      fixedSize: Size(185, 40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "キャンセル",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ));
  }
}
