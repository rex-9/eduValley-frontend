import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  // static final String url = 'https://rextutor.manishchudasama.com/api';
  static final String url = 'http://10.0.2.2:8000/api';
  //if you are using android studio emulator, change localhost to 10.0.2.2
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token')!);
  }

  authData(data, apiUrl) async {
    var fullUrl = url + apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  getData(apiUrl) async {
    var fullUrl = url + apiUrl;
    await _getToken();
    return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  }

  postData(apiUrl) async {
    var fullUrl = url + apiUrl;
    await _getToken();
    return await http.post(Uri.parse(fullUrl), headers: _setHeaders());
  }

  deleteData(apiUrl) async {
    var fullUrl = url + apiUrl;
    await _getToken();
    return await http.delete(Uri.parse(fullUrl), headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
