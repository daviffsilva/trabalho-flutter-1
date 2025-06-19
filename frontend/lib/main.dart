import 'package:entrega_app/data/models/usuario.dart';
import 'package:entrega_app/data/models/pedido.dart';
import 'package:entrega_app/data/services/usuario_service.dart';
import 'package:entrega_app/data/services/theme_service.dart';
import 'package:entrega_app/presentation/screens/cliente/home_page.dart';
import 'package:entrega_app/presentation/screens/cliente/entregas_page.dart';
import 'package:entrega_app/presentation/screens/cliente/perfil_page.dart';
import 'package:entrega_app/presentation/screens/cliente/criar_pedido_page.dart';
import 'package:entrega_app/presentation/screens/cliente/pedido_detalhes_page.dart';
import 'package:entrega_app/presentation/screens/auth/auth_page.dart';
import 'package:entrega_app/presentation/screens/motorista/home_page.dart';
import 'package:entrega_app/presentation/screens/motorista/entregas_page.dart';
import 'package:entrega_app/presentation/screens/motorista/perfil_page.dart';
import 'package:entrega_app/presentation/screens/motorista/entrega_detalhes_page.dart';
import 'package:entrega_app/presentation/screens/motorista/pedidos_disponiveis_page.dart';
import 'package:entrega_app/presentation/screens/settings_page.dart';
import 'package:entrega_app/presentation/widgets/cliente_drawer.dart';
import 'package:entrega_app/presentation/widgets/motorista_drawer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _themeService.themeStream.listen((mode) {
      setState(() {
        _themeMode = mode;
      });
    });
  }

  @override
  void dispose() {
    _themeService.dispose();
    super.dispose();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _themeService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Entregas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: const LoginCheck(),
      routes: {
        '/home': (context) => const MainScreen(),
        '/auth': (context) => const AuthPage(),
        '/settings': (context) => const SettingsPage(),
        '/criar-pedido': (context) => const CriarPedidoPage(),
        '/motorista/entrega-detalhes': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Pedido;
          return EntregaDetalhesPage(pedido: args);
        },
        '/motorista/pedidos-disponiveis': (context) => const PedidosDisponiveisPage(),
        '/cliente/pedido-detalhes': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Pedido;
          return PedidoDetalhesPage(pedido: args);
        },
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

        return const AuthPage();
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

  @override
  void dispose() {
    _usuarioService.dispose();
    super.dispose();
  }

  Future<void> _carregarTipoUsuario() async {
    final usuario = await _usuarioService.getCurrentUser();
    if (usuario != null) {
      setState(() {
        _isMotorista = usuario.tipo == TipoUsuario.motorista;
      });
    }
  }

  Future<void> _fazerLogout() async {
    await _usuarioService.removerUsuario();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
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
      drawer: _isMotorista ? const MotoristaDrawer() : const ClienteDrawer(),
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