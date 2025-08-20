import 'package:flutter/material.dart';
import 'package:service_robot_new/services/api_service.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<dynamic> statusLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

Future<void> fetchStatus() async {
  try {
    final data = await ApiService.fetchStatus();
    setState(() {
      statusLogs = data;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print("Error fetching status logs: $e");
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Robot Status Log"),
        backgroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: const Text("Home", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/logs'),
            child: const Text("Logs", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Status",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : statusLogs.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.amber[100],
                    child: const Center(
                      child: Text(
                        "No status records found.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(color: Colors.grey),
                      columns: const [
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Battery (%)")),
                        DataColumn(label: Text("Obstacle")),
                        DataColumn(label: Text("Timestamp")),
                      ],
                      rows: statusLogs.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item['id'].toString())),
                            DataCell(Text("${item['battery']}")),
                            DataCell(Text(item['obstacle'] ? "Yes" : "No")),
                            DataCell(Text(item['timestamp'].toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
      ),
    );
  }
}
