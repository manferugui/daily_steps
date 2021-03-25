import 'dart:math';

import 'package:daily_steps/steps_provider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _stepsProvider = new StepsProvider();
  int _steps = 0;
  int _day = 1;

  @override
  void initState() {
    _stepsProvider.init();
    this._steps = _stepsProvider.currentDaySteps;

    super.initState();
  }

  @override
  void dispose() {
    _stepsProvider.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Películas'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              "Día: ${this._day}",
              style: TextStyle(fontSize: 40),
            ),
            this._cardsSwiper(),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              int newValue = Random.secure().nextInt(100);
              print(newValue);
              this._steps += newValue;

              await _stepsProvider.setTodaySteps(this._steps, this._day);
              this.setState(() {});
            },
          ),
          Container(
            width: 10,
            height: 10,
          ),
          FloatingActionButton(
            child: Icon(Icons.calendar_today),
            backgroundColor: Colors.purple,
            onPressed: () async {
              this._steps = 10;
              this._day++;

              await _stepsProvider.setTodaySteps(this._steps, this._day);

              this.setState(() {});
            },
          ),
          Container(
            width: 10,
            height: 10,
          ),
          FloatingActionButton(
            child: Icon(Icons.undo),
            backgroundColor: Colors.green,
            onPressed: () async {
              this._steps = 200;

              print(this._steps);

              await _stepsProvider.setTodaySteps(this._steps, this._day);
              this.setState(() {});
            },
          ),
          Container(
            width: 10,
            height: 10,
          ),
          FloatingActionButton(
            child: Icon(Icons.theaters),
            backgroundColor: Colors.yellow,
            onPressed: () async {
              this._steps = 0;
              this._day = 1;

              await _stepsProvider.clearAll();
              this.setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _cardsSwiper() {
    return Center(
      child: StreamBuilder(
        stream: _stepsProvider.stepsStream,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData)
            return Container(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            );

          return Text(
            snapshot.data.toString(),
            style: TextStyle(
              fontSize: 40,
            ),
          );
        },
      ),
    );
  }
}
