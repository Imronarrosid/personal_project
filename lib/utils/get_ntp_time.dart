import 'dart:convert';

import 'package:http/http.dart' as http;

Future<DateTime> fetchTime() async {
  final response = await http
      .get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Jakarta'));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    String datetime = data['datetime']; // Fetch the Jakarta time
    return DateTime.parse(datetime);
  } else {
    throw Exception('Failed to load time');
  }
}
