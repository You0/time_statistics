import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shaniu/components/list.dart';
import 'package:shaniu/utils/data_base_helper.dart';

import 'activity/create_task_page.dart';
import 'constant/Constants.dart';
import 'data/list_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ListItem> datas = [];
  void fetchData() async {
    List<ListItem> list = await DataBaseHelper().getListItem();
    datas.clear();
    setState(() {
      datas.addAll(list);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonSection = _buildTopTex();
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          _buildNomalPopMenu(),
          // 在这里添加右上角的图标按钮
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buttonSection,
          Expanded(
            flex: 1,
            child: TimeStatisticsList(items: datas, callback: fetchData),
          ),
          // _buildAddTaskButton()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateForResult(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNomalPopMenu() {
    return PopupMenuButton<String>(
        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                  value: 'value01', child: Text('导出数据')),
              const PopupMenuItem<String>(value: 'value02', child: Text('导入数据'))
            ],
        onSelected: (String value) {});
  }

  Future<void> _navigateForResult(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => const CreateTaskPage()),
    );
    fetchData();
  }

  InkResponse _buildAddTaskButton() {
    return InkResponse(
      onTap: () {
        _navigateForResult(context);
      },
      child: Container(
          color: Colors.amber,
          height: 60,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: Checkbox.width,
              ),
              Text(
                "添加新的一项～",
                style: TextStyle(
                  fontSize: 16.0, // 设置字体大小
                  fontWeight: FontWeight.w400, // 设置字体粗细
                  color: Colors.white, // 设置文本颜色
                ),
              )
            ],
          )),
    );
  }

  Container _buildTopTex() {
    return Container(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "hi ${getTimeOfDay()}好",
              style: const TextStyle(
                  fontSize: 28.0, // 设置字体大小
                  fontWeight: FontWeight.w400, // 设置字体粗细
                  fontFamily: 'lanting'),
            ),
            Text(getText(),
                style: const TextStyle(
                    fontSize: 20.0, // 设置字体大小
                    fontWeight: FontWeight.w400, // 设置字体粗细
                    fontFamily: 'wenYue'))
          ],
        ));
  }
}
