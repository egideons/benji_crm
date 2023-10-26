import 'package:benji_aggregator/controller/user_controller.dart';
import 'package:benji_aggregator/model/user_model.dart';
import 'package:benji_aggregator/services/api_url.dart';
import 'package:http/http.dart' as http;

Future<bool> isAuthorized() async {
  final response = await http.get(
    Uri.parse('$baseURL/auth/'),
    headers: authHeader(),
  );
  return response.statusCode == 200;
}

Map<String, String> authHeader([String? authToken, String? contentType]) {
  if (authToken == null) {
    UserModel user = UserController.instance.getUserSync();
    authToken = user.token;
  }

  Map<String, String> res = {
    'Authorization': 'Bearer $authToken',
  };
  // 'Content-Type': 'application/json', 'application/x-www-form-urlencoded'

  if (contentType != null) {
    res['Content-Type'] = contentType;
  }
  return res;
}
