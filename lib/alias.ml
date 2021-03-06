
open Core.Std

(* An [Alias.t] is a user-defined symbolic name which will be associated to a set of build
   dependencies. Similar to a `phony' target in omake/make phony; but with no action *)

module T = struct
  type t = {
    dir : Path.Rel.t;
    name : string;
  } with sexp, bin_io, compare
  let hash = Hashtbl.hash
end

include T
include Hashable.Make(T)

let create ~dir name = { dir; name; }
let split t = t.dir, t.name
let default ~dir = create ~dir "DEFAULT"

let to_string t =
  if Path.Rel.equal t.dir Path.Rel.the_root
  then sprintf ".%s" t.name
  else sprintf "%s/.%s" (Path.Rel.to_string t.dir) t.name

let directory t = t.dir

let create ~dir name =
  match (Path.case dir) with
  | `relative dir -> create ~dir name
  | `absolute _ ->
    failwith "[Alias.create] called with absolute directory"

let default ~dir =
  match (Path.case dir) with
  | `relative dir -> default ~dir
  | `absolute _ ->
    failwith "[Alias.default] called with absolute directory"
