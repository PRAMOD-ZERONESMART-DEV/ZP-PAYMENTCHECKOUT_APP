import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Globals{

  static String BASE_URL = "https://api-uat.zeronepay.com/zerone-pay";
  static String PROD_BASE_URL = "https://api.zeronepay.com/pg";
  static String AUTH_TOKEN = "";
  static String CALL_BACK_URL = "";
  static bool? isProductionMode = false;

  //UAT
  static String uatUserName = "64f6ef0c8ff312ea07103b73";
  static String uatUserPassword = "lFNvoEFBIL9WyxxCFkIl";
  static String uatUserPublicKey = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIQfVHLl3zPA0M0iLefvWNawMfgxwJHRHqf/s0X/SI7brAxMjkEiA0ysv/maJ1bCHkYTqNwKeszqfaSdjYf6GI8CAwEAAQ==";
  //Prod
  static String prodUserName = "65000a454aecb1917bda9eb8";
  static String prodUserPassword = "Wna3v6QSERoR6OtUVFl1";
  static String prodUserPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA43TsgPJ1r1/y6A0awljtsL4uXvxkC8n7c0VIiCMU8/3n76TrpQdzks748PIOpWPhic87YsM9X7WHZF6MMfMlloNy7BGq+4s49CnLCqjPvL1R+J9vXPMKI1YvdnYzpmEO5hdxBB+6lpQc8i03ETGjdbX49e2DEMyEMW90dcbOuiKQiaABO7zNdfuWA8I54n3k/QMpBaL1mjJc+miFzGwsU4N4Es/4AuDBRMZPzv7vYTAi9x175UB3gJDakkmhi9CynGfSEiSrwgaY1e2/SEanploCGrxPs+LE6LJFXISBhX0z0GkL33Uc9ZiibXBUNwtPpwhxUsGP6yFpQZtaHy6LmQIDAQAB";

  static void showAlert(BuildContext context, String title, String subTitle){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subTitle),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }

  static String generateUniqueTradeNumber() {
    DateTime now = DateTime.now();
    String timestampMicros = now.microsecondsSinceEpoch.toString();
    String randomNumber = _generateRandomNumberString(18 - timestampMicros.length);

    String tradeNumber = timestampMicros + randomNumber;
    return tradeNumber;
  }

  static String _generateRandomNumberString(int length) {
    Random random = Random();
    String randomString = "";
    for (int i = 0; i < length; i++) {
      randomString += random.nextInt(10).toString();
    }
    return randomString;
  }
}