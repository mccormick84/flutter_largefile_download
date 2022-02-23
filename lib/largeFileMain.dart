import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LargeFileMain extends StatefulWidget {
  const LargeFileMain({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LargeFileMain();
}

class _LargeFileMain extends State<LargeFileMain> {
  // 내려 받을 이미지 주소
  final imgUrl =
      'https://images.pexels.com/photos/240040/pexels-photo-240040.jpeg'
      '?auto=compress';

  bool downloading = false; // 다운 중인지 확인
  var progressString = '';
  String file = '';

  Future<Widget> downloadWidget(String filePath) async {
    File file = File(filePath);
    bool exist = await file.exists();
    new FileImage(file).evict(); // 캐시 초기화하기

    if (exist) {
      return Center(
        child: Column(
          children: <Widget>[Image.file(File(filePath))],
        ),
      );
    } else {
      return const Text('No data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Large File Example'),
      ),
      body: Center(
          child: downloading
              ? SizedBox(
                  height: 120.0,
                  width: 200.0,
                  child: Card(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Downloading File: $progressString',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : FutureBuilder(
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        debugPrint('none');
                        return Text('데이터 없음');
                      case ConnectionState.waiting:
                        debugPrint('waiting');
                        return CircularProgressIndicator();
                      case ConnectionState.active:
                        debugPrint('active');
                        return CircularProgressIndicator();
                      case ConnectionState.done:
                        debugPrint('done');
                        if (snapshot.hasData) {
                          return snapshot.data as Widget;
                        }
                    }
                    debugPrint('end process');
                    return const Text('데이터 없음');
                  },
                  future: downloadWidget(file),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          downloadFile();
        },
        child: const Icon(Icons.file_download),
      ),
    );
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      await dio.download(imgUrl, '${dir.path}/myimage.jpg',
          onReceiveProgress: (rec, total) {
        debugPrint('Rec: $rec, Total: $total');
        file = '${dir.path}/myimage.jpg';
        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + '%';
        });
      });
    } catch (error) {
      print(error);
    }
    setState(() {
      downloading = false;
      progressString = 'Completed';
    });
    debugPrint('Download completed');
  }
}
