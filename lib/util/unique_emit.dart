mixin UniqueEmit {
  Object get uniqueHash => identityHashCode(this);

  List<Object> get uniqueProps => [uniqueHash];
}
