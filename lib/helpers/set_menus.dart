import 'package:flutter/material.dart';

Color activeTabColor(String value, dynamic data) {
  if (value == "Pemasukan") {
    return data[1];
  } else if (value == "Pengeluaran") {
    return data[2];
  } else if (value == "Hutang") {
    return data[3];
  } else if (value == "Piutang") {
    return data[4];
  }
  return data[0];
}

List<String> miniGradImages = [
  "assets/images/minigrad0.png",
  "assets/images/minigrad1.png",
  "assets/images/minigrad2.png",
  "assets/images/minigrad3.png",
  "assets/images/minigrad4.png",
];

List<Color> labelsColor = [
  Colors.grey.shade200,
  const Color.fromARGB(255, 231, 255, 240),
  const Color.fromARGB(255, 253, 243, 241),
  const Color.fromARGB(255, 255, 251, 236),
  const Color.fromARGB(255, 235, 245, 255),
];

List<Color> reportActiveTabColor = [
  Colors.black87,
  Colors.green.shade700,
  Colors.red,
  Colors.amber.shade700,
  Colors.blue.shade700,
];

List<Color> chipsColor = [
  Colors.grey.shade200,
  const Color.fromARGB(255, 138, 241, 176),
  const Color.fromARGB(255, 255, 203, 191),
  const Color.fromARGB(255, 255, 226, 119),
  const Color.fromARGB(255, 159, 210, 255),
];

List<LinearGradient> gradient2 = [
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 238, 255, 246),
      Color.fromARGB(255, 222, 250, 235),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 255, 238, 238),
      Color.fromARGB(255, 228, 200, 200),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 255, 254, 238),
      Color.fromARGB(255, 233, 223, 202),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 238, 241, 255),
      Color.fromARGB(255, 221, 228, 255),
    ],
  ),
];

List<LinearGradient> gradientActiveDMenu = [
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF11998e),
      Color(0xFF38ef7d),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 240, 130, 130),
      Color(0xFFec008c),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 243, 239, 12),
      Color(0xFFffb300),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF0072ff),
      Color(0xFF00c6ff),
    ],
  )
];

List<LinearGradient> gradientMenu = [
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF38ef7d),
      Color(0xFF11998e),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFec008c),
      Color.fromARGB(255, 240, 130, 130),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFfffc00),
      Color(0xFFffb300),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF00c6ff),
      Color(0xFF0072ff),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 61, 61, 61),
      Color.fromARGB(255, 185, 185, 185),
    ],
  )
];

List<IconData> iconMenus = [
  Icons.download_for_offline_outlined,
  Icons.upload_rounded,
  Icons.content_copy_rounded,
  Icons.content_paste_go_rounded,
];

List<LinearGradient> modalGradientMenu = [
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF11998e),
      Color(0xFF38ef7d),
      Colors.white54,
    ],
  ),
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFec008c),
      Color.fromARGB(255, 240, 130, 130),
      Colors.white54,
    ],
  ),
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFffb300),
      Color(0xFFfffc00),
      Colors.white54,
    ],
  ),
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0072ff),
      Color(0xFF00c6ff),
      Colors.white54,
    ],
  )
];

List<LinearGradient> modalGradientMenu2 = [
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white54,
      Color(0xFF38ef7d),
      Colors.white54,
    ],
  ),
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white54,
      Color(0xFFec008c),
      Colors.white54,
    ],
  ),
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white54,
      Color(0xFFffb300),
      Colors.white54,
    ],
  ),
  const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white54,
      Color(0xFF00c6ff),
      Colors.white54,
    ],
  )
];
