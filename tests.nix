{ category, fn, set, list, optics, ... }:
let
  setOptics = optics set fn;
  listOptics = optics list fn;
in {
  pathOnSet = assert (setOptics.path [ "foo" "bar" "baz" ] (el: el + 1) { foo.bar.baz = 2; }) == { foo.bar.baz = 3; }; {};
  pathOnList = assert (listOptics.path [ 0 1 2 ] (el: el + 1) [ [ 0 [ 0 0 2 ] ] ]) == [ [ 0 [ 0 0 3 ] ] ]; {};
}
