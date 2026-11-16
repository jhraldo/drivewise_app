
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  final bool temaOscuro;
  final ValueChanged<bool> onCambiarTema;

  const LoginPage({
    super.key,
    required this.temaOscuro,
    required this.onCambiarTema,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();

  bool _esRegistro = false;
  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  Future<void> _autenticar() async {
    String nombre = nombreController.text.trim();
    String correo = correoController.text.trim();
    String password = passwordController.text.trim();
    String confirmar = confirmarController.text.trim();

    if (_esRegistro && nombre.isEmpty) {
      _mostrarMensaje('Ingresa tu nombre completo.');
      return;
    }

    if (correo.isEmpty || password.isEmpty) {
      _mostrarMensaje('Completa el correo y la contraseña.');
      return;
    }

    if (_esRegistro && password != confirmar) {
      _mostrarMensaje('Las contraseñas no coinciden.');
      return;
    }

    if (_esRegistro && password.length < 6) {
      _mostrarMensaje('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      if (_esRegistro) {
        UserCredential resultado =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: correo,
          password: password,
        );

        User? usuario = resultado.user;

        if (usuario != null) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario.uid)
              .set({
            'uid': usuario.uid,
            'nombre': nombre,
            'correo': correo,
            'fechaRegistro': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: correo,
          password: password,
        );
      }

      if (!mounted) return;

      User? usuario = FirebaseAuth.instance.currentUser;

if (usuario == null) {
  throw Exception('No se encontró el usuario autenticado.');
}

DocumentSnapshot<Map<String, dynamic>> perfil =
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

if (!perfil.exists) {
  throw Exception('No se encontró el perfil del usuario.');
}

String nombreCompleto = perfil.data()?['nombre']?.toString() ?? '';

String primerNombre = nombreCompleto.trim().split(' ').first;

if (!mounted) return;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => DashboardPage(
      temaOscuro: widget.temaOscuro,
      onCambiarTema: widget.onCambiarTema,
      nombreUsuario: primerNombre,
    ),
  ),
);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No fue posible completar la operación.';

      switch (e.code) {
        case 'invalid-email':
          mensaje = 'El correo electrónico no es válido.';
          break;
        case 'user-not-found':
        case 'invalid-credential':
          mensaje = 'El correo o la contraseña son incorrectos.';
          break;
        case 'wrong-password':
          mensaje = 'La contraseña es incorrecta.';
          break;
        case 'email-already-in-use':
          mensaje = 'Este correo ya tiene una cuenta registrada.';
          break;
        case 'weak-password':
          mensaje = 'La contraseña debe tener al menos 6 caracteres.';
          break;
        case 'too-many-requests':
          mensaje = 'Demasiados intentos. Inténtalo más tarde.';
          break;
        case 'network-request-failed':
          mensaje = 'Verifica tu conexión a internet.';
          break;
      }

      if (mounted) {
        _mostrarMensaje(mensaje);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        if (e.code == 'permission-denied') {
          _mostrarMensaje(
            'La cuenta se creó, pero Firestore no permitió guardar el perfil. Debemos configurar sus reglas de seguridad.',
          );
        } else {
          _mostrarMensaje('No fue posible guardar el perfil del usuario.');
        }
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Ocurrió un error inesperado.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _decoracion(
    String etiqueta,
    IconData icono, {
    Widget? sufijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono),
      suffixIcon: sufijo,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF16A34A),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _campoPassword(String etiqueta, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: !_mostrarPassword,
      decoration: _decoracion(
        etiqueta,
        Icons.lock_outline,
        sufijo: IconButton(
          onPressed: () {
            setState(() {
              _mostrarPassword = !_mostrarPassword;
            });
          },
          icon: Icon(
            _mostrarPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }

  Widget _botonPrincipal() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _cargando ? null : _autenticar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _cargando
            ? const SizedBox(
                height: 23,
                width: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _esRegistro ? 'Crear mi cuenta' : 'Iniciar sesión',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _esRegistro ? 'Crea tu cuenta' : 'Bienvenido de nuevo',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _esRegistro
              ? 'Registra tus datos para comenzar a utilizar DriveWise.'
              : 'Ingresa tus datos para continuar con la gestión de tu vehículo.',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),

        if (_esRegistro) ...[
          TextField(
            controller: nombreController,
            textCapitalization: TextCapitalization.words,
            decoration: _decoracion(
              'Nombre completo',
              Icons.person_outline,
            ),
          ),
          const SizedBox(height: 16),
        ],

        TextField(
          controller: correoController,
          keyboardType: TextInputType.emailAddress,
          decoration: _decoracion(
            'Correo electrónico',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),

        _campoPassword('Contraseña', passwordController),

        if (_esRegistro) ...[
          const SizedBox(height: 16),
          _campoPassword(
            'Confirmar contraseña',
            confirmarController,
          ),
        ],

        if (!_esRegistro)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _cargando ? null : _recuperarPassword,
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),

        const SizedBox(height: 16),
        _botonPrincipal(),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _esRegistro
                    ? '¿Ya tienes una cuenta?'
                    : '¿Todavía no tienes una cuenta?',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: _cargando
                  ? null
                  : () {
                      setState(() {
                        _esRegistro = !_esRegistro;
                      });
                    },
              child: Text(
                _esRegistro ? 'Inicia sesión' : 'Regístrate',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _recuperarPassword() async {
    String correo = correoController.text.trim();

    if (correo.isEmpty) {
      _mostrarMensaje('Ingresa tu correo para recuperar tu contraseña.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);

      if (mounted) {
        _mostrarMensaje(
          'Te enviamos un correo para restablecer tu contraseña.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _mostrarMensaje(
          e.code == 'user-not-found'
              ? 'No encontramos una cuenta con ese correo.'
              : 'No fue posible enviar el correo de recuperación.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ancho = MediaQuery.of(context).size.width;
    final esPantallaGrande = ancho > 750;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: esPantallaGrande
                  ? Row(
                      children: [
                        Expanded(
                          child: _panelMarca(),
                        ),
                        const SizedBox(width: 50),
                        Expanded(
                          child: _formulario(context),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _panelMarca(),
                        const SizedBox(height: 35),
                        _formulario(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelMarca() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF14532D),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'DriveWise',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Todo sobre tu vehículo, en un solo lugar.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Controla tus gastos, mantenimientos, documentos y recordatorios de una manera sencilla.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF86EFAC),
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Tu información organizada y protegida.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
