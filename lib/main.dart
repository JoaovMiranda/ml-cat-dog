import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() { runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Learning Cat & Dog'),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null ? Text('Nenhuma imagem selecionada.') : Image.file(_image),
                  SizedBox(
                    height: 20,
                  ),
                  _outputs != null ? Text(
                          "${_outputs[0]["label"]}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            background: Paint()..color = Colors.white,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () => chooseImage(ImageSource.camera),
              ),
            IconButton(
              icon: Icon(Icons.image),
              onPressed: () => chooseImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  /// Pega a imagem dependendo da localidade
  Future<void> chooseImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

/// Classifica a imagem
  classifyImage(File image) async{
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }


/// Carrega o modelo de rede
  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

}
