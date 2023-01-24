import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/admob_helper.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key,  this.initialUrl = "https://www.google.com/"}) : super(key: key);
  final String initialUrl;
  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  double progress = 0;
  bool initInterstitial = false;

  @override
  void initState() {
    super.initState();
    createInterstitialAds();
  }

  late WebViewController controller;

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('$initInterstitial');
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          iniIntersitial();
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                color: Colors.red,
                backgroundColor: Colors.black12,
              ),
              Expanded(
                child: WebView(
                  initialUrl: widget.initialUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) {
                    this.controller = controller;
                  },
                  onPageStarted: (url) {},
                  onProgress: (progress) => setState(() {
                    this.progress = progress / 100;
                  }),
                  // gestureRecognizers: Set()
                  //   ..add(Factory<VerticalDragGestureRecognizer>(
                  //       () => VerticalDragGestureRecognizer())),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 40,
            color: Colors.black38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clearCache();
                    CookieManager().clearCookies();
                    setState(() => initInterstitial = true);
                  },
                ),
                IconButton(
                    onPressed: () async {
                      setState(
                        () => initInterstitial = true,
                      );
                      if (await controller.canGoBack()) {
                        controller.reload();
                      }
                    },
                    icon: const Icon(Icons.refresh)),
                GestureDetector(
                    onTap: () async {
                      controller.loadUrl("https://www.amazon.com/");
                      setState(() => initInterstitial = true);
                    },
                    child: const SizedBox(
                        width: 60,
                        height: 25,
                        child: Icon(FontAwesomeIcons.amazon))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InterstitialAd? _interstitialAd;

  void createInterstitialAds() {
    InterstitialAd.load(
        adUnitId: AbmobService.interstitialAdsId!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) => _interstitialAd = ad,
            onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null));
  }

  void _showInterstitialAds() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        createInterstitialAds();
        print('show ads');
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        createInterstitialAds();
      });
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  void iniIntersitial() {
    if (initInterstitial == true) {
      _showInterstitialAds();
    }
  }
}
