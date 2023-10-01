import 'package:flutter/material.dart';
import 'package:shaniu/activity/time_count_page.dart';
import 'package:shaniu/activity/timekeeping_page.dart';
import 'package:shaniu/data/list_item.dart';

class TimeStatisticsList extends StatelessWidget {
  const TimeStatisticsList(
      {Key? key, required this.items, required this.callback})
      : super(key: key);
  final List<ListItem> items;
  final Function callback;

  Future<void> _navigateForResult(BuildContext context, String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeKeepingPage(type: type)),
    );
    callback();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 获取屏幕宽度
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async => {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimeCountPage(
                        type: items[index].title, screenWidth: screenWidth))),
            callback()
          },
          child: Container(
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(25, 16, 47, 224), // 设置背景色
                borderRadius: BorderRadius.circular(8.0), // 设置圆角
              ),
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.only(left: 15.0)),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Padding(padding: EdgeInsets.only(top: 10.0)),
                        Text(items[index].title,
                            style: const TextStyle(
                                fontSize: 20.0, // 设置字体大小
                                fontWeight: FontWeight.w400, // 设置字体粗细
                                fontFamily: 'lanting')),
                        Text(items[index].subtitle,
                            style: const TextStyle(color: Colors.black54)),
                        const Padding(padding: EdgeInsets.only(top: 10.0)),
                        Text("已经累积了${millisecond2String(items[index].time)}"),
                        const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                      ])),
                  Column(
                    children: [
                      InkResponse(
                        onTap: () {
                          _navigateForResult(context, items[index].title);
                        },
                        child: const Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(999.0))),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.play_arrow,
                                size: 30,
                              ),
                            )),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(right: 10.0)),
                ],
              )),
        );
      },
    );
  }

  String millisecond2String(int millisecond) {
    final seconds = millisecond ~/ 1000;
    final hour = seconds ~/ 3600;
    final minute = seconds % 3600 ~/ 60;
    final second = seconds % 60;
    return '${hour.toString().padLeft(2, '0')}小时${minute.toString().padLeft(2, '0')}分${second.toString().padLeft(2, '0')}秒啦';
  }
}
