import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shaniu/utils/data_base_helper.dart';

enum TextInputType { title, target }

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  State<CreateTaskPage> createState() {
    return _CreateTaskPageState();
  }
}

class _CreateTaskPageState extends State<CreateTaskPage>
    with TickerProviderStateMixin {
  String _textFieldValue = '';
  String _targetValue = '';
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Container input = _buildEditText('hi，你想统计什么事情的时间呢', '请输入～',
        const Color.fromARGB(255, 222, 226, 252), TextInputType.title);
    Container target = _buildEditText('统计这个时间的目的是?', '输入你的目标吧!',
        const Color.fromARGB(255, 255, 230, 231), TextInputType.target);
    Container button = _buildCreateButton();
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "创建",
                style: TextStyle(
                    fontSize: 28.0, // 设置字体大小
                    fontWeight: FontWeight.w500, // 设置字体粗细
                    fontFamily: 'lanting'),
              ),
              const Text("新的一项",
                  style: TextStyle(
                      fontSize: 28.0, // 设置字体大小
                      fontWeight: FontWeight.w500, // 设置字体粗细
                      fontFamily: 'lanting')),
              input,
              target,
              button
            ],
          ),
        ));
  }

  Container _buildEditText(
      String title, String hitText, Color color, TextInputType type) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 20,
              )),
          Container(
            height: 60,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color, // 背景颜色
              borderRadius: BorderRadius.circular(8), // 圆角半径
            ),
            child: TextField(
              onChanged: (value) {
                // 当文本发生变化时，将文本内容保存到_textFieldValue中
                if (type == TextInputType.title) {
                  _textFieldValue = value;
                } else if (type == TextInputType.target) {
                  _targetValue = value;
                }
              },
              decoration:
                  InputDecoration(hintText: hitText, border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }

  Container _buildCreateButton() {
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
          String message = '';
          if (_targetValue == '') {
            message = 'sorry,你还没有输入目标哦～';
          }
          if (_textFieldValue == '') {
            message = 'sorry, 你还没有输入事项呢～';
          }
          if (message != '') {
            Fluttertoast.showToast(
              msg: message,
              toastLength: Toast
                  .LENGTH_SHORT, // Toast显示持续时间，可以是Toast.LENGTH_SHORT或Toast.LENGTH_LONG
              gravity: ToastGravity
                  .BOTTOM, // Toast显示位置，可以是ToastGravity.TOP、ToastGravity.CENTER或ToastGravity.BOTTOM
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            return;
          }
          DateTime now = DateTime.now(); // 获取当前日期和时间
          String formattedDate = DateFormat('yyyy-MM-dd').format(now);
          DataBaseHelper().insert({
            'type': _textFieldValue,
            'date': formattedDate,
            'begin_time': now.millisecondsSinceEpoch,
            'end_time': now.millisecondsSinceEpoch,
            'desc': _targetValue
          });

          _showLottieDialog(context);
        },
        child: const Text(
          '创建事项',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
    );
  }

  void _showLottieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  repeat: false,
                  'assets/lottie/success.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward();

                    _controller.addStatusListener((status) => {
                          if (status == AnimationStatus.completed)
                            {
                              Navigator.of(context).pop(),
                              Navigator.of(context).pop()
                            }
                        });
                  },
                ), // 替换为你的Lottie动画文件路径
              ],
            ),
          ),
        );
      },
    );
  }
}
