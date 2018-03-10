open AlgebraTypes
open Ast


let string_of_op op = 
  match op with
  | Eq -> "="
  | Neq -> "!="
  | Leq -> "<="
  | Geq -> ">="
  | Lt -> "<"
  | Gt -> ">"
  | And -> "&&"
  | Or -> "||"
  | Add -> "+"
  | Sub -> "-"
  | Times -> "*"
  | Div -> "/"

let string_of_atom atom = 
  match atom with 
  | Attribute x -> string_of_header x
  | Number x -> string_of_int x
  | String s -> "\"" ^ s  ^ "\""

let rec string_of_alg_expr expr = 
  match expr with
  | AlgAtom at -> string_of_atom at
  | AlgBinOp (op, a, b) ->
    Printf.sprintf "(%s %s %s)" (string_of_alg_expr a) (string_of_op op) (string_of_alg_expr b)

let graphviz_instrs_of_algebra alg =
  let uid = ref 0 in
  let node = format_of_string "%d [label = \"%s\"]" in
  let edge = format_of_string "%d -> %d" in
  let edge_label = format_of_string "%d -> %d [label = \"%s\"]" in
  let rec conv_alg alg =
    match alg with
    | AlgUnion(a, b) ->
      let a_lbl, a_str = conv_alg a in
      let b_lbl, b_str = conv_alg b in
      let _ = incr uid in
      !uid, a_str 
            @ b_str 
            @ [Printf.sprintf node !uid "union";
               Printf.sprintf edge !uid a_lbl;
               Printf.sprintf edge !uid b_lbl]

    | AlgProduct(a, b) ->
      let a_lbl, a_str = conv_alg a in
      let b_lbl, b_str = conv_alg b in
      let _ = incr uid in
      !uid, a_str 
            @ b_str 
            @ [Printf.sprintf node !uid "product";
               Printf.sprintf edge !uid a_lbl;
               Printf.sprintf edge !uid b_lbl]

    | AlgInput(name) ->
      let _ = incr uid in
      !uid, [Printf.sprintf node !uid name]

    | AlgProjection(a, headers) ->
      let a_lbl, a_str = conv_alg a in
      let _ = incr uid in
      !uid, a_str 
            @ [Printf.sprintf node !uid "projection";
               Printf.sprintf edge_label !uid a_lbl 
                 (String.concat "; " (List.map string_of_header headers))]


    | AlgSelect(a, expr) ->
      let a_lbl, a_str = conv_alg a in
      let _ = incr uid in
      !uid, a_str 
            @ [Printf.sprintf node !uid "selection";
               Printf.sprintf edge_label !uid a_lbl (string_of_alg_expr expr)]

    | AlgRenameTable (a, name) ->
      let a_lbl, a_str = conv_alg a in
      let _ = incr uid in
      !uid, a_str 
            @ [Printf.sprintf node !uid "rename_table";
               Printf.sprintf edge_label !uid a_lbl name]


  in conv_alg alg


let graphviz_to_file file graphviz_instructions =
  let str = String.concat ";\n" graphviz_instructions in
  let oc = open_out file in
  let _ = Printf.fprintf oc "digraph G{\n%s\n}" str in
  close_out oc


let graphviz_of_algebra file alg = 
  snd (graphviz_instrs_of_algebra alg)
  |> graphviz_to_file file