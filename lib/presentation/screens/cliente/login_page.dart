import 'package:entrega_app/data/models/usuario.dart';
import 'package:entrega_app/data/services/usuario_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _usuarioService = UsuarioService();
  TipoUsuario _tipoUsuario = TipoUsuario.cliente;

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      final usuario = Usuario(
        id: 1,
        nome: _tipoUsuario == TipoUsuario.cliente ? 'Cliente Teste' : 'Motorista Teste',
        email: _emailController.text,
        tipo: _tipoUsuario,
      );

      await _usuarioService.salvarUsuario(usuario);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SegmentedButton<TipoUsuario>(
                segments: const [
                  ButtonSegment<TipoUsuario>(
                    value: TipoUsuario.cliente,
                    label: Text('Cliente'),
                    icon: Icon(Icons.person),
                  ),
                  ButtonSegment<TipoUsuario>(
                    value: TipoUsuario.motorista,
                    label: Text('Motorista'),
                    icon: Icon(Icons.delivery_dining),
                  ),
                ],
                selected: {_tipoUsuario},
                onSelectionChanged: (Set<TipoUsuario> selected) {
                  setState(() {
                    _tipoUsuario = selected.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fazerLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 