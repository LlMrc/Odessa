import 'package:audio_service/audio_service.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdf_reader/multimedia/page_manager.dart';

import '../api/admob_helper.dart';

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

  bool isLoaded = false;
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
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  statusBarColor: Colors.blue
));
    return SafeArea(
      child: Scaffold(
          body: Center(
            child: Container(
              decoration:  const BoxDecoration(
               
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
                  ValueListenableBuilder<List<String>>(
                    valueListenable: pageManager.playlistNotifier,
                    builder: (context, playlistTitles, _) {
                      return Flexible(
                        child: ListView.builder(
                          itemCount: playlistTitles.length,
                          itemBuilder: (context, index) {
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
                                        leading: const CircleAvatar(
                                            child: Icon(
                                          Icons.headphones,
                                          color: Colors.white,
                                        )),
                                        title: Text(playlistTitles[index],
                                            maxLines: 2,

                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18,
                                              shadows: [
                                              Shadow(
                                              // blurRadius: 0.5,
                                                color: Colors.black
                                                ,
                                                offset: Offset(
                                                1, -0
                                              ))
                                            ]),
                                            overflow: TextOverflow.fade),
                                        onTap: () async {
                                          await _audioHandler
                                              .skipToQueueItem(index);
                                          _audioHandler.play();
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
          floatingActionButton: FabCircularMenu(
            fabOpenIcon: const Icon(
              Icons.queue_music_outlined,
              semanticLabel: 'Audio player',
            ),
            fabOpenColor: Colors.orangeAccent,
            fabColor: Colors.blue[300],
            ringColor: Colors.indigo.withOpacity(0.6),
            // ringDiameter: 300,
            fabSize: 45,
            children: const [
              Visibility(visible: false, child: ShuffleButton()),
              RepeatButton(),
              PreviousSongButton(),
              PlayButton(),
              NextSongButton(),
              ShuffleButton(),
            ],
          )),
    );
  }

  void _creatBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AbmobService.bannerAdsId!,
        listener: BannerAdListener(
          onAdLoaded: (ad) => setState(() => isAldloaded = true),
          onAdFailedToLoad: (ad, error) => print('$ad $error'),
        ),
        request: const AdRequest())
      ..load();
  }

  Widget buildcontent() {
    return isAldloaded
        ? Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: 58,
            child: AdWidget(ad: _bannerAd!),
          )
        : Container(
            alignment: Alignment.center,
            height: 58,
            color: Colors.white12,
            child: const Text('A U D I O  P L A Y E R',
                style: TextStyle(color: Color(0xff0F52BA),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                 letterSpacing: 2.0,
                  shadows: [
                  Shadow(
                   
                    color: Colors.grey,
                 offset:Offset(-1, 1) )])));
  }
}
