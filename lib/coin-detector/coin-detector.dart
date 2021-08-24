import 'dart:async';

import 'package:coin_detector/coin-detector/coin-service.dart';
import 'package:coin_detector/coin-detector/coin.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timeago/timeago.dart' as timeago;

class CoinDetector extends StatefulWidget {
  CoinDetector({Key? key}) : super(key: key);

  @override
  _CoinDetectorState createState() => _CoinDetectorState();
}

class _CoinDetectorState extends State<CoinDetector> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();
  CoinService _coinService = CoinService();
  StreamSubscription? _coinSubscription;
  List<Coin> _coinValues = [];
  AnimationController? _controller;
  AudioPlayer _player = AudioPlayer();
  final bool isProduction = bool.fromEnvironment('dart.vm.product');

  @override
  void initState() {
    this._player.setAsset('assets/coin.mp3');
    this._controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    this._coinSubscription = this._coinService.stream.listen((coinValue) {
      this._coinValues.insert(0, Coin(coinValue));
      this._animatedListKey.currentState?.insertItem(0, duration: Duration(milliseconds: 500));
      if (coinValue == 'Real') {
        this._playSound();
      }
      setState(() {});
    });
    this._controller!.forward();
    super.initState();
  }

  @override
  void dispose() {
    this._coinService.cancelSubscriptions();
    this._coinSubscription?.cancel();
    this._controller?.dispose();
    this._player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isStreamPaused = this._coinSubscription!.isPaused;
    return Scaffold(
      appBar: AppBar(
        title: Text(this._coinValues.length > 0 ? this._coinValues.first.value : 'Coin detector'),
        centerTitle: true,
        actions: [
          InkWell(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: this._controller!,
                  size: 30,
                ),
              ),
            ),
            onTap: () {
              if (isStreamPaused) {
                // recreate CoinService Timer
                this._coinService.setTimer();
                // resume listening to values from the Timer
                this._coinSubscription!.resume();
                // transition to the pause icon
                this._controller!.forward();
              } else {
                // remove CoinService Timer to avoid getting multiple items on resume, couldn't get to make it work with
                // a BehaviorSubject from rxdart in the time I had.
                this._coinService.cancelTimer();
                // suspend listening to values from the Timer
                this._coinSubscription!.pause();
                // transition back to the play icon
                this._controller!.reverse();
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: AnimatedList(
        key: this._animatedListKey,
        itemBuilder: (BuildContext context, int index, Animation<double> animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), border: Border.all(width: 2.0)),
                child: ExpansionTile(
                  // needed to ensure the expansion is linked to the item in the list and not the index
                  key: ValueKey(this._coinValues[index]),
                  initiallyExpanded: this._coinValues[index].isExpanded,
                  leading: SizedBox.shrink(),
                  trailing: SizedBox.shrink(),
                  textColor: Colors.black,
                  tilePadding: EdgeInsets.only(right: 20),
                  title: Container(
                    height: 150,
                    child: Center(
                        child: Text(
                      this._coinValues[index].value,
                      style: TextStyle(fontSize: 50),
                    )),
                  ),
                  children: [
                    Text(
                      timeago.format(this._coinValues[index].createdAt, locale: 'en'),
                    ),
                  ],
                  onExpansionChanged: (hasExpanded) {
                    this._coinValues[index].isExpanded = hasExpanded;
                    if (hasExpanded) {
                      if (this._coinValues[index].value == 'Real') {
                        this._playSound();
                      }
                      if (!isProduction) {
                        debugPrint('Tapped Coin value is ${this._coinValues[index].value}');
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _playSound() {
    this._player.play().then((value) => this._player.setAsset('assets/coin.mp3'));
  }
}
