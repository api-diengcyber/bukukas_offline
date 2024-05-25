import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import '../config/api.dart';
import 'package:get/get.dart' as g;

class MenuService {
  Future<bool> delete(BuildContext context, int id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    try {
      final Response response = await dio.delete(
        urlAPI('menu/delete/$id'),
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

  Future<bool> update(BuildContext context, int menuId, String type,
      Map<String, dynamic> params) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    final userId = await storage.read(key: 'id');

    int defaultValue =
        (params['default_value'] != null && params['default_value'] != "")
            ? int.parse(params['default_value']
                .replaceAll(RegExp(r'[^\d.]'), '')
                .replaceAll(RegExp(r'[.]'), '')
                .replaceAll(RegExp(r'[,]'), '.'))
            : 0;

    var data = jsonEncode(
      {}..addAll(
          {
            'name': params['name'],
            'notes': params['notes'],
            'default_value': defaultValue,
            'deadline': params['deadline'] != null && params['deadline'] != ""
                ? params['deadline'].toIso8601String()
                : null,
            'type': type,
            'userId': int.parse(userId!),
          },
        ),
    );

    try {
      final Response response = await dio.patch(
        urlAPI('menu/update/$menuId'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
        data: data,
      );
      if (response.statusCode == 200) {
        g.Get.snackbar("Update berhasil!", "${response.data['message']}");
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> create(
      BuildContext context, String type, Map<String, dynamic> params) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    final userId = await storage.read(key: 'id');

    int defaultValue =
        (params['default_value'] != null && params['default_value'] != "")
            ? int.parse(params['default_value']
                .replaceAll(RegExp(r'[^\d.]'), '')
                .replaceAll(RegExp(r'[.]'), '')
                .replaceAll(RegExp(r'[,]'), '.'))
            : 0;

    int total = (params['total'] != null && params['total'] != "")
        ? int.parse(params['total']
            .replaceAll(RegExp(r'[^\d.]'), '')
            .replaceAll(RegExp(r'[.]'), '')
            .replaceAll(RegExp(r'[,]'), '.'))
        : 0;

    int paid = (params['paid'] != null && params['paid'] != "")
        ? int.parse(params['paid']
            .replaceAll(RegExp(r'[^\d.]'), '')
            .replaceAll(RegExp(r'[.]'), '')
            .replaceAll(RegExp(r'[,]'), '.'))
        : 0;

    var data = jsonEncode(
      {}..addAll(
          {
            'name': params['name'],
            'notes': params['notes'],
            'default_value': defaultValue,
            'total': total,
            'paid': paid,
            'deadline': params['deadline'] != null
                ? params['deadline'].toIso8601String()
                : '',
            'type': type,
            'userId': int.parse(userId!),
            'debtDate': params['debtDate'] != null
                ? params['debtDate'].toIso8601String()
                : '',
          },
        ),
    );
    try {
      final Response response = await dio.post(
        urlAPI('menu/create'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
        data: data,
      );
      if (response.statusCode == 201) {
        g.Get.snackbar(
          "Tersimpan!",
          "${response.data['message']}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: const Icon(Icons.check, color: Colors.green),
          duration: const Duration(seconds: 1),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> getByType4Transaction(
      BuildContext context, String type, int page) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    try {
      final Response response = await dio.post(
        urlAPI('menu/get_by_type_for_transaction/$type'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
        data: {
          'limit': 10,
          'page': page,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> getByType(BuildContext context, String type, int page) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    try {
      final Response response = await dio.post(
        urlAPI('menu/get_by_type/$type'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
        data: {
          'limit': 10,
          'page': page,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
