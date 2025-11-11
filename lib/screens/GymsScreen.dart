import 'package:flutter/material.dart';
import '../services/gym_api_service.dart';

class GymsScreen extends StatefulWidget {
  final int userId;
  const GymsScreen({required this.userId, super.key});

  @override
  State<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends State<GymsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _gyms = [];

  @override
  void initState() {
    super.initState();
    _fetchGyms();
  }

  Future<void> _fetchGyms() async {
    final gyms = await GymApiService().getGyms(widget.userId);
    setState(() {
      _gyms = gyms;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Gyms"),
        backgroundColor: Colors.red.shade700,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _gyms.isEmpty
              ? const Center(child: Text("No gyms found"))
              : ListView.builder(
                  itemCount: _gyms.length,
                  itemBuilder: (_, index) {
                    final gym = _gyms[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          gym['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                        subtitle: Text(gym['location'] ?? ''),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // navigate to gym details or membership plans
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
