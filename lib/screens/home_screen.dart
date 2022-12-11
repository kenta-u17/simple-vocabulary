import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_own_frashcards/model_theme.dart';
import 'package:my_own_frashcards/parts/button_with_icon.dart';
import 'package:my_own_frashcards/screens/test_screen.dart';
import 'package:my_own_frashcards/screens/word_list_screen.dart';
import 'package:provider/provider.dart';

void home() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Add Banner
  BannerAd? bannerAd;
  bool isLoaded = false;

  bool isIncludeMemorizedWords = false;

  @override
  void didChangeDependencies() {
    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();
  }

  // final BannerAd myBanner = BannerAd(
  //   // テスト用バナーID
  //   adUnitId: Platform.isAndroid
  //       ? 'ca-app-pub-3940256099942544/6300978111'
  //       : 'ca-app-pub-3940256099942544/2934735716',
  //   size: AdSize.banner,
  //   request: AdRequest(),
  //   listener: BannerAdListener(
  //     onAdLoaded: (Ad ad) => print('バナー広告がロードされました'),
  //     // Called when an ad request failed.
  //     onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //       // Dispose the ad here to free resources.
  //       ad.dispose();
  //       print('バナー広告の読み込みが次の理由で失敗しました: $error');
  //     },
  //     // Called when an ad opens an overlay that covers the screen.
  //     onAdOpened: (Ad ad) => print('バナー広告が開かれました'),
  //     // Called when an ad removes an overlay that covers the screen.
  //     onAdClosed: (Ad ad) => print('バナー広告が閉じられました'),
  //     // Called when an impression occurs on the ad.
  //     onAdImpression: (Ad ad) => print('Ad impression.'),
  //   ),
  // );

  Widget build(BuildContext context) {
    // myBanner.load();
    // final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      // child: adWidget,
      // width: myBanner.size.width.toDouble(),
      // height: myBanner.size.height.toDouble(),
    );
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              _titleText(),
              Expanded(
                child: Image.asset("assets/images/tango.png"),
              ),
              Divider(
                height: 15.0,
              ),
              SizedBox(
                height: 13.0,
              ),
              ButtonWithIcon(
                onPressed: () => _startTestScreen(context),
                icon: Icon(Icons.play_arrow),
                label: "確認テスト",
                color: Colors.red,
              ),
              SizedBox(
                height: 16.0,
              ),
              _radioButtons(),
              SizedBox(
                height: 16.0,
              ),
              ButtonWithIcon(
                onPressed: () => _startWordListScreen(context),
                icon: Icon(Icons.reorder),
                label: "単語一覧",
                color: Colors.grey,
              ),
              SizedBox(
                height: 16.0,
              ),
              _switchTheme(),
              SizedBox(
                height: 40.0,
              ),
              // adContainer,
            ],
          ),
        ),
      );
    });
  }

  Widget _titleText() {
    return Column(
      children: <Widget>[
        Text(
          "シンプル単語帳",
          style: TextStyle(fontSize: 40.0),
        ),
        Text(
          "Simple Vocabulary Book",
          style: TextStyle(fontSize: 19.0, fontFamily: "Mont"),
        ),
      ],
    );
  }

  Widget _radioButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 45.0),
      child: Column(
        children: <Widget>[
          RadioListTile(
            value: false,
            groupValue: isIncludeMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            activeColor: Colors.red,
            title: Text(
              "暗記済みの単語を除外する",
              style: TextStyle(fontSize: 17.0),
            ),
          ),
          RadioListTile(
            value: true,
            groupValue: isIncludeMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            activeColor: Colors.red,
            title: Text(
              "暗記済みの単語含む",
              style: TextStyle(fontSize: 17.0),
            ),
          ),
        ],
      ),
    );
  }

  _onRadioSelected(value) {
    setState(() {
      isIncludeMemorizedWords = value;
    });
  }

  Widget _switchTheme() {
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SwitchListTile(
          title: Text(themeNotifier.isDark ? "Dark" : "Light"),
          value: themeNotifier.isDark,
          secondary:
              Icon(themeNotifier.isDark ? Icons.bedtime : Icons.wb_sunny),
          onChanged: (value) {
            themeNotifier.isDark = !themeNotifier.isDark;
          },
        ),
      );
    });
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }

  _startTestScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(
                  isIncludeMemorizedWords: isIncludeMemorizedWords,
                )));
  }
}
