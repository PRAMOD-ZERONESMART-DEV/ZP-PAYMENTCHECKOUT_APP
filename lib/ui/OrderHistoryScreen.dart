import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../Utils/Globals.dart';
import 'Dashboard.dart';
import 'package:lottie/lottie.dart';

class OrderHistoryScreen extends StatefulWidget {
  bool showBackButton = false;
  String txnId = "";
  String status = '';
  String responseData = '';

  OrderHistoryScreen(
      {Key? key, required this.showBackButton, required this.txnId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderHistoryState();
}

class OrderHistoryState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    String authToken = Globals.AUTH_TOKEN;
    String baseUrl = Globals.BASE_URL;
    if (Globals.isProductionMode!) {
      baseUrl = Globals.PROD_BASE_URL;
    } else {
      baseUrl = Globals.BASE_URL;
    }
    String api = '$baseUrl/v1/transaction/details/${widget.txnId}';

    print("====>>> $api");

    Map<String, String> headers = {
      "Authorization": "Bearer $authToken",
      "Content-Type": "application/json",
    };
    Response response = await get(
      Uri.parse(api),
      headers: headers,
    );

    Map<String, dynamic> jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      // Successful request, parse the JSON data
      // String message = jsonResponse['message'];
      //print("message  $message");
      setState(() {
        widget.status = jsonResponse['data']['status'];
        widget.responseData = jsonResponse.toString();
      });
      //Globals.showToast(context, '$message');

      //return json.decode(response.body);
    } else if (response.statusCode == 400) {
      String message = jsonResponse['message'];
      print("message  $message");
      Globals.showToast(context, '$message');
    } else if (response.statusCode == 401) {
      // Access the status code, message, and error fields
      //print("status_code  $jsonResponse");
      String message = jsonResponse['message'];
      print("message  $message");
      Globals.showToast(context, '$message');
    } else {
      String message = jsonResponse['message'];
      Globals.showToast(context, '$message');
      // Error handling
      //throw Exception('Failed to load data');
    }
  }

  void goBack() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // Replace '/' with the route name of your home page.
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;

    if (widget.status == 'SUCCESS') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
    }
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Order History'),
            leading: widget.showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const Dashboard(),
                      ));
                    },
                  )
                : null,
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo for Success or Fa
                    Icon(
                      statusIcon,
                      size: 50,
                      color: statusColor,
                    ),
                    // If no logo needed, use an empty container

                    const SizedBox(height: 16),
                    // Adding some spacing

                    // Transaction ID
                    const Text(
                      'Status :',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.status,
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 16),
                    // Transaction ID
                    const Text(
                      'Transaction ID:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.txnId,
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 16),
                    // Adding more spacing

                    // Text Data
                    const Text(
                      'Response :',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.responseData,
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 20),

                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () => goBack(),
                      child: const Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
