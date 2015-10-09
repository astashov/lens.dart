# Lens

Super simple package, which gives you a small class `Lens`, which allows to build functional lenses.
Shamelessly stolen from
http://davids-code.blogspot.com/2014/02/immutable-domain-and-lenses-in-java-8.html

## Why would I need that?

If you have a big immutable data structure, and you want:

* Get a changed version of it without writing things like
  `foo.update(bar: foo.bar.update(blah: foo.bar.blah.update(moo: "another moo")))`
  in all places you want to change the `moo`.

* Get access to some spot in that structure without knowing how to get to it
  (something like `theLensToDeepElement.get(bigGlobalStructure)` will return a `DeepElement` :))

* Update the structure without knowing how to get to the deeply nested field
  (something like `theLensToDeepElement.set(bigGlobalStructure, new DeepElement())` will set
  a the `DeepElement` somewhere deep in the data structure, and will return a new version of the data structure.

## How to work with it.

([see full example](https://github.com/astashov/lens.dart/blob/master/example/example.dart))

Imagine you have a simple TODO app. The app has many todo items, every item has a status (active or completed).
You keep the whole state in a global immutable data structure. So, it looks something like this:

```dart
class App {
  final String name;
  final Iterable<TodoItem> items;
  App(this.name, this.items);
  App update({String name, Iterable<TodoItem> items}) {
    return new App(name ?? this.name, items ?? this.items);
  }
  String toString() => "<App name: $name, items: $items>";
}

class TodoItem {
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
```

Then, you create the initial state:

```dart
var state = new App("TODOist", [
  new TodoItem(new Status("active")),
  new TodoItem(new Status("completed"))]);
```
You want to find a way to update the status of the second item.

For that, you need to create lenses for the `App->TodoItem` relationship, and for the `TodoItem->Status` relationship.

So, let's add them:

```dart
class App {
  static Lens<App, TodoItem> itemsLens(int index) => new Lens(
      (app) => app.items[index],
      (app, todoItem) {
        var items = []..addAll(app.items);
        items[index] = todoItem;
        return app.update(items: items);
      });
  // ... the rest of content is the same
```

The `Lens` constructor accepts 2 arguments, you have to specify the way to get a value, and the way to set a new value.
Since there is an array of items on `App`, you build a new lens every time for a specific item index.

Now, let's add the same for `TodoItem->Status`:

```dart
class TodoItem {
  static final Lens<TodoItem, Status> statusLens = new Lens(
      (item) => item.status,
      (item, status) => item.update(status: status));
  // ... the rest of content is the same
```

Here we do the same thing, it's just a static property, since we don't have to variate it depending on index.
We just specify how to get the status, and how to set the new status.

Now we can do something actually useful:

```dart
void main() {
  var statusLens = App.itemsLens(1).then(TodoItem.statusLens);
  print(statusLens.get(app));
  // => <Status value: "completed">
  print(statusLens.set(app, new Status("active")));
  // => <App name: TODOist, items: [
  //        <TodoItem status: <Status active>>,
  //        <TodoItem status: <Status active>>]>
}
```

So, once we created `statusLens`, it encapsulates the knowledge how to get to the status of the second todo item.
We can just use it to get and set the new status of the second todo item without knowing where exactly that status
is placed in the data structure.
