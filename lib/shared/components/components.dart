import 'package:flutter/material.dart';
import 'package:to_do_app/shared/cubit/cubit.dart';

Widget defaultTextFormField({
  required TextEditingController controller,
  required TextInputType keyboardType,
  bool isPassword = false,
  Function(String)? onSubmitted,
  Function(String)? onChanged,
  required String? Function(String?)? validator,
  required String label,
  required IconData prefix,
  IconData? suffix,
  VoidCallback? suffixPressed,
  VoidCallback? onTap,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: IconButton(onPressed: suffixPressed, icon: Icon(suffix)),
        border: const OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(id: model['id']);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.0,
              child: Text('${model['time']}'),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .updateData(status: 'done', id: model['id']);
                },
                icon: const Icon(
                  Icons.check_circle_outlined,
                  color: Colors.green,
                )),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .updateData(status: 'archived', id: model['id']);
                },
                icon: const Icon(
                  Icons.archive,
                  color: Colors.black38,
                )),
          ],
        ),
      ),
    );

Widget tasksBuilder(List<Map> tasks) => tasks.isNotEmpty
    ? ListView.separated(
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[700],
              ),
            ),
        itemCount: tasks.length)
    : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.menu,
              size: 100.0,
              color: Colors.black38,
            ),
            Text(
              'No tasks Added, Please add some.',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.black38),
            ),
          ],
        ),
      );
