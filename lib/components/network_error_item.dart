import 'package:flutter/material.dart';

class NetworkErrorItem extends StatelessWidget {
  const NetworkErrorItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Koneksi internet tidak tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Text(
              'Silahkan coba lagi',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Text(
              ':(',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Icon(
              Icons.signal_wifi_connected_no_internet_4,
              size: 90,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Image.asset("assets/images/person1.png"),
          ],
        ),
      ),
    );
  }
}
