import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shaniu/utils/data_base_helper.dart';

enum SegmentType { week, month, year, total }

BarTouchData barTouchData = BarTouchData(
  enabled: true,
  touchTooltipData: BarTouchTooltipData(
    tooltipBgColor: Colors.transparent,
    tooltipPadding: EdgeInsets.zero,
    tooltipMargin: 8,
    getTooltipItem: (
      BarChartGroupData group,
      int groupIndex,
      BarChartRodData rod,
      int rodIndex,
    ) {
      return BarTooltipItem(
        rod.toY.round().toString(),
        const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      );
    },
  ),
);

FlTitlesData titlesData = const FlTitlesData(
  show: true,
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 30,
      getTitlesWidget: getTitles,
    ),
  ),
  leftTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
  topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
  rightTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
);

LinearGradient barsGradient = const LinearGradient(
  colors: [
    Colors.deepPurple,
    Colors.blue,
  ],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);

FlBorderData borderData = FlBorderData(
  show: false,
);

SegmentType currentType = SegmentType.week;

String addZero(int num) {
  if (num < 10) {
    return '0$num';
  }
  return '$num';
}

Future<BarChartData> getBarChartData(
    String title, SegmentType type, double screenWidth) async {
  List<BarChartGroupData> barGroups = [];
  Map<String, BarChartGroupData?> barChartGroupMap = {};
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  double width = screenWidth / 10;
  currentType = type;
  if (type == SegmentType.week) {
    final now = DateTime.now();
    startTime = now.subtract(Duration(days: now.weekday - 1));
    endTime = startTime.add(const Duration(days: 6));
    width = screenWidth / 10;
  } else if (type == SegmentType.month) {
    // 获取本月第一天和最后一天
    final now = DateTime.now();
    startTime = DateTime(now.year, now.month, 1);
    endTime = DateTime(now.year, now.month + 1, 1);
    width = screenWidth / 35;
  } else if (type == SegmentType.year) {
    width = screenWidth / 15;
  } else if (type == SegmentType.total) {
    width = screenWidth / 7;
  }

  if (type == SegmentType.month || type == SegmentType.week) {
    int index = 0;
    for (var i = startTime;
        i.isBefore(endTime) || i == endTime;
        i = i.add(const Duration(days: 1))) {
      barChartGroupMap[DateFormat('yyyy-MM-dd').format(i)] = BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
                toY: 0,
                gradient: barsGradient,
                width: width,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6), topRight: Radius.circular(6)))
          ],
          showingTooltipIndicators: [0],
          barsSpace: 10);
    }
    await DataBaseHelper()
        .queryByTypeAndTimeSectionGroupByDate(title,
            startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch)
        .then((value) => {
              for (var element in value)
                {
                  if (barChartGroupMap.containsKey(element['date']))
                    {
                      barChartGroupMap[element['date']] = BarChartGroupData(
                        x: barChartGroupMap[element['date']]!.x,
                        barRods: [
                          BarChartRodData(
                              toY: getTime(element['total_time'], type),
                              gradient: barsGradient,
                              width: width,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6)))
                        ],
                        showingTooltipIndicators: [0],
                      )
                    }
                }
            });
  } else if (type == SegmentType.year) {
    // 获取今年的年份
    int year = DateTime.now().year;
    for (int i = 1; i < 13; i++) {
      barChartGroupMap[addZero(i)] = BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: 0,
              gradient: barsGradient,
              width: width,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators: [0],
      );
    }
    await DataBaseHelper()
        .queryMonthTimeByType(title, year.toString())
        .then((value) => {
              for (var element in value)
                {
                  if (barChartGroupMap.containsKey(element['month'].toString()))
                    {
                      barChartGroupMap[element['month'].toString()] =
                          BarChartGroupData(
                        x: barChartGroupMap[element['month'].toString()]!.x,
                        barRods: [
                          BarChartRodData(
                              toY: getTime(element['total_time'], type),
                              gradient: barsGradient,
                              width: width,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6)))
                        ],
                        showingTooltipIndicators: [0],
                      )
                    }
                }
            });
  } else if (type == SegmentType.total) {
    int year = DateTime.now().year;
    int beginYear = year - 4;
    for (int i = beginYear; i <= year; i++) {
      barChartGroupMap[i.toString()] = BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: 0,
              gradient: barsGradient,
              width: width,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators: [0],
      );
    }

    await DataBaseHelper()
        .queryYearTimeByType(title, beginYear.toString(), year.toString())
        .then((value) => {
              for (var element in value)
                {
                  if (barChartGroupMap.containsKey(element['year'].toString()))
                    {
                      barChartGroupMap[element['year'].toString()] =
                          BarChartGroupData(
                        x: barChartGroupMap[element['year'].toString()]!.x,
                        barRods: [
                          BarChartRodData(
                              toY: getTime(element['total_time'], type),
                              gradient: barsGradient,
                              width: width,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6)))
                        ],
                        showingTooltipIndicators: [0],
                      )
                    }
                }
            });
  }

  // barChartGroupMap to barGroups
  switch (type) {
    case SegmentType.week:
      barChartGroupMap.forEach((key, value) {
        barGroups.add(value!);
      });
      break;
    case SegmentType.month:
      int counter = 0;
      int index = 0;
      List<BarChartRodData> barRods = [];
      barChartGroupMap.forEach((key, value) {
        BarChartRodData data = barChartGroupMap[key]!.barRods[0];
        if (counter < 4) {
          barRods.add(data);
        } else {
          counter = -1;
          barRods.add(data);
          barGroups.add(BarChartGroupData(
            x: index == 0 ? 1 : index,
            barRods: List.from(barRods),
            showingTooltipIndicators: [0],
          ));
          index += 5;
          barRods = [];
        }
        counter++;
      });
      break;
    case SegmentType.year:
      barChartGroupMap.forEach((key, value) {
        barGroups.add(value!);
      });
      break;
    case SegmentType.total:
      barChartGroupMap.forEach((key, value) {
        barGroups.add(value!);
      });
      break;
  }
  return BarChartData(
    barTouchData: barTouchData,
    titlesData: titlesData,
    borderData: borderData,
    barGroups: barGroups,
    gridData: const FlGridData(show: false),
    alignment: BarChartAlignment.spaceAround,
    maxY: double.parse(getMaxY(barGroups).toStringAsFixed(0)),
  );
}

int getMaxY(barGroups) {
  int maxY = 0;
  for (var element in barGroups) {
    for (var item in element.barRods) {
      if (item.toY > maxY) {
        maxY = item.toY.toInt();
      }
    }
  }
  return maxY;
}

double getTime(int time, SegmentType type) {
  // 将毫秒转换成小时，如果小于1小时，就转换成分钟
  Duration duration = Duration(milliseconds: time);
  double hour = duration.inHours.toDouble();
  double min = duration.inMinutes.toDouble();
  if (type == SegmentType.week || type == SegmentType.month) {
    return min;
  } else {
    return hour;
  }
}

Widget getTitles(double value, TitleMeta meta) {
  final style = const TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text = '';
  if (currentType == SegmentType.week) {
    switch (value.toInt()) {
      case 0:
        text = '周一';
        break;
      case 1:
        text = '周二';
        break;
      case 2:
        text = '周三';
        break;
      case 3:
        text = '周四';
        break;
      case 4:
        text = '周五';
        break;
      case 5:
        text = '周六';
        break;
      case 6:
        text = '周日';
        break;
      default:
        text = '';
        break;
    }
  } else if (currentType == SegmentType.month) {
    text = (value.toInt()).toString();
  } else if (currentType == SegmentType.year) {
    text = (value.toInt()).toString();
  } else if (currentType == SegmentType.total) {
    text = (value.toInt()).toString();
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 4,
    child: Text(text, style: style),
  );
}
