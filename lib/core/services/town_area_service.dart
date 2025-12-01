import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // Added for getApplicationDocumentsDirectory
import 'dart:io'; // Added for File

class TownAreaService {
  static const String baseUrl = 'http://192.168.1.100/rouftest1xopy2/';
  
  // Get all cities (towns)
  static Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString('serverUrl') ?? baseUrl;
      
      final response = await http.get(
        Uri.parse('$serverUrl/getclientcity.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Error fetching cities: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching cities: $e');
      return [];
    }
  }

  // Get areas for a specific city (town)
  static Future<List<Map<String, dynamic>>> getAreasForCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString('serverUrl') ?? baseUrl;
      
      // Create a PHP file that accepts city parameter
      final response = await http.post(
        Uri.parse('$serverUrl/getclientarea.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'city': cityName},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Error fetching areas for city $cityName: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching areas for city $cityName: $e');
      return [];
    }
  }

  // Get areas using the SQL query you provided
  static Future<List<Map<String, dynamic>>> getAreasByTownCode(String townName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString('serverUrl') ?? baseUrl;
      
      final response = await http.post(
        Uri.parse('$serverUrl/getareasbytown.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'town_name': townName},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Error fetching areas for town $townName: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching areas for town $townName: $e');
      return [];
    }
  }

  // Centralized offline data loading
  static Future<List<Map<String, dynamic>>> getOfflineCities() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/offline_data/getclientcity.json');
      print('DEBUG: City file exists: ${await file.exists()}');
      if (await file.exists()) {
        final content = await file.readAsString();
        print('DEBUG: City file content length: ${content.length}');
        final List<dynamic> data = json.decode(content);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('DEBUG: City file not found');
        return [];
      }
    } catch (e) {
      print('Exception loading offline cities: ${e.toString()}');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getOfflineAreas() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/offline_data/getclientarea.json');
      print('DEBUG: Area file exists: ${await file.exists()}');
      if (await file.exists()) {
        final content = await file.readAsString();
        print('DEBUG: Area file content length: ${content.length}');
        final List<dynamic> data = json.decode(content);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('DEBUG: Area file not found');
        return [];
      }
    } catch (e) {
      print('Exception loading offline areas: ${e.toString()}');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getOfflineClients() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/offline_data/getOrclClients.json');
      print('DEBUG: Client file exists: ${await file.exists()}');
      if (await file.exists()) {
        final content = await file.readAsString();
        print('DEBUG: Client file content length: ${content.length}');
        final List<dynamic> data = json.decode(content);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('DEBUG: Client file not found');
        return [];
      }
    } catch (e) {
      print('Exception loading offline clients: ${e.toString()}');
      return [];
    }
  }
} 