open Core.Std
open Pattern

let test_glob glob good bad =
  let pat = create_from_glob_string glob in
  List.iter good ~f:(fun good ->
    if not (matches pat good)
    then failwithf "%S should match %S" good glob ()
  );
  List.iter bad ~f:(fun bad ->
    if matches pat bad
    then failwithf "%S should not match %S" bad glob ()
  );

(* globs support the following: *)

(* escaping any character: *)
TEST_UNIT =
  List.iter (List.init 256 ~f:(fun i -> Option.value_exn (Char.of_int i)))
    ~f:(fun char ->
      let escaped = sprintf "\\%cq" char in
      let literal = sprintf "%cq" char in
      test_glob escaped [literal] [""; escaped])

(* choosing between alternatives with '{' and ',' *)
TEST_UNIT =
  test_glob "{a,b}" ["a"; "b"] [""; "c"; "ab"; "ba"; "bc"]

(* sequence of alternations *)
TEST_UNIT =
  test_glob "{a,b}{c,d}" ["ac"; "ad"; "bc"; "bd"] [""; "a"; "aa"; "ab"; "cb"; "cd"; "abc"]

(* nested alternations *)
TEST_UNIT =
  test_glob "{a{b,c},d}" ["ab"; "ac"; "d"] [""; "a"; "b"; "c"; "ad"; "bd"; "abc"; "abd"];

(* wildcard filename character *)
TEST_UNIT =
  test_glob "x?z"
    ["xyz"; "x?z"]
    ["xz"; "x/z"]

(* wildcard filename *)
TEST_UNIT =
  test_glob "a/*/b"
    ["a/foo/b"; "a/*/b"]
    ["aa/foo/b"; "a/foo/bb"; "afoob"; "a/foo/bar/b"]

(* wildcard partial filename *)
TEST_UNIT =
  test_glob "a*b"
    ["afoob"; "ab"]
    ["a/foo/b"; "afo/ob"; ""]

TEST_UNIT =
  test_glob "*"
    ["foo"]
    [".foo"; ""]

TEST_UNIT =
  test_glob "bar/*"
    ["bar/foo"; "bar/.foo"; "bar/"]
    []

TEST_UNIT =
  test_glob "a/*/c"
    ["a//c"; "a/b/c"]
    []

(* wildcard path *)
TEST_UNIT =
  test_glob "a/**/b"
    ["a/foo/bar/b"; "a/foo/b"; "a//b"]
    ["ab"; "aa/foo/b"; "a/foo/bb"; "afoob"]

(* character classes *)
TEST_UNIT =
  test_glob "[a-z]"
    ["a"; "b"; "c"; "d"; "z"]
    ["."; "A"; ""; "-"; "aa"]

TEST_UNIT =
  test_glob "[!^]"
    ["a"; "!"]
    ["^"]

TEST_UNIT =
  test_glob "[!!]"
    ["a"; "^"]
    ["!"]

(* TEST_UNIT =
  test_glob "[^]"
    ["^"]
    ["a"; "!"; "\\"] *)

TEST_UNIT =
  test_glob "[!a-z-]"
    ["1"; "."]
    ["a"; "c"; "-"]

TEST_UNIT =
  test_glob "[-a-z]"
    ["a"; "c"; "-"]
    ["1"; "."]

TEST_UNIT =
  test_glob "[]!a-z-]"
    ["a"; "c"; "-"; "]"; "!"]
    ["1"; "."; ""]
