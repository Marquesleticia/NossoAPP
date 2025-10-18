import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://68f2da1ffd14a9fcc427123d.mockapi.io'; // ✅ Sua URL MockAPI

  // 🔹 LOGIN: verifica usuário e senha
  static Future<bool> login(String login, String senha) async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List users = json.decode(response.body);
      final user = users.firstWhere(
        (u) => u['login'] == login && u['senha'] == senha,
        orElse: () => null,
      );
      return user != null;
    } else {
      throw Exception('Erro ao buscar usuários (${response.statusCode})');
    }
  }

  // 🔹 REGISTRO DE USUÁRIO
  static Future<void> registerUser(String login, String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'login': login, 'email': email, 'senha': senha}),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao cadastrar usuário (${response.statusCode})');
    }
  }

  // 🔹 PEGAR PESSOAS
  static Future<List<Map<String, dynamic>>> getPessoas() async {
    final response = await http.get(Uri.parse('$baseUrl/pessoas'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erro ao carregar pessoas (${response.statusCode})');
    }
  }

  // 🔹 CRIAR PESSOA
  static Future<void> createPessoa(String nome, String cpf, String telefone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pessoas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nome': nome, 'cpf': cpf, 'telefone': telefone}),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar pessoa (${response.statusCode})');
    }
  }

  // 🔹 ATUALIZAR PESSOA
  static Future<void> updatePessoa(String id, String nome, String cpf, String telefone) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pessoas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nome': nome, 'cpf': cpf, 'telefone': telefone}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar pessoa (${response.statusCode})');
    }
  }

  // 🔹 DELETAR PESSOA
  static Future<void> deletePessoa(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/pessoas/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar pessoa (${response.statusCode})');
    }
  }
}
