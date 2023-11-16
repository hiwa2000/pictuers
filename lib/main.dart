import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Local Image Viewer'),
        ),
        body: ImageGrid(),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final String imageDirectory = 'images';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>>(
      future: _getImageList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return GridView.builder(
              itemCount: snapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _buildImageItem(snapshot.data!a index]);
              },
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<List<File>> _getImageList() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final List<String> imagePaths = manifestMap.keys
        .where((String key) => key.startsWith('images/'))
        .toList();

    List<File> fileList = [];
    for (String imagePath in imagePaths) {
      final ByteData data = await rootBundle.load(imagePath);
      final List<int> bytes = data.buffer.asUint8List();
      final File file = File('${(await getTemporaryDirectory()).path}/$imagePath')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
      fileList.add(file);
    }

    return fileList;
  }

  Widget _buildImageItem(File file) {
    return Card(
      child: Image.file(file),
    );
  }
}
