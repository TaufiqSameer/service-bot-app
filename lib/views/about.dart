import 'package:flutter/material.dart';
import 'package:service_robot_new/services/api_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<dynamic> team = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeam();
  }

  Future<void> fetchTeam() async {
    try {
      final fetchedTeam = await ApiService.getTeam();
      setState(() {
        team = fetchedTeam;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading team: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About the Team"),
        backgroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : team.isEmpty
              ? const Center(child: Text("No team data available"))
              : ListView.builder(
                  itemCount: team.length,
                  itemBuilder: (context, index) {
                    final member = team[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: member['image'] != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "https://service-bot-production.up.railway.app/${member['image']}",
                                ),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(member['name'] ?? "Unnamed"),
                        subtitle: Text(member['role'] ?? "Team Member"),
                      ),
                    );
                  },
                ),
    );
  }
}
