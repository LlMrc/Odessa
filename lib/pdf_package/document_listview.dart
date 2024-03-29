import 'dart:core';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:path/path.dart' as p;
import 'package:pdf_reader/pdf_package/thumbnails.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/pdf_api.dart';
import '../constant.dart';
import '../multimedia/page_manager.dart';
import '../service/remote_google_book.dart';
import '../service/service.dart';
import 'browser.dart';
import 'favorite_pdf.dart';

class DocumentListview extends StatefulWidget {
  const DocumentListview({Key? key}) : super(key: key);

  @override
  _DocumentListviewState createState() => _DocumentListviewState();
}

late PermissionStatus status;

class _DocumentListviewState extends State<DocumentListview> {
  bool isvisible = false;

  var editingController = TextEditingController();

  ///////////////////////// REQUEST PERMISSION////////////////////////////

  Future<void> checkStoragePermission() async {
    status = await Permission.storage.request();
    var status1 = (await Permission.manageExternalStorage.request());

    String getVersion = await getPhoneVersion();
    int version = int.parse(getVersion);
    // get  storage  permission
    if (status == PermissionStatus.granted) {
      await getPath();
      setState(() => getIt<PageManager>().init());
    } else
    //  check Android version
    if (version > 30) {
      if (status1 == PermissionStatus.granted) {
        await getPath();
        setState(() => getIt<PageManager>().init());
      } else if (status1 == PermissionStatus.denied) {
        setState(() => alertDialog(status1));
      }
    } else {
      setState(() => alertDialog(status));
    }
  }

  ///           ***get directory by VERSION***
  bool isDir = true;
  void isDirectory() async {
    String getVersion = await getPhoneVersion();
    int version = int.parse(getVersion);
    if (version >= 30) {
      setState(() => isDir = true);
    } else {
      setState(() => isDir = false);
    }
  }

  void reload() {
    setState(() {
      if (kDebugMode) {
        print("file deleted");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isDirectory();
  }

  Future<List<File>> getPath() async {
    final List<File> exfilePath = [];
    Directory dir = isDir
        ? Directory('/storage/emulated/0/Download')
        : Directory('/storage/emulated/0/');

    List<FileSystemEntity> files = dir.listSync(recursive: true);
    for (FileSystemEntity file in files) {
      FileStat f = file.statSync();
      if (f.type == FileSystemEntityType.file && file.path.contains('.pdf')) {
        File g = File(file.path);
        setState(() {
          exfilePath.add(g);
        });
      }
    }
    return exfilePath;
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: FaIcon(
              FontAwesomeIcons.globe,
              size: 20,
              color: Colors.amber.shade100,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Browser()));
            },
          ),
          actions: [
            IconButton(
                icon: Icon(
                  FontAwesomeIcons.bookOpenReader,
                  color: Colors.amber.shade100,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoritePage()));
                }),
          ],
          centerTitle: true,
          title: Container(
            height: 36,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 27, 97, 202),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38,
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(2, 2)),
                ]),
            child: TextField(
              style: const TextStyle(color: Colors.white60, fontSize: 18),
              onSubmitted: (value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FetchBookFromGoogle(searchtherme: value)));
                editingController.clear();
              },
              controller: editingController,
              textAlignVertical: TextAlignVertical.center,
              maxLines: 1,
              decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.blue.shade300),
                  onPressed: () {
                    editingController.clear();
                  },
                ),
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.only(top: 10, bottom: 7, left: 8),
                hintText: "search...",
              ),
            ),
          )),
      body: FutureBuilder<List<File>>(
          future: getPath(),
          builder: (context, AsyncSnapshot<List<File>> snapshot) {
            var data = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (data == null) {
              return Center(child: widgetRequest());
            } else if (data.isEmpty) {
              return Center(
                child: SizedBox(
                  height: 200,
                  width: 320,
                  child: Card(
                    elevation: 4,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text('No Files found!😥',
                              style: TextStyle(fontSize: 16)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Please allow storage access 🗝 to view local PDFs'
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              selectionColor: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Deny')),
                              ElevatedButton(
                                  onPressed: ()async {
checkStoragePermission();
                                  } ,
                                  child: const Text('Allow')),
                            ],
                          )
                        ]),
                  ),
                ),
              ); //
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 2 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                    itemCount: data.length,
                    itemBuilder: (context, int index) {
                      File fileIndex = snapshot.data![index];

                      return GestureDetector(
                          onTap: () {
                            openPDF(context, fileIndex);
                          },
                          child: Thumbnails(file: fileIndex, reload: reload));
                    }),
              );
            }
          }),
      floatingActionButton: MaterialButton(
        padding: const EdgeInsets.all(10),
        minWidth: 60,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.blue.withOpacity(0.5),
        child: Icon(Icons.folder, size: 35, color: Colors.orange.shade400),
        onPressed: () async {
          final file = await PDFApi.pickFile();
          if (file == null) return;
          if (!mounted) return;
          openPDF(context, file);
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  ClipRRect widgetRequest() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.grey.shade300,
        height: 150,
        width: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
                'The app need your 🗝permission to display local PDF files'
                    .toUpperCase(),
                style: const TextStyle(fontSize: 16)),
            ElevatedButton(
                onPressed: () async {
                  await checkStoragePermission();
                  setState(() {});
                },
                child: const Text(
                  '📂 OPEN',
                  style: TextStyle(fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }

  Future<String> getPhoneVersion() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid) {
      return androidInfo.version.sdkInt.toString();
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion.toString();
    } else {
      throw UnimplementedError();
    }
  }

  void alertDialog(PermissionStatus status) {
    if (status.isDenied) {
      Future.delayed(Duration.zero, () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: const Text(
                      "Allow permission to access your storage to display pdf files"),
                  title: const Text("Alert!"),
                  actions: [
                    ElevatedButton(
                      child: const Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                        child: const Text("OK"),
                        onPressed: () {
                          checkStoragePermission();
                        }),
                  ],
                ));
      });
    }
  }
}
