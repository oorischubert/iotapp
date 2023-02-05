import 'dart:convert';
import 'package:http/http.dart' as http;

//TODO: IMPLEMENT ERROR DETECTION

class HttpController {
  final String url = "https://espledoori.herokuapp.com/color?key=";

  Future<void> setState({required String value, required String key}) async {
    try {
      http.post(Uri.parse(url + key), body: json.encode({"value": value}));
    } catch (e) {
      print("Error: $e"); //For debugging
      //add error handling here
    }
  }

  Future<bool> getState({required String key}) async {
    final response = await http.get(Uri.parse(url + key));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (decoded['value'] == "b'H'") {
      return true;
    } else {
      return false;
    }
  }
}
