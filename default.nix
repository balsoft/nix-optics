rec {
  category = p:
  with p;
  rec {
    pipe = builtins.foldl' compose id;
  };

  fn =
  rec {
    # :: (->) a a
    id = x: x;

    # :: (->) b c -> (->) a b -> (->) a c
    compose = f: g: x: f (g x);

    # :: (a' -> a) -> (b -> b') -> (->) a b -> (->) a' b'
    dimap = f: g: fn: a': g (fn (f a'));

    # :: (a' -> a) -> (->) a b -> (->) a' b
    lmap = f: dimap f id;

    # :: (b -> b') -> (->) a b -> (->) a b'
    rmap = g: dimap id g;

    # :: (->) a b -> (->) (a /\ x) (b /\ x)
    first = f: { fst, snd }: { fst = f fst; inherit snd; };

    # :: (->) a b -> (->) (x /\ a) (x /\ b)
    second = f: { fst, snd }: { inherit fst; snd = f snd; };

    # :: (a -> b -> c) -> b -> a -> c
    flip = f: x: y: f y x;

    # :: (a -> a) -> a
    fix = f: let x = f x; in x;

    # :: (a -> a -> a) -> a -> a
    fix1 = fn.compose fix;

    inherit (category fn) pipe;
  };

  set =
  rec {
    # k -> { [k] = v; ...r } -> v /\ r
    uncons = k: r: { fst = r."${k}"; snd = builtins.removeAttrs r [k]; };

    # k -> v /\ r -> { [k] = v; ...r }
    cons = k: { fst, snd }: snd // { "${k}" = fst; };
  };

  list =
  rec {
    # Taken from nixpkgs
    # {
    take =
      count: sublist 0 count;

    drop =
      count:
      list: sublist count (builtins.length list) list;

    sublist =
      start:
      count:
      list:
      let len = builtins.length list; in
      builtins.genList
        (n: builtins.elemAt list (n + start))
        (if start >= len then 0
         else if start + count > len then len - start
         else count);
    # }

    # i -> L -> Lᵢ/\ [... Lᵢ₋₁, Lᵢ₊₁ ...]
    uncons = i: l: { fst = builtins.elemAt l i; snd = take i l ++ drop (i + 1) l; };

    # i -> a /\ L -> [... Lᵢ₋₁, a, Lᵢ...]
    cons = i: { fst, snd }: take i snd ++ [fst] ++ drop i snd;
  };

  optics = t: p:
  with p;
  rec {

    # k -> Iso { [k] = a; ...r } { [k] = b; ...r } (a /\ r) (b /\ r)
    unconsed = k: dimap (t.uncons k) (t.cons k);

    # k -> Lens { [k] = a; ...r } { [k] = b; ...r } a b
    key = k: fn.pipe [(unconsed k) first];

    # given a list of keys, produces an optic that focuses on the relevant
    # part of an appropriately keyed nested attrset
    path = keys: fn.pipe (map key keys);

  };
}
