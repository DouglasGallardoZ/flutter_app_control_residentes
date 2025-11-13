import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardin/models/user.dart';
import 'package:guardin/services/user_service.dart';

class AuthService {
  static const String _currentUserKey = 'current_user_id';
  static const String _rememberMeKey = 'remember_me';

  final UserService _userService = UserService();

  Future<User?> login(String email, String password, bool rememberMe) async {
    final users = await _userService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => throw Exception('Credenciales inválidas'),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.id);
    await prefs.setBool(_rememberMeKey, rememberMe);

    return user;
  }

  Future<User> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String unidad,
  }) async {
    final users = await _userService.getAllUsers();
    final existingUser = users.where((u) => u.email == email);
    
    if (existingUser.isNotEmpty) {
      throw Exception('El correo electrónico ya está registrado');
    }

    return await _userService.createUser(
      nombre: nombre,
      email: email,
      password: password,
      telefono: telefono,
      unidad: unidad,
    );
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    
    if (userId == null) return null;
    
    return await _userService.getUserById(userId);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    final userId = prefs.getString(_currentUserKey);
    
    return rememberMe && userId != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_rememberMeKey);
  }
}
