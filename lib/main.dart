import 'package:entrega_app/data/models/usuario.dart';
import 'package:entrega_app/data/services/usuario_service.dart';
import 'package:entrega_app/presentation/screens/cliente/home_page.dart';
import 'package:entrega_app/presentation/screens/cliente/entregas_page.dart';
import 'package:entrega_app/presentation/screens/cliente/perfil_page.dart';
import 'package:entrega_app/presentation/screens/cliente/login_page.dart';
import 'package:entrega_app/presentation/screens/motorista/home_page.dart';
import 'package:entrega_app/presentation/screens/motorista/entregas_page.dart';
import 'package:entrega_app/presentation/screens/motorista/perfil_page.dart';
import 'package:entrega_app/presentation/widgets/cliente_drawer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Entregas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginCheck(),
      routes: {
        '/home': (context) => const MainScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class LoginCheck extends StatelessWidget {
  const LoginCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: UsuarioService().usuarioEstaLogado(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MainScreen();
        }

        return const LoginPage();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isMotorista = false;
  final _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    _carregarTipoUsuario();
  }

  Future<void> _carregarTipoUsuario() async {
    final usuario = await _usuarioService.obterUsuario();
    if (usuario != null) {
      setState(() {
        _isMotorista = usuario.tipo == TipoUsuario.motorista;
      });
    }
  }

  Future<void> _fazerLogout() async {
    await _usuarioService.removerUsuario();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  List<Widget> get _pages => _isMotorista
      ? [
          const MotoristaHomePage(),
          const MotoristaEntregasPage(),
          const MotoristaPerfilPage(),
        ]
      : [
          const HomePage(),
          const EntregasPage(),
          const PerfilPage(),
        ];

  void _handleOnTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(_isMotorista ? 'App de Entregas - Motorista' : 'App de Entregas - Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _fazerLogout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Entregas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _handleOnTap,
      ),
    );
  }
}