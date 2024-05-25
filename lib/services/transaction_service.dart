import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import '../config/api.dart';
import 'package:get/get.dart' as g;

class TransactionService {
  Future<bool> delete(BuildContext context, int id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    try {
      final Response response = await dio.delete(
        urlAPI('transaction/delete/$id'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> save(BuildContext context, dynamic params) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    final userId = await storage.read(key: 'id');

    try {
      final Response response = await dio.post(
        urlAPI('transaction/create'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
        data: jsonEncode({
          'userId': int.parse(userId!),
          'args': params,
        }),
      );
      if (response.statusCode == 201) {
        // g.Get.snackbar("Tersimpan!", "");
        g.Get.snackbar(
          "Proses tersimpan!",
          "Berhasil menyimpan transaksi",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
