import 'dart:async';
import 'dart:math';

class CoinService {
  StreamController<String> _streamController = StreamController();

  Stream<String> get stream => _streamController.stream.asBroadcastStream();
  Timer? timer;

  CoinService() {
    this.setTimer();
  }

  void setTimer() {
    this.timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _streamController.sink.add(Random().nextBool() ? 'Real' : 'Fake');
    });
  }

  void cancelTimer() {
    this.timer?.cancel();
  }

  void cancelSubscriptions() {
    this.cancelTimer();
    this._streamController.close();
  }
}
