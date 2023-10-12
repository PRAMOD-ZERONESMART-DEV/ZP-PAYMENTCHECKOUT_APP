import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/Globals.dart';
import 'WebViewScreen.dart';
import 'custom/DecimalTextInputFormatter.dart';

class OrderFormScreen extends StatefulWidget {
  final bool showBackButton;

  OrderFormScreen({Key? key, required this.showBackButton}) : super(key: key);

  @override
  OrderFormState createState() => OrderFormState();
}

class OrderFormState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _authTokenController = TextEditingController();
  final TextEditingController _returnUrlController = TextEditingController();
  final TextEditingController _callBackUrlController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _tradeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authTokenController.text = Globals.AUTH_TOKEN;
    _returnUrlController.text = 'https://cardse.co';
    _callBackUrlController.text = 'https://cardse.co';
    _amountController.text = '6.0';
    _tradeController.text = Globals.generateUniqueTradeNumber();
    _mobileController.text = '9999999999';
    _emailController.text = 'testcustomer@gmail.com';
  }

  void _submitButton(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      String authToken = _authTokenController.text;
      String returnUrl = _returnUrlController.text;
      String callBackUrl = _callBackUrlController.text;
      String amount = _amountController.text;
      String tradeNumber = _tradeController.text;
      String mobile = _mobileController.text;
      String email = _emailController.text;

      // Convert the amount to always display two decimal places
      double parsedAmount = double.parse(amount);
      String formattedAmount = parsedAmount.toStringAsFixed(2);

      Globals.AUTH_TOKEN = authToken;

      // Raw data to be sent in the request body
      Map<String, dynamic> rawBody = {
        "returnUrl": returnUrl,
        "callBackUrl": callBackUrl,
        "currency": "INR",
        "amount": formattedAmount,
        "tradeNumber": tradeNumber,
        "mobileNo": mobile,
        "email": email
      };

      // Encode the raw data to JSON
      String rawBodyJson = jsonEncode(rawBody);

      Globals.CALL_BACK_URL = callBackUrl;
      makeOrderRequest(rawBodyJson);

      // if (kDebugMode) {
      //   print('prev amount ==>>> $parsedAmount');
      // }
      // if (kDebugMode) {
      //   print('after amount ==>>> $formattedAmount');
      // }
    }
  }

  void makeOrderRequest(String rawData) async {
    String baseUrl = Globals.BASE_URL;
    if (Globals.isProductionMode!) {
      baseUrl = Globals.PROD_BASE_URL;
    } else {
      baseUrl = Globals.BASE_URL;
    }
    String authToken = Globals.AUTH_TOKEN;
    // API endpoint URL
    String endpointUrl = '$baseUrl/v1/merchant/order';
    // Set up the headers with the authorization token
    Map<String, String> headers = {
      "Authorization": "Bearer $authToken",
      "Content-Type": "application/json",
    };

    try {
      // Make the POST request
      Response response = await post(
        Uri.parse(endpointUrl),
        headers: headers,
        body: rawData,
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Request was successful
        print("Request was successful!");
        print("Response:");
        print(response.body);
        handleResponse(response.body);
      } else if (response.statusCode == 409) {
        // Conflict: Merchant Trade Number already exists
        handleResponse(response.body);
      } else {
        // Request failed
        print("Request failed with status code: ${response.statusCode}");
        print("Response:");
        print(response.body);
        handleResponse(response.body);
      }
    } catch (e) {
      // An error occurred
      print("An error occurred: $e");
    }
  }

  Future<void> handleResponse(String responseBody) async {
    // Parse the JSON response
    Map<String, dynamic> jsonResponse = json.decode(responseBody);

    // Access the status code, message, and error fields
    int statusCode = jsonResponse['statusCode'];

    // Check the status code
    if (statusCode == 201) {
      // Successful response
      String checkoutPageUrl = jsonResponse['data']['checkout_page'];
      String orderId = jsonResponse['data']['orderId'];
      print("Order successfully created!");
      print("Checkout Page URL: $checkoutPageUrl");
      print("Order ID: $orderId");
      Globals.showToast(context, "Order successfully created!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebviewScreen(url: checkoutPageUrl),
        ),
      );

    } else if (statusCode == 409) {
      // Conflict: Merchant Trade Number already exists
      String message = jsonResponse['message'];
      print("Conflict: $message");
      Globals.showToast(context, message);
    } else {
      // Handle other status codes here if necessary
      print("Status Code: $statusCode");
      String message = jsonResponse['message'];
      Globals.showToast(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Create Order'),
            leading: widget.showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Don't use .pushReplacement here
                    },
                  )
                : null,
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Set the background color to white
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the border color to grey
                        ),
                        child: TextFormField(
                          controller: _authTokenController,
                          maxLines: null, // for multiline
                          decoration: const InputDecoration(
                            labelText: 'Auth Token',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Globals.showToast(
                                  context, 'Please enter auth token');
                              return 'Please enter auth token';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Set the background color to white
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the border color to grey
                        ),
                        child: TextFormField(
                          controller: _returnUrlController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: 'Return Url',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Globals.showToast(
                                  context, 'Please enter return Url.');
                              return 'Please enter return Url.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Set the background color to white
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the border color to grey
                        ),
                        child: TextFormField(
                          controller: _callBackUrlController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: 'Callback Url',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Globals.showToast(
                                  context, 'Please enter callback Url.');
                              return 'Please enter callback Url.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Set the background color to white
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the border color to grey
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          // Allow decimal input
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalRange: 2)
                          ],
                          // Custom input formatter

                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Globals.showToast(
                                  context, 'Please enter amount.');
                              return 'Please enter amount.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Set the background color to white
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the border color to grey
                        ),
                        child: TextFormField(
                          controller: _tradeController,
                          keyboardType: TextInputType.number,
                          maxLength: 32,
                          decoration: const InputDecoration(
                            labelText: 'Trade Number',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Globals.showToast(
                                  context, 'Please enter trade number.');
                              return 'Please enter trade number.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Set the background color to white
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the border color to grey
                        ),
                        child: TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            labelText: 'Mobile',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Globals.showToast(
                                  context, 'Please enter mobile.');
                              return 'Please enter mobile.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Set the background color to white
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the border color to grey
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          maxLines: null,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Globals.showToast(
                                  context, 'Please enter valid email.');
                              return 'Please enter valid email.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                          padding: const EdgeInsets.all(8.0),
                          // decoration: BoxDecoration(
                          //   color: Colors.white, // Set the background color to white
                          //   borderRadius: BorderRadius.circular(8.0),
                          //   border: Border.all(color: Colors.grey), // Set the border color to grey
                          // ),

                          child: SizedBox(
                            height: 40.00,
                            child: ElevatedButton(
                              onPressed: () => _submitButton(context),
                              child: const Text('SUBMIT'),
                            ),
                          )),
                    ],
                  )),
            ),
          )),
    );

    throw UnimplementedError();
  }
}
