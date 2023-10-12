import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Utils/Globals.dart';
import 'OrderHistoryScreen.dart';

class WebviewScreen extends StatefulWidget {
  final String url;

  WebviewScreen({required this.url});

  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  WebViewController? _webViewController;

  void extractTxnIdFromUrl(String _url) {
    Uri uri = Uri.parse(_url);
    String? txnId = uri.queryParameters['txnId'];
    if (txnId != null) {
      // print('txnId: $txnId');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              OrderHistoryScreen(showBackButton: true, txnId: txnId),
        ),
      );
    } else {
      //print('txnId not found in the URL.');
    }
  }

  Future<bool> canGoBack() {
    return _webViewController!.canGoBack();
  }

  _launchURL(String url) async {
    Uri _uri = Uri.parse(url);
    if (await canLaunchUrl(_uri)) {
      await launchUrl(_uri, mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zerone-Pay'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await canGoBack()) {
                _webViewController!.goBack();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith(Globals.CALL_BACK_URL)) {
              return NavigationDecision.navigate;
            } else {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
          },
        ),
      ),
    );
  }
}
