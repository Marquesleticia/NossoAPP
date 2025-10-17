import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen());
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _screen = 'login';  // 'login', 'register', 'people', 'person'

  Map<String, dynamic>? _editingPerson;
  List<Map<String, dynamic>> _pessoas = [];

  void _login() async {
    if (await ApiService.login(_loginCtrl.text, _senhaCtrl.text)) {
      _loadPessoas();
      setState(() => _screen = 'people');
    }
  }

  void _register() async {
    await ApiService.registerUser(_loginCtrl.text, _senhaCtrl.text, _senhaCtrl.text);
    setState(() => _screen = 'login');
  }

  void _loadPessoas() async {
    _pessoas = await ApiService.getPessoas();
    setState(() {});
  }

  void _savePerson(String nome, String cpf, String telefone) async {
    if (_editingPerson == null) {
      await ApiService.createPessoa(nome, cpf, telefone);
    } else {
      await ApiService.updatePessoa(_editingPerson!['id'], nome, cpf, telefone);
    }
    _loadPessoas();
    setState(() => _screen = 'people');
  }

  void _deletePerson() async {
    await ApiService.deletePessoa(_editingPerson!['id']);
    _loadPessoas();
    setState(() => _screen = 'people');
  }

  @override
  Widget build(BuildContext context) {
    if (_screen == 'login') {
      return Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _loginCtrl, decoration: InputDecoration(labelText: 'Usuário')),
              TextField(controller: _senhaCtrl, decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
              ElevatedButton(onPressed: _login, child: Text('Entrar')),
              TextButton(onPressed: () => setState(() => _screen = 'register'), child: Text('Cadastrar-se')),
            ],
          ),
        ),
      );
    } else if (_screen == 'register') {
      return Scaffold(
        appBar: AppBar(title: Text('Cadastro')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _loginCtrl, decoration: InputDecoration(labelText: 'Login')),
              TextField(controller: _senhaCtrl, decoration: InputDecoration(labelText: 'Email')),
              TextField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
              ElevatedButton(onPressed: _register, child: Text('Cadastrar')),
            ],
          ),
        ),
      );
    } else if (_screen == 'people') {
      return Scaffold(
        appBar: AppBar(title: Text('Pessoas')),
        body: ListView.builder(
          itemCount: _pessoas.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(_pessoas[i]['nome']),
            onTap: () {
              _editingPerson = _pessoas[i];
              setState(() => _screen = 'person');
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _editingPerson = null;
            setState(() => _screen = 'person');
          },
          child: Icon(Icons.add),
        ),
      );
    } else {  // 'person'
      final nomeCtrl = TextEditingController(text: _editingPerson?['nome'] ?? '');
      final cpfCtrl = TextEditingController(text: _editingPerson?['cpf'] ?? '');
      final telCtrl = TextEditingController(text: _editingPerson?['telefone'] ?? '');
      return Scaffold(
        appBar: AppBar(title: Text(_editingPerson == null ? 'Nova Pessoa' : 'Editar Pessoa')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: nomeCtrl, decoration: InputDecoration(labelText: 'Nome')),
              TextField(controller: cpfCtrl, decoration: InputDecoration(labelText: 'CPF')),
              TextField(controller: telCtrl, decoration: InputDecoration(labelText: 'Telefone')),
              ElevatedButton(onPressed: () => _savePerson(nomeCtrl.text, cpfCtrl.text, telCtrl.text), child: Text('Salvar')),
              if (_editingPerson != null) ElevatedButton(onPressed: _deletePerson, child: Text('Excluir')),
            ],
          ),
        ),
      );
    }
  }
}