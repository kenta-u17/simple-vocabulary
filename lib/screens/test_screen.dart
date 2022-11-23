import 'package:flutter/material.dart';
import 'package:my_own_frashcards/db/database.dart';
import 'package:my_own_frashcards/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludeMemorizedWords;

  TestScreen({required this.isIncludeMemorizedWords});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestions = 0;
  String _textQuestion = "";
  String _textAnswer = "";
  bool _isMemorized = false;

  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFavVisible = false;

  List<Word> _testDataList = [];
  TestStatus _testStatus = TestStatus.BEFORE_START;

  int _index = 0;
  late Word _currentWord;

  @override
  void initState() {
    super.initState();
    _getTextData();
  }

  void _getTextData() async {
    if (widget.isIncludeMemorizedWords) {
      _testDataList = await database.allWords;
    } else {
      _testDataList = await database.allWordsExcludedMemorized;
    }

    _testDataList.shuffle();
    _testStatus = TestStatus.BEFORE_START;
    _index = 0;

    print(_testDataList.toString());

    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFavVisible = true;
      _numberOfQuestions = _testDataList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _finishTestScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("確認テスト"),
          centerTitle: true,
        ),
        floatingActionButton: _isFavVisible
            ? FloatingActionButton(
                onPressed: () => _goNextStatus(),
                child: Icon(Icons.skip_next),
                tooltip: "次に進む",
                backgroundColor: Colors.red,
              )
            : null,
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                _numberOfQuestionsPart(),
                SizedBox(
                  height: 30.0,
                ),
                _questionCardPart(),
                SizedBox(
                  height: 30.0,
                ),
                _answerCardPart(),
                SizedBox(
                  height: 20.0,
                ),
                _isMemorizedCheckPart(),
              ],
            ),
            _endMessage(),
          ],
        ),
      ),
    );
  }

  Widget _numberOfQuestionsPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "残り問題数",
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(
          width: 20.0,
        ),
        Text(
          _numberOfQuestions.toString(),
          style: TextStyle(fontSize: 23.0),
        ),
      ],
    );
  }

  Widget _questionCardPart() {
    if (_isQuestionCardVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          height: 170.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown,
                spreadRadius: 0.0,
                blurRadius: 0.0,
                offset: Offset(-7, -8),
              ),
              BoxShadow(
                color: Colors.white,
                spreadRadius: -3.0,
                blurRadius: 1.0,
                offset: Offset(-5, -5),
              ),
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: Colors.brown,
                width: 5.5,
              ),
            ),
            color: Colors.white,
            child: ListTile(
              title: Text(
                "問題",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                _textQuestion,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[800], fontSize: 28.0),
                maxLines: 3,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _answerCardPart() {
    if (_isAnswerCardVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          height: 170.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown,
                spreadRadius: 0.0,
                blurRadius: 0.0,
                offset: Offset(7, 8),
              ),
              BoxShadow(
                color: Colors.white,
                spreadRadius: -3.0,
                blurRadius: 1.0,
                offset: Offset(5, 5),
              ),
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: Colors.brown,
                width: 5.5,
              ),
            ),
            color: Colors.redAccent,
            child: ListTile(
              dense: true,
              title: Text(
                "答え",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                _textAnswer,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 28.0),
                maxLines: 3,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: CheckboxListTile(
            title: Text(
              "暗記済にする場合はチェックを入れて下さい",
              style: TextStyle(fontSize: 13.0),
            ),
            value: _isMemorized,
            onChanged: (value) {
              setState(() {
                _isMemorized = value!;
              });
            }),
      );
    } else {
      return Container();
    }
  }

  Widget _endMessage() {
    if (_testStatus == TestStatus.FINISHED) {
      return Center(
        child: InkWell(
          onTap: () => _finishTestScreen(),
          child: Container(
            color: Colors.white,
            width: 300.0,
            child: Text(
              "テスト終了",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 55.0,
                shadows: <Shadow>[
                  Shadow(
                    color: Colors.black,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 3.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _goNextStatus() async {
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        _testStatus = TestStatus.SHOW_QUESTION;
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        await _updateMemorizedFlag();
        if (_numberOfQuestions <= 0) {
          setState(() {
            _isFavVisible = false;
            _testStatus = TestStatus.FINISHED;
          });
        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
      case TestStatus.FINISHED:
        break;
    }
  }

  void _showQuestion() {
    _currentWord = _testDataList[_index];
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFavVisible = true;
      _textQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestions -= 1;
    _index += 1;
  }

  void _showAnswer() {
    setState(() {
      _isCheckBoxVisible = true;
      _isAnswerCardVisible = true;
      _isCheckBoxVisible = true;
      _isFavVisible = true;
      _textAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  Future<void> _updateMemorizedFlag() async {
    var updateWord = Word(
        strQuestion: _currentWord.strQuestion,
        strAnswer: _currentWord.strAnswer,
        isMemorized: _isMemorized);
    await database.updateWord(updateWord);
    print(updateWord.toString());
  }

  Future<bool> _finishTestScreen() async {
    return await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text("テスト終了"),
                  content: Text("テストを終了してもいいですか？"),
                  actions: <Widget>[
                    Center(
                      child: TextButton(
                        child: const Text(
                          "はい",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          fixedSize: Size(185, 40),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "いいえ",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                )) ??
        false;
  }
}
