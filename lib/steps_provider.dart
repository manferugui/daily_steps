import 'dart:async';

import 'package:hive/hive.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pedometer/pedometer.dart';
import 'package:rxdart/rxdart.dart';

class StepsProvider {
  static const String savedStepsKey = "31763A5A96FE48F3BB429DAD97805BF4";
  final _stepsStreamController = new BehaviorSubject<int>();
  final _stepsBox = Hive.box<int>('steps');

  int _currentDaySteps = 0;
  //Map<int, int> _savedSteps;
  Pedometer _pedometer;
  StreamSubscription<int> _subscription;

  static final StepsProvider _instance = new StepsProvider._internal();

  factory StepsProvider() {
    return _instance;
  }

  Stream<int> get stepsStream => this._stepsStreamController.stream;

  int get currentDaySteps => this._currentDaySteps;

  StepsProvider._internal();

  void dispose() {
    _subscription.cancel();
    _stepsStreamController?.close();
  }

  Future<void> init() async {
    //this._savedSteps = this._stepsBox.get(savedStepsKey, defaultValue: new Map<int, int>());
    int dayOfYear = _getDayOfYear();

    if (!this._stepsBox.containsKey(dayOfYear)) {
      this._stepsBox.put(dayOfYear, 0);
    }

    this._currentDaySteps = this._stepsBox.get(dayOfYear);

    this._stepsStreamController.sink.add(this._currentDaySteps);
    //.sink.add(this._currentDaySteps);

    // if (this._pedometer != null) return;

    // this._pedometer = Pedometer();

    // _subscription = _pedometer.pedometerStream.listen(
    //   this._getTodaySteps,
    //   onError: this._onError,
    //   onDone: this._onDone,
    //   cancelOnError: true,
    // );
  }

  int _getDayOfYear() => Jiffy(DateTime.now().toUtc()).dayOfYear;

  // void _onDone() => print("Finished pedometer tracking");
  // void _onError(error) => print("Flutter Pedometer Error: $error");

  Future<void> setTodaySteps(int value, int dayOfYear) async {
    //int dayOfYear = _getDayOfYear();
    int totalSteps = this._stepsBox.get(savedStepsKey, defaultValue: 0);
    int daySteps = this._stepsBox.get(dayOfYear, defaultValue: 0);

    if (value < daySteps) {
      // Upon device reboot, pedometer resets. When this happens, the saved counter must be reset as well.
      int prev = totalSteps;

      if (value < totalSteps) prev = 0;

      totalSteps = value;

      value += daySteps - prev;

      // persist this value using a package of your choice here
      this._stepsBox.put(savedStepsKey, totalSteps);
    }

    int lastDaySavedKey = 888888;
    int lastDaySaved = this._stepsBox.get(lastDaySavedKey, defaultValue: 0);
    // When the day changes, reset the daily steps count
    // and Update the last day saved as the day changes.
    if (lastDaySaved < dayOfYear) {
      lastDaySaved = dayOfYear;
      totalSteps = value;

      _stepsBox
        ..put(lastDaySavedKey, lastDaySaved)
        ..put(savedStepsKey, totalSteps);
    }

    this._currentDaySteps = value;

    await this._stepsBox.put(dayOfYear, this._currentDaySteps);

    this._stepsStreamController.sink.add(this._currentDaySteps);
  }

  clearAll() {
    this._stepsBox.clear();

    this._currentDaySteps = 0;

    this._stepsStreamController.sink.add(this._currentDaySteps);
  }
}
