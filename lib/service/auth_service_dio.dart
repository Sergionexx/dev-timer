import 'dart:convert';
import 'package:dio/dio.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth/'; // Reemplaza con tu URL base
  final Dio _dio = Dio();

  // Registro de usuario
  Future<Map<String, dynamic>> register({
    required String name,
    required String lastname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'name': name,
          'lastname': lastname,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to register user: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  // Login de usuario
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to login: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  // Obtener información del usuario por correo
  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('$baseUrl/user/$email');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch user: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Eliminar usuario
  Future<void> deleteUser(String id) async {
    try {
      final response = await _dio.delete('$baseUrl/user/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Actualizar estado premium
  Future<Map<String, dynamic>> updatePremiumStatus({
    required String id,
    required bool isPremium,
  }) async {
    try {
      final response = await _dio.put(
        '$baseUrl/user/$id/premium',
        data: {'isPremium': isPremium},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update premium status: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error updating premium status: $e');
    }
  }
}