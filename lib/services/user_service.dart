import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:guardin/models/user.dart';

class UserService {
  static const String _usersKey = 'users';
  final _uuid = Uuid();

  Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null) {
      await _initializeSampleData();
      return await getAllUsers();
    }

    try {
      final List<dynamic> usersList = json.decode(usersJson);
      return usersList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      await _initializeSampleData();
      return await getAllUsers();
    }
  }

  Future<User?> getUserById(String id) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<User> createUser({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String unidad,
  }) async {
    final users = await getAllUsers();
    final now = DateTime.now();
    
    final newUser = User(
      id: _uuid.v4(),
      nombre: nombre,
      email: email,
      password: password,
      telefono: telefono,
      unidad: unidad,
      qrCode: 'RESIDENT-${_uuid.v4()}',
      createdAt: now,
      updatedAt: now,
    );

    users.add(newUser);
    await _saveUsers(users);
    return newUser;
  }

  Future<User> updateUser(User user) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    
    if (index == -1) {
      throw Exception('Usuario no encontrado');
    }

    users[index] = user.copyWith(updatedAt: DateTime.now());
    await _saveUsers(users);
    return users[index];
  }

  Future<User> updateFaceImage(String userId, String imagePath) async {
    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('Usuario no encontrado');
    }

    return await updateUser(user.copyWith(faceImagePath: imagePath));
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    final sampleUsers = [
      User(
        id: 'user-1',
        nombre: 'Carlos Rodríguez',
        email: 'carlos@mail.com',
        password: '123456',
        telefono: '+593 412-1234567',
        unidad: 'A-101',
        qrCode: 'RESIDENT-carlos-a101',
        faceImagePath: 'face_registered',
        createdAt: now.subtract(Duration(days: 30)),
        updatedAt: now.subtract(Duration(days: 30)),
      ),
      User(
        id: 'user-2',
        nombre: 'María González',
        email: 'maria@mail.com',
        password: '123456',
        telefono: '+593 414-9876543',
        unidad: 'B-205',
        qrCode: 'RESIDENT-maria-b205',
        createdAt: now.subtract(Duration(days: 25)),
        updatedAt: now.subtract(Duration(days: 25)),
      ),
      User(
        id: 'user-3',
        nombre: 'Pedro Martínez',
        email: 'pedro@mail.com',
        password: '123456',
        telefono: '+593 416-5551234',
        unidad: 'C-310',
        qrCode: 'RESIDENT-pedro-c310',
        faceImagePath: 'face_registered',
        createdAt: now.subtract(Duration(days: 15)),
        updatedAt: now.subtract(Duration(days: 15)),
      ),
    ];

    await _saveUsers(sampleUsers);
  }
}
