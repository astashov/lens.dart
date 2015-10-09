library lens.example;

import 'package:lens/lens.dart';

class App {
  static Lens<App, TodoItem> itemsLens(int index) => new Lens(
      (app) => app.items[index],
      (app, todoItem) {
        var items = []..addAll(app.items);
        items[index] = todoItem;
        return app.update(items: items);
      });

  final String name;
  final Iterable<TodoItem> items;
  App(this.name, this.items);
  App update({String name, Iterable<TodoItem> items}) => new App(name ?? this.name, items ?? this.items);
  String toString() => "<App name: $name, items: $items>";
}

class TodoItem {
  static final Lens<TodoItem, Status> statusLens = new Lens(
      (item) => item.status,
      (item, status) => item.update(status: status));

  final Status status;
  TodoItem(this.status);
  TodoItem update({Status status}) => new TodoItem(status ?? this.status);
  String toString() => "<TodoItem status: $status>";
}

class Status {
  final String value;
  Status(this.value);
  Status update({String value}) => new Status(value ?? this.value);
  String toString() => "<Status $value>";
}

main(List<String> args) {
  var app = new App("TODOist", [
      new TodoItem(new Status("active")),
      new TodoItem(new Status("completed"))]);

  var statusLens = App.itemsLens(1).then(TodoItem.statusLens);
  print(statusLens.get(app));
  // => <Status value: "completed">
  print(statusLens.set(app, new Status("active")));
  // => <App name: TODOist, items: [
  //        <TodoItem status: <Status active>>,
  //        <TodoItem status: <Status active>>]>
}