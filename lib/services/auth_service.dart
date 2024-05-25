import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as g;
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../config/api.dart';

class AuthService {
  Future<bool> forgotPassword(
      BuildContext context, Map<String, dynamic> params) async {
    try {
      final Response response = await dio.post(
        urlAPI('auth/change_password'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      if (response.statusCode == 201) {
        g.Get.snackbar(
          "Ubah password berhasil",
          "",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.check, color: Colors.green),
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        g.Get.snackbar(
          "Ubah password gagal!",
          "",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.offline_bolt, color: Colors.red),
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    } catch (e) {
      if (e is DioError) {
        g.Get.snackbar(
          "Ubah password gagal!",
          "${e.response!.data['message'] != "" ? e.response!.data['message'] : e.response!.statusMessage}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.offline_bolt, color: Colors.red),
          duration: const Duration(seconds: 2),
        );
      }
      return false;
    }
  }

  Future<bool> login(BuildContext context, Map<String, dynamic> params) async {
    const storage = FlutterSecureStorage();
    try {
      final Response response = await dio.post(
        urlAPI('auth/login'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      if (response.statusCode == 201) {
        await storage.write(
          key: 'access_token',
          value: response.data['access_token'],
        );
        return true;
      } else {
        g.Get.snackbar(
          "Login gagal!",
          "${response.data['message']}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.offline_bolt, color: Colors.red),
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    } catch (e) {
      g.Get.snackbar(
        "Login gagal!",
        "Login akun gagal",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        icon: const Icon(Icons.offline_bolt, color: Colors.red),
        duration: const Duration(seconds: 2),
      );
      return false;
    }
  }

  Future<bool> register(
      BuildContext context, Map<String, dynamic> params) async {
    const storage = FlutterSecureStorage();
    try {
      final Response response = await dio.post(
        urlAPI('auth/registerWithPhone'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      if (response.statusCode == 201) {
        // to login
        final Response responseLogin = await dio.post(
          urlAPI('auth/login'),
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode({
            'username': params['phone'],
            'password': params['password'],
          }),
        );
        if (responseLogin.statusCode == 201) {
          await storage.write(
            key: 'access_token',
            value: responseLogin.data['access_token'],
          );
        }
        g.Get.snackbar(
          "Daftar berhasil",
          "${response.data['message']}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.check, color: Colors.green),
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        g.Get.snackbar(
          "Daftar gagal!",
          "${response.data['message']}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.offline_bolt, color: Colors.red),
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    } catch (e) {
      if (e is DioError) {
        g.Get.snackbar(
          "Daftar gagal!",
          "${e.response!.data['message'] != "" ? e.response!.data['message'] : e.response!.statusMessage}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.offline_bolt, color: Colors.red),
          duration: const Duration(seconds: 2),
        );
      }
      return false;
    }
  }

  Future<dynamic> verifyToken(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    try {
      final Response response = await dio.get(
        urlAPI('auth/verify_token'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
      );
      if (response.statusCode == 200) {
        await storage.write(
          key: 'id',
          value: response.data['user']['id'].toString(),
        );
        await storage.write(
          key: 'username',
          value: response.data['user']['username'].toString(),
        );
        await storage.write(
          key: 'name',
          value: response.data['user']['name'].toString(),
        );
        await storage.write(
          key: 'phoneCountryCode',
          value: response.data['user']['phoneCountryCode'].toString(),
        );
        await storage.write(
          key: 'phone',
          value: response.data['user']['phone'].toString(),
        );
        await storage.write(
          key: 'email',
          value: response.data['user']['email'].toString(),
        );
        await storage.write(
          key: 'created_on',
          value: response.data['user']['createdOn'].toString(),
        );
        return true;
      } else {
        await _deleteStorage();
        return false;
      }
    } catch (e) {
      await _deleteStorage();
      return false;
    }
  }

  Future<void> _deleteStorage() async {
    const storage = FlutterSecureStorage();
    bool isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (isDeviceConnected) {
      await storage.deleteAll();
    }
  }
}
