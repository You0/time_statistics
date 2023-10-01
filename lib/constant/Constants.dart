import 'dart:math';

List<String> normalText = [
  "三维世界的万事万物，不过梦幻泡影",
  "山河千古事，宇宙一杯空",
  "自其不变者而观之，则物与我皆无尽也，而又何羡乎",
  "踏破乾坤拿日月，银河洗剑天上仙",
  "梦付千秋星垂野"
];

List<String> night = [
  "月色真美",
  "银河下秋水，翠影共徘徊",
  "月明皎洁时，心事谁人知",
  "天阶夜色凉如水",
  "月明星稀，乌鹊南飞",
  "不知东方之既白",
  "江畔何人初见月，江月何年初照人"
];

List<String> images = [''];

List<String> lotties = [
  'assets/lottie/dog_walk.json',
  'assets/lottie/listen.json'
];

String getTimeOfDay() {
  DateTime now = DateTime.now();
  int hour = now.hour;
  if (hour >= 5 && hour < 12) {
    return '早上';
  } else if (hour >= 12 && hour < 19) {
    return '下午';
  } else {
    return '晚上';
  }
}

String getRandomLottie() {
  final random = Random();
  return lotties[random.nextInt(lotties.length)];
}

String getRandomSentence(List<String> sentences) {
  final random = Random();
  return sentences[random.nextInt(sentences.length)];
}

String getText() {
  DateTime now = DateTime.now();
  int hour = now.hour;
  if (hour >= 5 && hour < 12) {
    return getRandomSentence(normalText);
  } else if (hour >= 12 && hour < 19) {
    return getRandomSentence(normalText);
  } else {
    return getRandomSentence(night);
  }
}
