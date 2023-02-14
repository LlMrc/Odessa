import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

import '../api/admob_helper.dart';
import '../constant.dart';
import '../data/box.dart';
import '../data/datahelper.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _creatBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title:   const Text('Bookmark'),

      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 14, left: 8, right: 8),
        child: ValueListenableBuilder<Box<Favorite>>(
            valueListenable: FavoriteBoxes.getFav().listenable(),
            builder: (context, box, _) {
              final currentFavorite = box.values.toList().cast<Favorite>();
              if (currentFavorite.isEmpty) {
                return Center(child: LottieBuilder.asset('assets/empty.json'));
              } else {
                return ListView.builder(
                    itemCount: currentFavorite.length,
                    itemBuilder: (BuildContext context, int index) {
                      File pdfFile = File(currentFavorite[index].favoriteFile);
                      Favorite i = currentFavorite[index];
                
                      return Dismissible(
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          didssmisFavorite(i);
                        },
                        key: UniqueKey(),
                        background: backGroundDismissble(),
                        child: Card(
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              openPDF(context, pdfFile);
                            },
                            iconColor: Colors.blue,
                            leading: SizedBox(
                                width: 80,
                                child: PdfDocumentLoader.openFile(pdfFile.path,
                                    pageNumber: 1,
                                    pageBuilder:
                                        (context, textureBuilder, pageSize) =>
                                            textureBuilder(
                                                size: pageSize,
                                                backgroundFill: true))),
                            title: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                basenameWithoutExtension(pdfFile.path),
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_forever),
                              onPressed: () {
                                didssmisFavorite(i);
                              },
                            ),
                          ),
                        ),
                      );
                    });
              }
            }),
      ),
   bottomNavigationBar:  buildcontent(),
    );
  }
 Widget buildcontent() {
    return  _bannerAd != null
        ? Container(
            margin: const EdgeInsets.all(8),
            height: _bannerAd!.size.height.toDouble(),
            width: _bannerAd!.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : Container(
            alignment: Alignment.center,
            height: 58,
           );
  }
  void didssmisFavorite(Favorite i) {
    i.delete();
  }

  Widget backGroundDismissble() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_forever, color: Colors.white));
  }

  void _creatBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: randomId(), //AbmobService.bannerAdsId!,
        listener: AbmobService.bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  String randomId() {
    List<String> idList = [
      "ca-app-pub-3900780607450933/2405730931",
      "/120940746/pub-66798-android-9676"
    ];
    String randomIndex = (idList..shuffle()).first;
    if (kDebugMode) {
      print(randomIndex);
    }
    return randomIndex;
  }
}
