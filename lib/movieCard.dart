import 'package:flutter/material.dart';
import 'package:movieapp/sqlite/Utility.dart';
import 'package:movieapp/sqlite/movieModel.dart';

class MovieCard extends StatelessWidget {
  final movieModel data;
  const MovieCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.memory(Utility.dataFromBase64String(data.picture)),
      ),
      title: Text(data.title),
      subtitle: Text(data.director),
      trailing: CircleAvatar(),
    );
  }
}
