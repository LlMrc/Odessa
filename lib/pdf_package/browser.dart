import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';

// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


class Browser extends StatefulWidget {
  const Browser({Key? key, this.initialUrl = "https://www.google.com/"})
      : super(key: key);
  final String initialUrl;
  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  int progressIndicator = 0;

  @override
  void initState() {
    super.initState();
    createInterstitialAds();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xffEEF2FF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => progressIndicator = progress);

            debugPrint('WebView is loading (progress : $progressIndicator%)');
          },
          onPageStarted: (String url) {
            controller.runJavaScript(
                "document.getElementsByClassName('elementor elementor-7715 elementor-location-header')[0].style.display='none'");
            controller.runJavaScript(
                "document.getElementsByClassName('elementor elementor-2727 elementor-location-footer')[0].style.display='none'");
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) =>
              debugPrint('Page finished loading: $url'),
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse("https://www.google.com/"));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    this.controller = controller;
  }

  late WebViewController controller;

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
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
                value: progressIndicator.toDouble(),
                color: Colors.red,
                backgroundColor: Colors.black12,
              ),
              Expanded(
                child: WebViewWidget(controller: controller),
              ),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(
                  offset: Offset(4, 4), color: Colors.black54, blurRadius: 10)
            ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      controller.clearCache();
                      cookieManager.clearCookies();
                    }),
                IconButton(
                    onPressed: () async {
                      controller
                          .loadRequest(Uri.parse("https://www.twitter.com/"));

                     _displayAds();
                    },
                    icon: const Icon(FontAwesomeIcons.twitter,
                        color: Colors.blue)),
                IconButton(
                    onPressed: () async {
                      controller
                          .loadRequest(Uri.parse("https://www.facebook.com/"));

                     _displayAds();
                    },
                    icon: const Icon(FontAwesomeIcons.facebook,
                        color: Color(0xff0F52BA))),
                IconButton(
                    onPressed: () async {
                      controller
                          .loadRequest(Uri.parse("https://www.youtube.com/"));

                      _displayAds();
                    },
                    icon: const Icon(
                      FontAwesomeIcons.youtube,
                      color: Colors.red,
                    )),
                IconButton(
                    onPressed: () async {
                      controller
                          .loadRequest(Uri.parse("https://www.amazon.com/"));

                      _displayAds();
                    },
                    icon: const SizedBox(
                        width: 60,
                        height: 25,
                        child: Icon(FontAwesomeIcons.amazon))),
                IconButton(
                    onPressed: () async {
                      if (await controller.canGoBack()) {
                        controller.reload();
                      }
                    },
                    icon: const Icon(Icons.refresh)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final WebViewCookieManager cookieManager = WebViewCookieManager();

  InterstitialAd? _interstitialAd;

  void createInterstitialAds() {
    InterstitialAd.load(
        adUnitId: randomId(),// /120940746/pub-66798-android-9676
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
        if (kDebugMode) {
          print('show ads');
        }
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        createInterstitialAds();
      });
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
  String randomId() {
    List<String> idList = [
      "ca-app-pub-3900780607450933/3686025845",
      "/120940746/pub-66798-android-9676"
    ];
    String randomIndex =
        (idList..shuffle()).first;
    print(randomIndex);
    return randomIndex;
  }

  void _displayAds() {
    Timer(const Duration(seconds: 20), () {
      _showInterstitialAds();
    });
  }
}
