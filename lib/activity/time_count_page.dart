import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shaniu/utils/data_base_helper.dart';
import '../utils/database_bean_adapter.dart';

class TimeCountPage extends StatefulWidget {
  const TimeCountPage({Key? key, required this.type, required this.screenWidth})
      : super(key: key);
  final String type;
  final double screenWidth;

  @override
  State<TimeCountPage> createState() {
    return _TimeCountPageState();
  }
}

class _TimeCountPageState extends State<TimeCountPage> with RestorationMixin {
  RestorableInt currentSegment = RestorableInt(0);
  @override
  String? get restorationId => 'timezoom_segmented_control';
  BarChartData? barChartData;
  String _totalHour = "0";
  String _totalMinute = "0";
  String _beginDate = "";
  late RestorableRouteFuture<String> _alertDialogRoute;

  void fetchMainDate() async {
    List<Map<String, dynamic>> result =
        await DataBaseHelper().queryTotalTimeByType(widget.type);

    List<Map<String, dynamic>> firstData =
        await DataBaseHelper().queryFirstData(widget.type);
    int totalTime = result[0]['total_time'] ~/ 1000;
    int hour = totalTime ~/ 3600;
    int minute = (totalTime % 3600) ~/ 60;

    int beginTime = firstData[0]['begin_time'];
    DateTime beginDateTime = DateTime.fromMillisecondsSinceEpoch(beginTime);
    String beginDate =
        "${beginDateTime.year}年${beginDateTime.month}月${beginDateTime.day}日";

    setState(() {
      _totalHour = hour.toString();
      _totalMinute = minute.toString();
      _beginDate = beginDate;
    });
  }

  void fetchChartData(int segment) async {
    BarChartData data = await getBarChartData(
        widget.type,
        SegmentType.values[segment >= 0 ? segment : currentSegment.value],
        widget.screenWidth);
    setState(() {
      barChartData = data;
    });
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(currentSegment, 'current_segment');

    registerForRestoration(
      _alertDialogRoute,
      'alert_demo_dialog_route',
    );
  }

  void onValueChanged(int? newValue) {
    setState(() {
      currentSegment.value = newValue!;
    });
    fetchChartData(-1);
  }

  @override
  void initState() {
    super.initState();
    fetchMainDate();
    fetchChartData(0);

    _alertDialogRoute = RestorableRouteFuture<String>(
      onPresent: (navigator, arguments) {
        return navigator.restorablePush(_alertDialogDemoRoute);
      },
      onComplete: _showInSnackBar,
    );
  }

  void _showInSnackBar(String value) {
    if (value == '取消') {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已删除${widget.type}')),
    );
    Navigator.of(context).pop();
    DataBaseHelper().delete(widget.type);
  }

  static Route<String> _alertDialogDemoRoute(
    BuildContext context,
    Object? arguments,
  ) {
    final theme = Theme.of(context);
    final dialogTextStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.textTheme.bodySmall!.color);

    return DialogRoute<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 设置圆角
          ),
          content: Text(
            '确定要删除这个事项吗？',
            style: dialogTextStyle,
          ),
          actions: const [
            _DialogButton(text: '取消'),
            _DialogButton(text: '确定'),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Container timeZoomSelected = _buildSegmentControl();
    Container detail = _builidDetail();
    Container charts = _buildCards(currentSegment.value);
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const Text("统计"),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [timeZoomSelected, detail, charts],
          ),
        ));
  }

  Container _buildSegmentControl() {
    const segmentedControlMaxWidth = 500.0;
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: SizedBox(
        width: segmentedControlMaxWidth,
        child: CupertinoSlidingSegmentedControl(
          groupValue: currentSegment.value,
          children: const <int, Widget>{
            0: Text('本周'),
            1: Text('本月'),
            2: Text('今年'),
            3: Text('总计'),
          },
          onValueChanged: onValueChanged,
        ),
      ),
    );
  }

  Container _builidDetail() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text("${widget.type} 总共积累了"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _totalHour,
                style: const TextStyle(
                    fontSize: 28.0, // 设置字体大小
                    fontWeight: FontWeight.bold, // 设置字体粗细
                    fontFamily: 'lanting'),
              ),
              Column(
                children: [
                  const Text("小时",
                      style: TextStyle(
                          fontSize: 15.0, // 设置字体大小
                          fontWeight: FontWeight.w400, // 设置字体粗细
                          fontFamily: 'lanting')),
                  Container(
                    width: 0,
                    height: 4,
                    color: Colors.grey,
                  )
                ],
              ),
              Text(_totalMinute,
                  style: const TextStyle(
                      fontSize: 28.0, // 设置字体大小
                      fontWeight: FontWeight.bold, // 设置字体粗细
                      fontFamily: 'lanting')),
              Column(
                children: [
                  const Text("分钟",
                      style: TextStyle(
                          fontSize: 15.0, // 设置字体大小
                          fontWeight: FontWeight.w400, // 设置字体粗细
                          fontFamily: 'lanting')),
                  Container(
                    width: 0,
                    height: 4,
                    color: Colors.grey,
                  )
                ],
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          Text("你在$_beginDate创建了这个项目"),
        ],
      ),
    );
  }

  Container _buildCards(int segment) {
    if (barChartData == null) {
      return Container();
    } else {
      return Container(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("时间分布图"),
            const Text(
              "每一分每一秒，时空都会铭记。",
              style: TextStyle(
                  fontSize: 12.0, // 设置字体大小
                  color: Colors.grey, // 设置文本颜色
                  fontFamily: 'lanting'),
            ),
            const Padding(padding: EdgeInsets.only(top: 40)),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(barChartData!,
                  swapAnimationDuration: const Duration(milliseconds: 300),
                  swapAnimationCurve: Curves.linear),
            ),
            const Padding(padding: EdgeInsets.only(top: 100)),
            _buildDeleteButton()
          ],
        ),
      );
    }
  }

  Container _buildDeleteButton() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              const Color.fromARGB(255, 69, 102, 236)),
          minimumSize: MaterialStateProperty.all(const Size(300, 50)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // 设置圆角为8
            ),
          ),
        ),
        onPressed: () {
          _alertDialogRoute.present();
        },
        child: const Text(
          '删除这个事项',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop(text);
      },
      child: Text(text),
    );
  }
}
