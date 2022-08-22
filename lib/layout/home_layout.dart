import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/shared/components/components.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/shared/cubit/cubit.dart';
import 'package:to_do_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  @override


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (context,state) {
          AppCubit cubit = AppCubit.get(context);
          if (state is AppInsertDatabaseState){
            Navigator.pop(context);
            cubit.changeBottomSheetState(false);
          }
        } ,
        builder: (context,state){
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.appBarTitles[cubit.currentIndex],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);


                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultTextFormField(
                                controller: titleController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                                label: 'Title',
                                prefix: Icons.title),
                            const SizedBox(
                              height: 15.0,
                            ),
                            defaultTextFormField(
                              controller: timeController,
                              keyboardType: TextInputType.datetime,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'time must not be empty';
                                }
                                return null;
                              },
                              label: 'Time',
                              prefix: Icons.watch_later_outlined,
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) => {
                                  timeController.text =
                                      value!.format(context)
                                });
                              },
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            defaultTextFormField(
                              controller: dateController,
                              keyboardType: TextInputType.datetime,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'date must not be empty';
                                }
                                return null;
                              },
                              label: 'Date',
                              prefix: Icons.calendar_month,
                              onTap: () {
                                showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2030-01-01'))
                                    .then((value) => {
                                  dateController.text =
                                      DateFormat.yMMMd().format(value!)
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    elevation: 20.0,
                  )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(false);
                  });
                  cubit.changeBottomSheetState(true);
                }
              },
              child: Icon(cubit.isBottomSheetShown ? Icons.add : Icons.edit),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archive'),
              ],
            ),
            body: cubit.screens[cubit.currentIndex],
          );
        },
      ),
    );
  }

}

