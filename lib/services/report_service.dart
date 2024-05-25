import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.dart';

class ReportService {
  Future<dynamic> getMenuDetail(BuildContext context, int id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    try {
      final Response response = await dio.get(
        urlAPI('report/get_menu_detail/$id'),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token",
          },
        ),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getMenu(BuildContext context, params) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    var data = jsonEncode(
      {}..addAll({
          'type': params['type'],
          'reportType': params['reportType'],
          'startDate': params['startDate'],
          'endDate': params['endDate'],
        }),
    );

    try {
      final Response response = await dio.post(
        urlAPI('report/get_menu'),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token",
          },
        ),
        data: data,
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getData(BuildContext context, params) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    var data = jsonEncode(
      {}..addAll({
          'type': params['type'],
          'reportType': params['reportType'],
          'startDate': params['startDate'],
          'endDate': params['endDate'],
          'limit': params['limit'],
          'page': params['page'],
        }),
    );

    try {
      final Response response = await dio.post(
        urlAPI('report/get_data'),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token",
          },
        ),
        data: data,
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getSummary(BuildContext context, params) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    var data = jsonEncode(
      {}..addAll({
          'type': params['type'],
          'reportType': params['reportType'],
          'startDate': params['startDate'],
          'endDate': params['endDate'],
        }),
    );

    try {
      final Response response = await dio.post(
        urlAPI('report/get_summary'),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token",
          },
        ),
        data: data,
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getDashboard(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    try {
      final Response response = await dio.get(
        urlAPI('report/get_dashboard'),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        }),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
