import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrPhone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final success = await ApiService().loginUser(
      _emailOrPhone.text.trim(),
      _password.text.trim(),
    );

    setState(() => _loading = false);

    if (success != null) {
      await saveLogin(success); // ✅ save user info locally
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(user: success)),
      );
    }
    else {
      setState(() => _errorMessage = "Invalid credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 236, 238),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: Colors.white, // 👈 background color here
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              // background color
              side: BorderSide(color: Colors.blue.shade100, width: 1),
              
            ),
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Replace this with your own logo
                  Image.asset(
                    'assets/images/logo.png', // make sure this path exists
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Trainzo Gym Software',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _emailOrPhone,
                    decoration: InputDecoration(
                      labelText: 'Email or Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),

                  const SizedBox(height: 10),
                  _loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 24),
                            ),
                            onPressed: _login,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveLogin(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', user['id'].toString());
    await prefs.setString('name', user['name']);
    await prefs.setString('email', user['email']);
    await prefs.setString('role', user['role']);
    await prefs.setString('sessionId', user['session_id']); // ✅ save session
  }

}
