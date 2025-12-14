// lib/data/providers/http_client.dart
import 'package:dio/dio.dart';

class HttpClient {
  final Dio dio;
  HttpClient({required String baseUrl}) : dio = Dio(BaseOptions(baseUrl: baseUrl));
}
