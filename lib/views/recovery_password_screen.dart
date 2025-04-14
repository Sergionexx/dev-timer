import 'package:flutter/material.dart';

class RecoveryPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Lógica para enviar correo de recuperación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Correo enviado')),
                );
              },
              child: Text('Enviar Correo'),
            ),
          ],
        ),
      ),
    );
  }
}