import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shaniu/utils/data_base_helper.dart';
import 'package:workmanager/workmanager.dart';

import '../components/time_scroll_compoent.dart';

class TimeKeepingPage extends StatefulWidget {
  const TimeKeepingPage({Key? key, required this.type}) : super(key: key);
  final String type;

  @override
  State<TimeKeepingPage> createState() {
    return _TimeKeepingPageState();
  }
}

class _TimeKeepingPageState extends State<TimeKeepingPage>
    with WidgetsBindingObserver {
  int _timeCount = 0;
  final int _startTimestamp = DateTime.now().millisecondsSinceEpoch;
  bool _isStart = false;
  late Timer timer;
  String _totalHour = "0";
  String _weekHour = "0";
  String _dayHour = "0";

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      if (task == "timer") {
        _timeCount++;
        print("Countdown complete");
      }
      return Future.value(true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
    } else if (state == AppLifecycleState.paused) {
      showNotification();
    }
  }

  void showNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.max,
            ongoing: true,
            visibility: NotificationVisibility.public,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    flutterLocalNotificationsPlugin.show(
        0, '${widget.type} 时间积累中', '正在后台默默记录', notificationDetails,
        payload: 'item x');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void startWorkmanager() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await Workmanager().registerPeriodicTask("1", "timer",
        frequency: const Duration(seconds: 1) // 每1s执行一次
        );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isStart = true;
    _startTimer();
    fetchMainDate();
    startWorkmanager();
  }

  void fetchMainDate() async {
    List<Map<String, dynamic>> result =
        await DataBaseHelper().queryTotalTimeByType(widget.type);
    int totalTime = result[0]['total_time'];
    final now = DateTime.now();
    DateTime startTime = now.subtract(Duration(days: now.weekday - 1));
    DateTime endTime = startTime.add(const Duration(days: 6));
    num weekTotalTime = 0;
    await DataBaseHelper()
        .queryByTypeAndTimeSectionGroupByDate(widget.type,
            startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch)
        .then((value) => {
              for (var element in value)
                {weekTotalTime += element['total_time']}
            });
    // 今日:
    num todayTime = 0;
    String queryDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await DataBaseHelper()
        .queryOneDateTotalTimeByType(widget.type, queryDate)
        .then((value) => {
              for (var element in value) {todayTime += element['total_time']}
            });

    setState(() {
      _totalHour = getHours(totalTime);
      _weekHour = getHours(weekTotalTime);
      _dayHour = getHours(todayTime);
    });
  }

  // ms转小时，保留一位小数
  String getHours(num ms) {
    double hour = ms / 1000 / 3600;
    return hour.toStringAsFixed(1);
  }

  void _setPlayOrPause() {
    setState(() {
      _isStart = !_isStart;
    });
    if (_isStart) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _updateTimeCount() {
    setState(() {
      _timeCount++;
    });
  }

  void _startTimer() async {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _updateTimeCount();
    });
  }

  void _stopTimer() {
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.white), // 设置图标颜色为白色
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            title: Text("${widget.type} 积累中",
                style: const TextStyle(color: Colors.white))),
        body: WillPopScope(
          onWillPop: () async {
            bool shouldPop = false;
            // 在这里执行你的逻辑，例如显示确认对话框
            if (_isStart) {
              shouldPop = await showExitConfirmationDialog(context) ?? false;
            }
            return shouldPop;
          },
          child: Stack(
            children: [
              Positioned.fill(
                  child: Image.asset('assets/images/2.jpg', fit: BoxFit.cover)),
              Align(
                  alignment: const Alignment(0, -0.7),
                  child: Lottie.asset(
                    'assets/lottie/dog_walk.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fill,
                  )),
              Align(
                alignment: Alignment.center,
                child: _buildTimeCounter(),
              ),
              Align(
                  alignment: const Alignment(0, 0.5),
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(197, 255, 255, 255), // 设置背景色
                      borderRadius: BorderRadius.circular(12.0), // 设置圆角
                    ),
                    width: 350.0, // 设置Container的宽度
                    height: 120.0, // 设置Container的高度
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 20)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('已积累',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                            Text(
                              '$_dayHour 小时',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            const Text('今日',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                          ],
                        ),
                        const VerticalDivider(
                          color: Colors.black,
                          thickness: 0.5,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('已积累',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                            Text(
                              '$_weekHour 小时',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            const Text('本周',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                          ],
                        ),
                        const VerticalDivider(
                          color: Colors.black,
                          thickness: 0.5,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('已积累',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                            Text(
                              '$_totalHour 小时',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            const Text('总计',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(right: 20)),
                      ],
                    ), // Container的子小部件
                  )),
              Align(
                  alignment: const Alignment(0, 0.8),
                  child: Container(
                    child: _buildControllButton(widget.type), // Container的子小部件
                  )),
            ],
          ),
        ));
  }

  Row _buildControllButton(String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            _setPlayOrPause();
          },
          icon: Icon(
            _isStart ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 65,
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 30)),
        IconButton(
          onPressed: () {
            _stopTimer();
            var endTimestamp = _timeCount * 1000 + _startTimestamp;
            String formattedDate =
                DateFormat('yyyy-MM-dd').format(DateTime.now());
            String second = addZero(_getSecondFromTimeCount(_timeCount));
            String hour = addZero(_getMHourFromTimeCount(_timeCount));
            String minute = addZero(_getMinuteFromTimeCount(_timeCount));
            _showLottieDialog(context, '$hour:$minute:$second');
            DataBaseHelper().insert({
              'type': type,
              'date': formattedDate,
              'begin_time': _startTimestamp,
              'end_time': endTimestamp,
              'desc': ''
            });
          },
          icon: const Icon(
            Icons.stop,
            color: Colors.white,
            size: 65,
          ),
        ),
      ],
    );
  }

  String addZero(int num) {
    if (num < 10) {
      return '0$num';
    }
    return '$num';
  }

  void _showLottieDialog(BuildContext context, String timeCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
              width: 300,
              height: 250,
              child: Stack(
                children: [
                  Positioned.fill(
                      child:
                          Lottie.asset('assets/lottie/congratulations.json')),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('让咱看看本次积累了多少时间'),
                        Text(timeCount,
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        const Text('祝你找日达成目标🎉'),
                      ],
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.0, 0.8),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('关闭页面'),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }

  Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 设置圆角
          ),
          title: const Text('时间正在累积'),
          content: const Text('确定要退出吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 不退出
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 退出
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Row _buildTimeCounter() {
    int second = _getSecondFromTimeCount(_timeCount);
    int hour = _getMHourFromTimeCount(_timeCount);
    int minute = _getMinuteFromTimeCount(_timeCount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TimeScrollAnimation(hour: hour, minute: minute, second: second),
      ],
    );
  }

  int _getMHourFromTimeCount(int timeCount) {
    int secondTimeCount = timeCount;
    int hour = secondTimeCount ~/ 3600;
    return hour;
  }

  int _getMinuteFromTimeCount(int timeCount) {
    int secondTimeCount = timeCount;
    int hour = secondTimeCount ~/ 3600;
    int minute = (secondTimeCount - hour * 3600) ~/ 60;
    return minute;
  }

  int _getSecondFromTimeCount(int timeCount) {
    int secondTimeCount = timeCount;
    int hour = secondTimeCount ~/ 3600;
    int minute = (secondTimeCount - hour * 3600) ~/ 60;
    int second = secondTimeCount - hour * 3600 - minute * 60;
    return second;
  }
}
