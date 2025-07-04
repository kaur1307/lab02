import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  final _storage = FlutterSecureStorage();

  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String email = '';

  Future<void> loadData() async {
    firstName = await _storage.read(key: 'firstName') ?? '';
    lastName = await _storage.read(key: 'lastName') ?? '';
    phoneNumber = await _storage.read(key: 'phoneNumber') ?? '';
    email = await _storage.read(key: 'email') ?? '';
  }

  Future<void> saveData() async {
    await _storage.write(key: 'firstName', value: firstName);
    await _storage.write(key: 'lastName', value: lastName);
    await _storage.write(key: 'phoneNumber', value: phoneNumber);
    await _storage.write(key: 'email', value: email);
  }
}

final userRepository = UserRepository();
