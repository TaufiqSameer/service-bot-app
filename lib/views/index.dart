import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:service_robot_new/services/api_service.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  Map<String, dynamic>? statusData;
  List<dynamic> orders = [];
  List<dynamic> team = [];
  bool isLoading = true;
  final TextEditingController taskController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetchedStatus = await ApiService.fetchStatus();
      final fetchedTeam = await ApiService.getTeam();
      final fetchedOrders = await ApiService.fetchOrders();

      setState(() {
        statusData = fetchedStatus.isNotEmpty ? fetchedStatus[0] : {};
        team = fetchedTeam;
        orders = fetchedOrders.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> submitTask() async {
    final task = taskController.text.trim();
    final destination = destinationController.text.trim().isEmpty
        ? "autonomous"
        : destinationController.text.trim();
    if (task.isEmpty) return;
    try {
      await ApiService.submitOrder(task, destination: destination);
      taskController.clear();
      destinationController.clear();
      fetchData();
    } catch (e) {
      print("Error submitting task: $e");
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/logs');
        break;
      case 2:
        Navigator.pushNamed(context, '/status');
        break;
      case 3:
        Navigator.pushNamed(context, '/about');
        break;
    }
  }

  Widget buildCustomCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    final task = order['task'] ?? 'N/A';
    final destination = order['destination'] ?? 'autonomous';
    String formattedTime = 'No timestamp';

    if (order['ordered_at'] != null &&
        order['ordered_at'].toString().isNotEmpty) {
      try {
        final dateTime = DateTime.parse(order['ordered_at'].toString());
        formattedTime =
            "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
      } catch (_) {
        formattedTime = 'Invalid timestamp';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text("Destination: $destination"),
          Text("Status: ${order['status'] ?? 'N/A'}"),
          Text(
            "🕒 Ordered at: $formattedTime",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Service Robot",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
          
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 24,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.black54],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Meet the Service Robot 🤖",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "A smart assistant designed to deliver papers, snacks, and avoid obstacles efficiently inside our college!",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  
                  buildCustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "About the Project",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "This robot is built using a Raspberry Pi and sensors to help it navigate around the environment. It collects data such as battery status, obstacle detection, and logs them to a database for monitoring.\n\nUsers can control the robot via the app interface and monitor logs for performance and status updates.",
                        ),
                      ],
                    ),
                  ),

                  
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ApiService.moveRobot();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ Move command sent"),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("❌ Failed: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Move Robot",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  
                  buildCustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Robot Status Logs",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        statusData != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Battery: ${statusData!['battery'] ?? 'N/A'}%",
                                  ),
                                  Text(
                                    "Obstacle: ${(statusData!['obstacle'] ?? false) ? "Yes" : "No"}",
                                  ),
                                  Text(
                                    "Location: ${statusData!['location'] ?? 'Unknown'}",
                                  ),
                                ],
                              )
                            : const Text("No robot status logs available."),
                      ],
                    ),
                  ),

                  buildCustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Assign a New Task to Robot",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: taskController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Task",
                            hintText: "e.g., Take papers",
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: destinationController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Destination",
                            hintText: "e.g., Staff Room",
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: submitTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Submit Task"),
                        ),
                      ],
                    ),
                  ),

                  
                  buildCustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📋 Recent Robot Orders",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (orders.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order =
                                  orders[index] as Map<String, dynamic>;
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order['task'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Flexible(
                                      child: Text(
                                        "Destination: ${order['destination'] ?? 'autonomous'}",
                                        softWrap: true,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Flexible(
                                      child: Text(
                                        "🕒 Ordered at: ${order['ordered_at'] ?? 'N/A'}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        else
                          const Text("No recent orders found."),
                      ],
                    ),
                  ),
                  
                  buildCustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📍 Robot Current Location",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                statusData!['lat'] ?? 17.196555283658483,
                                statusData!['lng'] ??
                                    78.59614064024444, //17.196555283658483, 78.59614064024444
                              ),
                              zoom: 15,
                            ),
                            markers: {
                              if (statusData != null)
                                Marker(
                                  markerId: const MarkerId("robot"),
                                  position: LatLng(
                                    statusData!['lat'] ?? 17.19774936291105,
                                    statusData!['lng'] ?? 78.59842424770561,
                                  ),
                                  infoWindow: const InfoWindow(
                                    title: "Service Robot 🤖",
                                  ),
                                ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  buildCustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "👨‍💻 Project Team",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Developer: Mohammad Taufeeq Sameer (Software & Web Interface)",
                        ),
                        Text(
                          "Team Members: Bhavana (Sensors), Sreeja (Mechanics), Harsha (3D design)",
                        ),
                        SizedBox(height: 6),
                        Text(
                          "College Project (2025)",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Logs"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: "Control",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
      ),
    );
  }
}
