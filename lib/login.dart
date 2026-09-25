import 'package:flutter/material.dart';
import 'main.dart';

class LoginPage extends StatelessWidget {
  final bool temaOscuro;
  final ValueChanged<bool> onCambiarTema;

  const LoginPage({
    super.key,
    required this.temaOscuro,
    required this.onCambiarTema,
  });

  void _iniciarSesion(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DashboardPage(temaOscuro: temaOscuro, onCambiarTema: onCambiarTema),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DriveWise')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 80),

            const SizedBox(height: 24),

            Text(
              'Bienvenido a DriveWise',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'Inicia sesión para continuar',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _iniciarSesion(context),
                child: const Text('Iniciar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
