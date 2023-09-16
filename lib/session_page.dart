import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class SessionPage extends StatefulWidget {
  const SessionPage({
    super.key,
  });


  @override
  State<SessionPage> createState() => _SessionPageState();
}


class _SessionPageState extends State<SessionPage> {
  bool _visible = true;
  Timer? _timer;
  int _sec = 10;
  IconData btnPlayStatus = Icons.play_arrow;
  Stopwatch watch = Stopwatch();
  bool startStop = true;
  String elapsedTime = '';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(_sec * 1000 - watch.elapsedMilliseconds);
        _sec * 1000 - 1000;
      });
    }
  }

  Future<void> zonedScheduleNotification(String title, String body, int time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: time)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _showNotificationWithCustomTimestamp(String title, String body) async {
    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      when: DateTime.now().millisecondsSinceEpoch - 120 * 1000,
      usesChronometer: true,
      chronometerCountDown: true,
    );
    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, "You have studied for: $body", notificationDetails,
        payload: 'item x');
  }

  final Stream<int> _bids = (() {
    late final StreamController<int> controller;
    controller = StreamController<int>(
      onListen: () async {
        await Future<void>.delayed(const Duration(seconds: 5));
        controller.add(5);
        await Future<void>.delayed(const Duration(seconds: 5));
        await controller.close();
      },
    );
    return controller.stream;
  })();

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    const oneMin = const Duration(seconds: 60);
    const oneHr = const Duration(minutes: 60);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_sec == 0) {
        } else {
          setState(() {
            _sec--;
          });
        }
      },
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Focus Mode Enabled"),
      ),
      body: Center(
        child:SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children:[
                  AnimatedOpacity(
                    opacity: _visible ? 0.8 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 125,
                      height: 18,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _visible ? 0.8 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: const SizedBox(
                      width: 200,
                      height: 100,
                      child: Text(
                        "Points:",
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                  children:[
                    AnimatedOpacity(
                      opacity: _visible ? 0.2 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        width: 200,
                        height: 100,
                        color: Colors.blueGrey,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _visible ? 0.8 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: const SizedBox(
                        width: 200,
                        height: 100,
                        child: Text(
                          "This is a quote",
                        ),
                      ),
                    ),
                  ]
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Text(elapsedTime, style: const TextStyle(fontSize: 25.0)),
                    const SizedBox(height: 20.0),
                    FloatingActionButton(
                        heroTag: "btn1",
                        backgroundColor: Colors.red,
                        onPressed: () => startOrStop(elapsedTime),
                        child: (startStop) ? const Icon(Icons.play_arrow) : const Icon(Icons.pause))
                  ],
                ),
              ),
              Text("$_sec"),
              ElevatedButton(
                onPressed: () {
                  startTimer();
                },
                child: const Text("start"),
              ),

              SizedBox(
                child: TextField(
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Input your Time',
                  ),
                  onChanged: (value){
                    setState(() {
                      _sec = int.parse(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),


      floatingActionButton: FloatingActionButton(
        heroTag: "OPACITY BUTTON",
        onPressed: () {
          setState(() {
            _visible = !_visible;
          });
        },
        tooltip: 'Toggle Opacity',
        child: const Icon(Icons.flip),
      ),
    );
  }
  startOrStop(String elapsedTime) {
    if(startStop && _sec * 1000 - watch.elapsedMilliseconds > 0) {
      startWatch();
    } else {
      stopWatch();
      _showNotificationWithCustomTimestamp("title", transformMilliSeconds(_sec * 1000 - watch.elapsedMilliseconds));
    }
  }

  startWatch() {
    setState(() {
      startStop = false;
      watch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
    });
  }

  stopWatch() {
    setState(() {
      startStop = true;
      watch.stop();
      setTime();
    });
  }

  setTime() {
    var timeSoFar = _sec * 1000 - watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }
}


