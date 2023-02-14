

import 'package:audio_service/audio_service.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:pdf_reader/multimedia/page_manager.dart';


import '../api/buttom_package/button_class.dart';
import '../service/service.dart';

class Multimedia extends StatefulWidget {
  const Multimedia({
    Key? key,
  }) : super(key: key);
  @override
  State<Multimedia> createState() => _MultimrdiaState();
}

class _MultimrdiaState extends State<Multimedia> {
  BannerAd? _bannerAd;

  bool isAldloaded = false;
  @override
  void initState() {
    super.initState();
    _creatBannerAd();
  }
var  id;
  final pageManager = getIt<PageManager>();
  final _audioHandler = getIt<AudioHandler>();

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.blue));
    return SafeArea(
      child: Scaffold(
          body: Center(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/mig.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Visibility(
                      visible: isPortrait ? true : false,
                      child: buildcontent()),
                  ValueListenableBuilder<List<MediaItem>>(
                    valueListenable: pageManager.playlistNotifier,
                    builder: (context, playlistTitles, _) {

                      if (playlistTitles.isEmpty) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 200),
                          child: Text("No Audio Files found",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 24,
                                  shadows: [
                                    Shadow(
                                        // blurRadius: 0.5,
                                        color: Colors.red,
                                        offset: Offset(1, -0))
                                  ])),
                        ));
                      }
                      return Flexible(
                        child: ListView.builder(
                          itemCount: playlistTitles.length,
                          itemBuilder: (context, index) {
                        id = playlistTitles[index].artUri;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white10,
                                        border: Border.all(color: Colors.grey)),
                                    child: ListTile(
                                        leading: CircleAvatar(
                                            child: Icon(
                                          Icons.headphones,
                                          color: Colors.grey[700],
                                        )),
                                        title: Text(playlistTitles[index].title,
                                            maxLines: 2,
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 20,
                                                shadows: const [
                                                  Shadow(
                                                      // blurRadius: 0.5,
                                                      color: Colors.black,
                                                      offset: Offset(1, -0))
                                                ]),
                                            overflow: TextOverflow.fade),
                                        onTap: () async {
                                          await _audioHandler
                                              .skipToQueueItem(index);
                                          _audioHandler.play();
                                          showSongs(playlistTitles[index].artUri!.path);
                                        }),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

         
          ),
    );
  }

  void _creatBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: randomId(),
        listener: BannerAdListener(
            onAdLoaded: (ad) => setState(() => isAldloaded = true),
            onAdFailedToLoad: (ad, error) {
              if (kDebugMode) {
                print('$ad $error');
              }
            }),
        request: const AdRequest())
      ..load();
  }

  Widget buildcontent() {
    return isAldloaded
        ? Container(
            margin: const EdgeInsets.all(8),
            height: _bannerAd!.size.height.toDouble(),
            width: _bannerAd!.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : Container(
            alignment: Alignment.center,
            height: 58,
            color: Colors.white12,
            child: const Text('A U D I O  P L A Y E R',
                style: TextStyle(
                    color: Color(0xff0F52BA),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(color: Colors.grey, offset: Offset(-1, 1))
                    ])));
  }

  String randomId() {
    List<String> idList = [
      "ca-app-pub-3900780607450933/2405730931",
      "/120940746/pub-66798-android-9676"
    ];
    String randomIndex =   (idList..shuffle()).first;
    if (kDebugMode) {
      print(randomIndex);
    }
    return randomIndex;
  }

  void showSongs( String id) {
    showBottomSheet(context: context, builder: (context)=>SizedBox(height: 350,child: Column(children: [
      Container(height: 200, decoration: BoxDecoration(image:
      DecorationImage(image: NetworkImage(id)))

      ,),
      Row(children:const [
        RepeatButton(),
        PreviousSongButton(),
        PlayButton(),
        NextSongButton(),
        ShuffleButton(),
      ],)
    ],),));
  }


}
// RepeatButton(),
// PreviousSongButton(),
// PlayButton(),
// NextSongButton(),
// ShuffleButton(),