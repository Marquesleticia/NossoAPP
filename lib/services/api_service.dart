import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://your-mockapi-id.mockapi.io';  // Substitua pela sua URL <----------

  static Future<bool> login(String login, String senha) async {
    final response = await http.get(Uri.parse('$baseUrl/login?login=$login&senha=$senha'));
    return response.statusCode == 200 && json.decode(response.body).isNotEmpty;
  }

  static Future<void> registerUser(String login, String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'login': login, 'email': email, 'senha': senha}),
    );
    if (response.statusCode != 201) throw Exception('Erro');
  }

  static Future<List<Map<String, dynamic>>> getPessoas() async {
    final response = await http.get(Uri.parse('$baseUrl/pessoa'));
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Erro');
  }

  static Future<void> createPessoa(String nome, String cpf, String telefone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pessoa'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nome': nome, 'cpf': cpf, 'telefone': telefone}),
    );
    if (response.statusCode != 201) throw Exception('Erro');
  }

  static Future<void> updatePessoa(String id, String nome, String cpf, String telefone) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pessoa/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nome': nome, 'cpf': cpf, 'telefone': telefone}),
    );
    if (response.statusCode != 200) throw Exception('Erro');
  }

  static Future<void> deletePessoa(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/pessoa/$id'));
    if (response.statusCode != 200) throw Exception('Erro');
  }
}

