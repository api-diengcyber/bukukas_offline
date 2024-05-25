import 'package:dio/dio.dart';

// const String baseUrl = "http://192.168.60.183:4445";
const String baseUrl = "http://api-markaz-keu.aipos.id";
const String apiUrl = baseUrl + "";

final dio = Dio(BaseOptions());

String urlAPI(endpoint) {
  return "$apiUrl/$endpoint";
}
