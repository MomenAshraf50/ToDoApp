import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/modules/archived/archived_screen.dart';
import 'package:to_do_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:to_do_app/modules/tasks/tasks_screen.dart';
import 'package:to_do_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  late Database database;
  late List<Map> newTasks = [];
  late List<Map> doneTasks = [];
  late List<Map> archivedTasks = [];
  bool isBottomSheetShown = false;



  List<Widget> screens = [
    TasksScreen(),
    DoneTasksScreen(),
    ArchivedScreen(),
  ];
  List<String> appBarTitles = [
    'Tasks',
    'Done',
    'Archived',
  ];

  void changeIndex(int index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void changeBottomSheetState(bool isShow){
    isBottomSheetShown = isShow;
    emit(AppChangeBottomSheetState());
  }

  void createDatabase(){
    openDatabase('todo.dp', version: 1,
        onCreate: (database, version) {
          print('database created');
          database
              .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY,title TEXT , date TEXT,time TEXT, status TEXT)')
              .then((value) {
            print('table created');
          }).catchError((error) {
            print('error when creating database ${error.toString()}');
          });
        }, onOpen: (database) {
          getDataFromDatabase(database);
        }).then((value){
          database = value;
          emit(AppCreateDatabaseState());
    });
  }

  void insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async{
     await database.transaction((txn) {
       txn
          .rawInsert(
          'INSERT INTO tasks (title,date,time,status) VALUES("$title","$date","$time","new")')
          .then((value) {
            emit(AppInsertDatabaseState());
            getDataFromDatabase(database);
        print('$value Record inserted successfully');
      });
       return Future(() => null);
    });
  }

  void updateData(
  {
    required String status,
    required int id
  })async {
    await database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
    [status,id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }
  void deleteData(
      {required int id
      })async {
    await database.rawDelete('DELETE FROM tasks WHERE id = ?',[id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteFromDatabaseState());
    });
  }

  void getDataFromDatabase(Database database)  {
    newTasks=[];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
   database.rawQuery('SELECT * FROM tasks').then((value) {
     value.forEach((element) {
       if(element['status'] == 'new'){
         newTasks.add(element);
       }else if(element['status'] == 'done'){
         doneTasks.add(element);
       }else{
         archivedTasks.add(element);
       }
     });
     emit(AppGetDatabaseState());
   });
  }
}