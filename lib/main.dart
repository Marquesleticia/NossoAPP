import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Pessoas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          primary: Colors.blueAccent,
          secondary: Colors.blueGrey.shade400,
          background: Colors.grey.shade100,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.blueGrey.shade700),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _screen = 'login'; // 'login', 'register', 'people', 'person'

  Map<String, dynamic>? _editingPerson;
  List<Map<String, dynamic>> _pessoas = [];

  void _login() async {
    if (await ApiService.login(_loginCtrl.text, _senhaCtrl.text)) {
      _loadPessoas();
      setState(() => _screen = 'people');
    }
  }

  void _register() async {
    await ApiService.registerUser(_loginCtrl.text, _emailCtrl.text, _senhaCtrl.text);
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
    final theme = Theme.of(context);

    if (_screen == 'login') {
      return Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: theme.colorScheme.primary),
              SizedBox(height: 30),
              TextField(controller: _loginCtrl, decoration: InputDecoration(labelText: 'Usuário')),
              SizedBox(height: 15),
              TextField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
              SizedBox(height: 25),
              ElevatedButton(onPressed: _login, child: Text('Entrar')),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => _screen = 'register'),
                child: Text('Criar nova conta', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ],
          ),
        ),
      );
    } else if (_screen == 'register') {
      return Scaffold(
        appBar: AppBar(title: Text('Cadastro')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt, size: 80, color: theme.colorScheme.primary),
              SizedBox(height: 30),
              TextField(decoration: InputDecoration(labelText: 'Login')),
              SizedBox(height: 15),
              TextField(decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 15),
              TextField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
              SizedBox(height: 25),
              ElevatedButton(onPressed: _register, child: Text('Cadastrar')),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => _screen = 'login'),
                child: Text('Voltar ao Login', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ],
          ),
        ),
      );
    } else if (_screen == 'people') {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pessoas'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => setState(() => _screen = 'login'),
              tooltip: 'Sair',
            )
          ],
        ),
        body: _pessoas.isEmpty
            ? Center(child: Text('Nenhuma pessoa cadastrada.'))
            : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _pessoas.length,
                itemBuilder: (context, i) {
                  final pessoa = _pessoas[i];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(pessoa['nome'], style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(pessoa['telefone'] ?? ''),
                      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                      onTap: () {
                        _editingPerson = pessoa;
                        setState(() => _screen = 'person');
                      },
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _editingPerson = null;
            setState(() => _screen = 'person');
          },
          child: Icon(Icons.add),
        ),
      );
    } else {
      final nomeCtrl = TextEditingController(text: _editingPerson?['nome'] ?? '');
      final cpfCtrl = TextEditingController(text: _editingPerson?['cpf'] ?? '');
      final telCtrl = TextEditingController(text: _editingPerson?['telefone'] ?? '');
      return Scaffold(
        appBar: AppBar(title: Text(_editingPerson == null ? 'Nova Pessoa' : 'Editar Pessoa')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(controller: nomeCtrl, decoration: InputDecoration(labelText: 'Nome')),
              SizedBox(height: 15),
              TextField(controller: cpfCtrl, decoration: InputDecoration(labelText: 'CPF')),
              SizedBox(height: 15),
              TextField(controller: telCtrl, decoration: InputDecoration(labelText: 'Telefone')),
              SizedBox(height: 30),
                       // 🔹 Botões variam conforme a ação
          if (_editingPerson == null)
            // Modo NOVA pessoa → Salvar + Cancelar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _savePerson(nomeCtrl.text, cpfCtrl.text, telCtrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Salvar'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _screen = 'people'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Cancelar'),
                  ),
                ),
              ],
            )
          else
            // Modo EDITAR pessoa → Salvar + Excluir
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _savePerson(nomeCtrl.text, cpfCtrl.text, telCtrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Salvar'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deletePerson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Excluir'),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      );
    }
  }
}
