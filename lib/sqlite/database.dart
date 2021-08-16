import 'package:movieapp/sqlite/movieModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DB {
  static Database? _db;
  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String TABLE = 'movie';
  static const String DIRECTOR = 'director';
  static const String PIC = 'picture';
  static const String DB_NAME = 'movies.db';

  Future<Database> get db async {
    // if (null != _db) {
    //   return _db;
    // }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = await getDatabasesPath();
    // var db = await openDatabase(
    //     join(path, DB_NAME)); //------------------------------>>>>>>>>>>>>>
    var db = await openDatabase(join(path, DB_NAME),
        version: 1, onCreate: _onCreate);
    //print("database : " + path);
    print("CUSTOM : database created");
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("""
        CREATE TABLE 
        $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $TITLE TEXT NOT NULL,
                $DIRECTOR TEXT NOT NULL,
                $PIC TEXT NOT NULL)""");
  }

  Future<movieModel> insert(movieModel mov) async {
    var dbClient = await db;
    print("CUSTOM : database DELETE");
    // dbClient.execute("""
    //     CREATE TABLE
    //     $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT,
    //             $TITLE TEXT NOT NULL,
    //             $DIRECTOR TEXT NOT NULL,
    //             $PIC TEXT NOT NULL)""");
    //print(mov.toMap());
    //await dbClient.execute("DROP TABLE IF EXISTS movie");
    /////////////////////////////////////////////////////////////////dbClient.delete(TABLE);
    mov.id = await dbClient.insert(TABLE, mov.toMap());
    return mov;
  }

  Future<List<movieModel>> getMovies() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(TABLE);
    List<movieModel> movielist = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        movielist.add(movieModel.fromMap(maps[i]));
      }
    }
    //String test = await dbClient.rawQuery("Desc " + TABLE);
    return movielist;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<void> updateDB(movieModel model, int? id) async {
    var dbClient = await db;

    int count = await dbClient.rawUpdate(
        'UPDATE movie SET title = ?, director = ?, picture = ? WHERE id = ?',
        [model.title, model.director, model.picture, id]);
    print('updated: $count , $id');

    // await dbClient.rawUpdate("""
    // UPDATE movie SET title='${model.title}',director='${model.director}',picture='${model.picture}' WHERE id=${model.id}
    // """);
    // print("updated");
    //await dbClient.update(TABLE, model.toMap(), where: "id=?", whereArgs: [id]);
  }

  Future<void> delete(int? index) async {
    var dbClient = await db;
    dbClient.delete(TABLE, where: "id=?", whereArgs: [index]);
  }
}
