import 'package:devtimer/service/auth_service_dio.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido al perfil'),
            ElevatedButton(
              onPressed: () {
                // Lógica para cerrar sesión
                Navigator.pop(context);
              },
              child: Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}