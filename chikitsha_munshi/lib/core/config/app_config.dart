import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get serverUrl => dotenv.env['server'] ?? 'http://172.16.14.122:5000';
  
  // You can add other configuration variables here
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
}
