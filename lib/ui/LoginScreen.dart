import 'dart:async';
import 'dart:convert';

import 'package:ZeronePay/Utils/Cryptom.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../Utils/Globals.dart';

class LoginScreen extends StatefulWidget {
  var showBackButton;

  LoginScreen({Key? key, required this.showBackButton}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _publicKeyController = TextEditingController();
  String _token = '';
  bool _isLoading = false;
  bool showPasteText = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = Globals.uatUserName;
    _passwordController.text = Globals.uatUserPassword;
    _publicKeyController.text = Globals.uatUserPublicKey;
  }

  void _submitButton(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      String userName = _usernameController.text;
      String password = _passwordController.text;
      String publicToken = _publicKeyController.text;

      getTimeStamp(userName, password, publicToken);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    // This function copies the token to the clipboard
    Clipboard.setData(ClipboardData(text: _token));
    Globals.showToast(context, 'Token copied to clipboard');
  }

  void getTimeStamp(String userName, String password, String publicToken) {
    int time = currentTimeInSeconds();
    String fText = "$password.$time";
    if (kDebugMode) {
      print(fText);
    }
    try {
      String key = Cryptom().text(fText, publicToken);
      if (kDebugMode) {
        print(key);
      }
      fetchAPIWithBasicAuth(userName, password, key);
    } catch (e) {
      Globals.showToast(context, 'invalid public key');
    }
  }

  int currentTimeInSeconds() {
    var ms = (DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  void setUserCredentials() {
    if (Globals.isProductionMode!) {
      setState(() {
        _usernameController.text = Globals.prodUserName;
        _passwordController.text = Globals.prodUserPassword;
        _publicKeyController.text = Globals.prodUserPublicKey;
      });
    } else {
      setState(() {
        _usernameController.text = Globals.uatUserName;
        _passwordController.text = Globals.uatUserPassword;
        _publicKeyController.text = Globals.uatUserPublicKey;
      });
    }
  }

  Future<void> fetchAPIWithBasicAuth(
      String userName, String password, String key) async {
    setState(() {
      _isLoading = true;
    });
    // Encode the username and password to Base64
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$userName:$password'))}';

    try {
      String baseUrl = Globals.BASE_URL;
      if (Globals.isProductionMode!) {
        baseUrl = Globals.PROD_BASE_URL;
      } else {
        baseUrl = Globals.BASE_URL;
      }
      if (kDebugMode) {
        print(baseUrl);
      }
      final response = await http.get(
        Uri.parse("$baseUrl/v1/token"),
        headers: {'Authorization': basicAuth, 'x-zp-signature': key},
      );

      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response: ${response.body}');
      }
      if (response.statusCode == 200) {
        // API call successful, handle the response
        // print('Response: ${response.body}');

        String token = responseData['data']['token'];
        if (kDebugMode) {
          print('Token: $token');
        }
        //Globals.showToast(context, token);
        visibleUIData(token);
      } else {
        // API call failed, handle the error
        // print('Error: ${response.statusCode}');
        String message = responseData['message'];
        Globals.showToast(context, '$message');
        setState(() {
          showPasteText = false;
        });
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void visibleUIData(String response) {
    showPasteText = true;
    setState(() {
      _token = response;
    });

    Globals.AUTH_TOKEN = _token;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Generate Token'),
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
                    const SizedBox(height: 50.0),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // Set the background color to white
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: Colors.grey), // Set the border color to grey
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'User Name',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter user name';
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
                            color: Colors.grey), // Set the border color to grey
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password.';
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
                            color: Colors.grey), // Set the border color to grey
                      ),
                      child: TextFormField(
                        controller: _publicKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Public Key',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        maxLines: null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter public key.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: Globals.isProductionMode ?? false,
                          onChanged: (bool? newValue) {
                            setState(() {
                              Globals.isProductionMode = newValue!;
                            });

                            setUserCredentials();
                          },
                        ),
                        const Text('Production Mode ?'),
                      ],
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
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                strokeWidth: 2.0,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: showPasteText
                          ? const Text(
                              'Your Token (Click on text to copy to clipboard)',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 2.0),
                    Container(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(),
                          child: showPasteText
                              ? Text(
                                  _token,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),
                                )
                              : const SizedBox.shrink(),
                        )),
                  ],
                )),
          ),
        ),
      ),
    );

    // TODO: implement build
    throw UnimplementedError();
  }
}
