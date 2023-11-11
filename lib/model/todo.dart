import 'dart:convert';

List<Todo> todoFromJson(String str) =>
    List<Todo>.from(json.decode(str).map((x) => Todo.fromJson(x)));

String todoToJson(List<Todo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Todo {
  String? objectId;
  String? title;
  String? description;

  Todo({
    this.objectId,
    this.title,
    this.description,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        objectId: json["objectId"],
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() =>
      {'objectId': objectId, 'title': title, 'description': description};
}
