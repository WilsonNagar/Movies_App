import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movieapp/movieCard.dart';
import 'package:movieapp/sqlite/movieModel.dart';
import 'package:path_provider/path_provider.dart';

import 'sqlite/Utility.dart';
import 'sqlite/database.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<MainPage> {
  late DB db;
  //Future<movieModel> movielistview;
  List<movieModel>? somelist;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late StateSetter seetState;
  //XFile? imgString = XFile('assets/no_image.png');
  //Utility.base64String(rootBundle.load('assets/no_image.png')));
  TextEditingController titleControl = TextEditingController();
  TextEditingController dirControl = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = DB();
    somelist = [];
    refreshImages();
    //loadAsset();
  }

  Future<File> getImageFileFromAssets(String path) async {
    Directory tempDir = await getTemporaryDirectory();
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${tempDir.path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  refreshImages() {
    db.getMovies().then((movs) {
      setState(() {
        somelist!.clear();
        somelist!.addAll(movs);
      });
    });
  }

  _imgFromCamera() async {
    File image = File(
        (await _picker.pickImage(source: ImageSource.camera, imageQuality: 50))!
            .path);

    seetState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = File((await _picker.pickImage(
            source: ImageSource.gallery, imageQuality: 50))!
        .path);

    seetState(() {
      _image = image;
      print('seeeeet');
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  bool addToDatabase() {
    if (_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Add Image Please')));
      return false;
    }
    if (titleControl.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Add Title Please')));
      return false;
    }
    if (dirControl.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Add Director Name Please')));
      return false;
    }
    db.insert(movieModel(
        title: titleControl.text,
        director: dirControl.text,
        picture: Utility.base64String(_image!.readAsBytesSync())));
    refreshImages();
    return true;
  }

  bool updateToDatabase(int index) {
    if (titleControl.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Add Title Please')));
      return false;
    }
    if (dirControl.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Add Director Name Please')));
      return false;
    }
    db.updateDB(
        movieModel(
            title: titleControl.text,
            director: dirControl.text,
            picture: (_image == null)
                ? somelist![index].picture
                : Utility.base64String(_image!.readAsBytesSync())),
        somelist![index].id);
    // db.insert(movieModel(
    //     title: titleControl.text,
    //     director: dirControl.text,
    //     picture: Utility.base64String(_image!.readAsBytesSync())));
    refreshImages();
    return true;
  }

  void deleteDatabase(int index) {
    db.delete(somelist![index].id);
    refreshImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Movies List App")),
      // body: _image != null
      //     ? (Text(
      //         'WOW IT HAS VALUE',
      //       ))
      //     : (Text(
      //         'NOTHING',
      //       )),
      backgroundColor: Colors.lightBlueAccent,
      body: ListView.builder(
        itemCount: somelist!.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            onTap: () {
              titleControl.text = somelist![index].title;
              dirControl.text = somelist![index].director;
              _image = null;
              showAddWindow(true, index);
            },
            leading: Container(
              child: Image.memory(
                  Utility.dataFromBase64String(somelist![index].picture)),
            ),
            title: Text(
              somelist![index].title,
              style: TextStyle(color: Colors.blueAccent),
            ),
            subtitle: Text(somelist![index].director)
            //+" : "
            //+somelist![index].id.toString())
            ,
            trailing: ElevatedButton(
              onPressed: () => {deleteDatabase(index)},
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)))),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        onPressed: () {
          //loadAsset();
          _image = null;
          titleControl.text = "";
          dirControl.text = "";
          showAddWindow(false, 0);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showAddWindow(bool checkState, int editindex) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            seetState = setState;
            return AlertDialog(
              title: Center(
                child: Text(
                  ((checkState) ? "Edit Movie" : "Add Movie"),
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              contentPadding: EdgeInsets.all(15),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                    height: 380,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        //------------------------------------------------------------------
                        GestureDetector(
                          onTap: () {
                            _showPicker(context);
                          },
                          child: Container(
                            //radius: 55,
                            //backgroundColor: Color(0xffFDCF09),
                            child: (checkState)
                                ? _image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          _image!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          Utility.dataFromBase64String(
                                              somelist![editindex].picture),
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      )
                                : _image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          _image!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        width: 200,
                                        height: 200,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                          ),
                        ),
                        //---------------------------------------------------------------------------
                        // OutlinedButton(
                        //   child: Image.memory(IMAG),
                        //   //Image.file(File('assets/no_image.png')),
                        //   //Image.asset('assets/no_image.png'),
                        //   //child: Image.file(File(imgString!.path)),
                        //   onPressed: () => {pickImageFromGallery()},
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: titleControl,
                          decoration: InputDecoration(
                            labelText: "Title",
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: dirControl,
                          decoration: InputDecoration(
                            labelText: "Director",
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ],
                    )),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (checkState) {
                      //update database,
                      if (updateToDatabase(editindex)) {
                        _image = null;
                        titleControl.clear();
                        dirControl.clear();
                        Navigator.pop(context);
                      }
                    } else {
                      if (addToDatabase()) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('Added Successfully')),
                        // );
                        _image = null;
                        titleControl.clear();
                        dirControl.clear();
                        Navigator.pop(context);
                        //add success
                      }
                    }
                  },
                  child: Text(
                    ((checkState) ? "UPDATE" : "SAVE"),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            );
          });
        });
  }
}
