import 'package:flutter/material.dart';
import 'package:service_robot_new/services/api_service.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<dynamic> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final data = await ApiService.fetchLogs();
      setState(() {
        logs = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching logs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Service Robot"),
        backgroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: const Text("Home", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Logs",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Control", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : logs.isNotEmpty
                ? ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final item = logs[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Battery: ${item['battery']}%",
                                  style: const TextStyle(fontSize: 16)),
                              Text("Obstacle: ${item['obstacle'] ? "Yes" : "No"}",
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                "Timestamp: ${item['timestamp']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.amber[100],
                    child: const Center(
                      child: Text(
                        "No logs available.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
      ),
    );
  }
}
