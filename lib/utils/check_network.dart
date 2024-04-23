import 'dart:io';
import 'package:http/http.dart' as http;

Future<bool> checkNetwork() async {
 
   try {
    final result = await http.get(Uri.parse('http://google.com'));
    if(result.statusCode==200){
      return true;
    }
  else{
      return false;
  }
  }
   on SocketException catch (_) {
    return false;
  }
}