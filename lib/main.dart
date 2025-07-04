import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user_repository.dart';

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

  void _checkPassword() async {
    setState(() {
      String enteredPassword = _passwordController.text;
      imageSource = enteredPassword == "QWERTY123"
          ? "images/idea.png"
          : "images/stop.png";
    });

    if (_passwordController.text == "QWERTY123") {
      await userRepository.loadData();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfilePage(loginName: _loginController.text),
        ),
      );
    }

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


class ProfilePage extends StatefulWidget {
  final String loginName;

  const ProfilePage({super.key, required this.loginName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: userRepository.firstName);
    _lastNameController = TextEditingController(text: userRepository.lastName);
    _phoneController = TextEditingController(text: userRepository.phoneNumber);
    _emailController = TextEditingController(text: userRepository.email);

    _firstNameController.addListener(_saveData);
    _lastNameController.addListener(_saveData);
    _phoneController.addListener(_saveData);
    _emailController.addListener(_saveData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome Back ${widget.loginName}")),
      );
    });
  }

  void _saveData() {
    userRepository
      ..firstName = _firstNameController.text
      ..lastName = _lastNameController.text
      ..phoneNumber = _phoneController.text
      ..email = _emailController.text;
    userRepository.saveData();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Unsupported Action"),
          content: Text("Cannot open $url on this device."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome Back ${widget.loginName}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First Name Field
            _buildStyledTextField(
              controller: _firstNameController,
              hintText: "First Name",
            ),
            const SizedBox(height: 10),

            // Last Name Field
            _buildStyledTextField(
              controller: _lastNameController,
              hintText: "Last Name",
            ),
            const SizedBox(height: 10),

            // Phone with icons
            _buildTextFieldWithIcons(
              controller: _phoneController,
              hintText: "Phone Number",
              icons: [
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () => _launchUrl("tel:${_phoneController.text}"),
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () => _launchUrl("sms:${_phoneController.text}"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Email with icon
            _buildTextFieldWithIcons(
              controller: _emailController,
              hintText: "Email address",
              icons: [
                IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () => _launchUrl("mailto:${_emailController.text}"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      color: const Color(0xFFFCF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcons({
    required TextEditingController controller,
    required String hintText,
    required List<Widget> icons,
  }) {
    return Container(
      color: const Color(0xFFFCF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          ...icons,
        ],
      ),
    );
  }


}

