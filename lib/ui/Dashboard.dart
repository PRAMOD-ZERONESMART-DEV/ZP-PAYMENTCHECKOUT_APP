import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utils/Globals.dart';
import '../model/DataItems.dart';
import 'LoginScreen.dart';
import 'OrderFormScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final List<DataItems> items = [
    DataItems('Generate Token', 'assets/images/token.png'),
    DataItems('Create Order', 'assets/images/orders.png'),
    DataItems('Transactions', 'assets/images/transaction.png'),
    DataItems('Refunds', 'assets/images/refund.png'),
  ];

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      theme: ThemeData(
          // appBarTheme: const AppBarTheme(
          //     systemOverlayStyle: SystemUiOverlayStyle.dark
          // ),
          primarySwatch: Colors.red
      ),
      initialRoute: '/', // Set the initial route to be the home page

      home: Scaffold(
        appBar: AppBar(title: const Text('Zerone-Pay')),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  showTitle(items[index].title);
                },
                child: GridItem(
                  title: items[index].title,
                  imageAsset: items[index].imageAsset,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void showTitle(String title) {
    if (title == 'Generate Token') {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => LoginScreen(showBackButton: true)),
      );
    } else if (title == 'Create Order') {
      // Keep the Dashboard route in the stack, no need for pushReplacement here
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => OrderFormScreen(showBackButton: true)),
      );
    } else {
      Globals.showToast(context, 'coming soon..');
    }
  }
}

class GridItem extends StatelessWidget {
  final String title;
  final String imageAsset;

  const GridItem({Key? key, required this.title, required this.imageAsset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            width: 48,
            height: 48,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

