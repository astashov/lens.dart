library lens;

// Shamelessly stolen from
// http://davids-code.blogspot.com/2014/02/immutable-domain-and-lenses-in-java-8.html
class Lens<A, B> {
  final Function fget;
  final Function fset;

  const Lens(B fget(A a), A fset(A a, B b))
      : this.fget = fget,
        this.fset = fset;

  B get(A a) {
    return fget(a);
  }

  A set(A a, B b) {
    return fset(a, b);
  }

  A mod(A a, B f(B b)) {
    return set(a, f(get(a)));
  }

  // I wish we have method generics here...
  Lens<dynamic, B> compose(final Lens<dynamic, A> that) {
    return new Lens((c) => get(that.get(c)), (c, b) => that.mod(c, (a) => set(a, b)));
  }

  // ...and here...
  Lens<A, dynamic> then(Lens<B, dynamic> that) {
    return that.compose(this);
  }
}
