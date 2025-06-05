import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week-4 - Login Page',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(title: 'Login Page'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});



  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = FlutterSecureStorage();

  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  String imageSource = "images/question-mark.png";// initial image

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();

    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    String? savedLogin = await storage.read(key: "username");
    String? savedPassword = await storage.read(key: "password");

    if (savedLogin != null && savedPassword != null) {
      _loginController.text = savedLogin;
      _passwordController.text = savedPassword;


      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Previous login data loaded.")),
        );
      });
    }
  }
  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Login Info?"),
          content: const Text("Would you like to save your login name and password?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () async {

                await storage.deleteAll();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {

                await storage.write(key: "username", value: _loginController.text);
                await storage.write(key: "password", value: _passwordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkPassword() {
    setState(() {
      String enteredPassword = _passwordController.text;
      if (enteredPassword == "QWERTY123") {
        imageSource = "images/idea.png";
      } else {
        imageSource = "images/stop.png";
      }
    });
    _showSaveDialog();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView( // to avoid overflow when keyboard shows
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  hintText: "Enter login name",
                  border: OutlineInputBorder(),
                  labelText: "Login",
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Enter password",
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPassword,
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue// 👈 sets the text color
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),


              ),
              const SizedBox(height: 20),
              Semantics(
                child: Image.asset(imageSource, width: 300, height: 300),
                label: "Image that updates based on login status",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
