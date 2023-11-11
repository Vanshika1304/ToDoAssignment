import 'dart:convert';

import 'package:http/http.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/constants.dart';

class TodoUtils {
  static final String _baseUrl = "https://parseapi.back4app.com/classes/";

  static Future<Response> addTodo(Todo todo) async {
    final apiUrl = _baseUrl + "todo";

    Response response = await post(
      Uri.parse(apiUrl),
      headers: {
        'X-Parse-Application-Id': kParseApplicationId,
        'X-Parse-REST-API-Key': kParseRestApiKey,
        'Content-Type': 'application/json'
      },
      body: json.encode(todo.toJson()),
    );

    return response;
  }

  static Future getTodoList() async {
    String apiUrl = _baseUrl + "todo";

    Response response = await get(Uri.parse(apiUrl), headers: {
      'X-Parse-Application-Id': kParseApplicationId,
      'X-Parse-REST-API-Key': kParseRestApiKey,
    });

    return response;
  }

  static Future updateTodo(Todo todo) async {
    String apiUrl = _baseUrl + "todo/${todo.objectId}";

    Response response = await put(Uri.parse(apiUrl),
        headers: {
          'X-Parse-Application-Id': kParseApplicationId,
          'X-Parse-REST-API-Key': kParseRestApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(todo.toJson()));

    return response;
  }

  static Future deleteTodo(String objectId) async {
    String apiUrl = _baseUrl + "todo/$objectId";

    Response response = await delete(Uri.parse(apiUrl), headers: {
      'X-Parse-Application-Id': kParseApplicationId,
      'X-Parse-REST-API-Key': kParseRestApiKey,
    });

    return response;
  }
}
