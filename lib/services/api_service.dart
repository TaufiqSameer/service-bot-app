import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://service-bot-production.up.railway.app/api";

  // About / Team
  static Future<List<dynamic>> getTeam() async {
    final response = await http.get(Uri.parse("$baseUrl/team"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load team");
    }
  }

// Move Robot
static Future<void> moveRobot() async {
  final response = await http.post(
    Uri.parse("$baseUrl/move"), // now calls /api/move
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data["success"] == true) {
      return; // ✅ success
    } else {
      throw Exception("Failed to move robot: ${data["message"]}");
    }
  } else {
    throw Exception("Failed to move robot: ${response.statusCode}");
  }
}



  // Logs
  static Future<List<dynamic>> fetchLogs() async {
    final response = await http.get(Uri.parse("$baseUrl/logs"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load logs");
    }
  }

  // Status (always return latest row as Map)
static Future<List<dynamic>> fetchStatus() async {
    final response = await http.get(Uri.parse("https://service-bot-production.up.railway.app/api/status"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;  // ✅ Decode as List
    } else {
      throw Exception("Failed to load status logs");
    }
  }

  // Orders
  static Future<List<dynamic>> fetchOrders() async {
    final response = await http.get(Uri.parse("$baseUrl/orders"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load orders");
    }
  }

  // Submit new task
  static Future<void> submitOrder(String task, {String destination = "autonomous"}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/order"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"task": task, "destination": destination}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to submit order");
    }
  }
}

