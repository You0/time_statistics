import 'package:shaniu/data/list_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseHelper {
  static Database? _database;
  static final DataBaseHelper _instance = DataBaseHelper._privateConstructor();

  factory DataBaseHelper() {
    return _instance;
  }

  DataBaseHelper._privateConstructor();

  Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS time_statistics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        date TEXT,
        begin_time NUMERIC,
        end_time NUMERIC,
        desc TEXT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    var db = await getDatabase();
    return await db.insert('time_statistics', data);
  }

  // query by type
  Future<List<Map<String, dynamic>>> queryByType(String type) async {
    var db = await getDatabase();
    return await db
        .query('time_statistics', where: 'type = ?', whereArgs: [type]);
  }

  // query by type and time section group by date get all items endtime - begintime sum
  Future<List<Map<String, dynamic>>> queryByTypeAndTimeSectionGroupByDate(
      String type, int beginTime, int endTime) async {
    var db = await getDatabase();
    return await db.rawQuery(
        'SELECT date, SUM(time) as total_time FROM (SELECT date, (end_time - begin_time) as time FROM time_statistics WHERE type = ? AND begin_time >= ? AND begin_time <= ?) GROUP BY date',
        [type, beginTime, endTime]);
  }

  // query the first data order by begin_time
  Future<List<Map<String, dynamic>>> queryFirstData(String type) async {
    var db = await getDatabase();
    return await db.query('time_statistics',
        where: 'type=?',
        whereArgs: [type],
        orderBy: 'begin_time ASC',
        limit: 1);
  }

  Future<List<Map<String, dynamic>>> queryOneDateTotalTimeByType(
      String type, String date) async {
    var db = await getDatabase();
    return await db.rawQuery(
        'SELECT type, SUM(time) as total_time FROM (SELECT type, (end_time - begin_time) as time FROM time_statistics WHERE type = ? AND date = ?) GROUP BY type',
        [type, date]);
  }

  Future<List<Map<String, dynamic>>> queryTotalTimeByType(String type) async {
    var db = await getDatabase();
    return await db.rawQuery(
        'SELECT type, SUM(time) as total_time FROM (SELECT type, (end_time - begin_time) as time FROM time_statistics WHERE type = ?) GROUP BY type',
        [type]);
  }

  Future<List<Map<String, dynamic>>> queryMonthTimeByType(
      String type, String year) async {
    var db = await getDatabase();
    return await db.rawQuery('''
    SELECT month, SUM(time) as total_time FROM
    (SELECT strftime('%m', date) AS month, end_time - begin_time as time
    FROM time_statistics
    WHERE type = ? AND strftime('%Y', date) = ?) GROUP BY month
  ''', [type, year]);

    // await db.rawQuery('''SELECT month, SUM(time) as total_time
    //     FROM (SELECT strftime('%m', date) AS month, (end_time - begin_time) as time
    //     FROM time_statistics WHERE type = ? and strftime('%Y', date) AS year = ?) GROUP BY month''',
    //     [type, year]);
  }

  Future<List<Map<String, dynamic>>> queryYearTimeByType(
      String type, String beginYear, String endYear) async {
    var db = await getDatabase();
    return await db.rawQuery('''
    SELECT year, SUM(time) as total_time FROM
    (SELECT strftime('%Y', date) AS year, end_time - begin_time as time
    FROM time_statistics
    WHERE type = ? AND strftime('%Y', date) >= ? AND strftime('%Y', date) <= ?) GROUP BY year
  ''', [type, beginYear, endYear]);
  }

  // query by type and time  section
  Future<List<Map<String, dynamic>>> queryByTypeAndTimeSection(
      String type, int beginTime, int endTime) async {
    var db = await getDatabase();
    return await db.query('time_statistics',
        where: 'type = ? and begin_time >= ? and begin_time <= ?',
        whereArgs: [type, beginTime, endTime]);
  }

  Future<List<Map<String, dynamic>>> query() async {
    var db = await getDatabase();
    return await db.query('time_statistics');
  }

  Future<int> delete(String type) async {
    var db = await getDatabase();
    return await db
        .delete('time_statistics', where: 'type = ?', whereArgs: [type]);
  }

  Future<int> update(Map<String, dynamic> data, int id) async {
    var db = await getDatabase();
    return await db
        .update('time_statistics', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ListItem>> getListItem() async {
    List<ListItem> datas = [];
    Map<String, ListItem> memorizedMap = {};

    await query().then((value) {
      for (var element in value) {
        String type = element['type'];
        int endTime = element['end_time'];
        int beginTime = element['begin_time'];
        int timeSpend = endTime - beginTime;
        if (memorizedMap.containsKey(type)) {
          ListItem item = memorizedMap[type]!;
          item.time = item.time + timeSpend;
          memorizedMap[type] = item;
        } else {
          memorizedMap[type] = ListItem(
              element['type'], element['desc'], timeSpend, element['id']);
        }
      }
    });
    memorizedMap.forEach((key, value) {
      datas.add(value);
    });
    return datas;
  }
}
