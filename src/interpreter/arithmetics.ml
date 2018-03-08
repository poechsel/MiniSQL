open Ast
open AlgebraTypes

let comp_atom a b =
  if a = b then 0 else
  if a < b then -1 else
    1

let comp a b =
  match (a, b) with
  | (Number a), (Number b) -> 
    comp_atom a b
  | (String a), (String b) ->
    comp_atom a b
  | (Number a), (String b) ->
    comp_atom a (int_of_string b)
  | (String a), (Number b) ->
    comp_atom (int_of_string a) b
  | _ -> 0

let rec execute_value expr env =
  match expr with
  | AlgAtom y -> begin
      match y with
      | Attribute y ->
        String (Hashtbl.find env y)
      | _ -> y
    end
  | AlgBinOp(op, r, l) ->
      let fct = match op with
        | Add -> (+)
        | Sub -> (-)
        | Times -> ( * )
        | Div -> (/)
        | _ -> failwith "unexpected"
      in let r = match (execute_value r env) with
        | String x -> int_of_string x
        | Number x -> x
        | _ -> 0
      in let l = match (execute_value l env) with
        | String x -> int_of_string x
        | Number x -> x
        | _ -> 0
      in Number (fct r l)


let alg_expr_of_ast_expr expr = 
  let rec c_cond cond = 
    match cond with
    | AstBinOp(op, a, b) ->
      AlgBinOp(op, c_cond a, c_cond b)
    | AstCompOp(op, a, b) ->
      AlgBinOp(op, c_expr a, c_expr b)
    | _ -> failwith "unexpected type of condition"
  and c_expr expr = 
    match expr with
    | AstExprOp(op, a, b) ->
      AlgBinOp(op, c_expr a, c_expr b)
    | AstAtom a ->
      AlgAtom a
  in c_cond expr

    

let rec execute_filter expr env =
  match expr with
  | AlgBinOp(op, r, l) -> 
    begin match op with
      | And | Or -> 
        let fct = match op with
          | And -> (&&)
          | _ -> (||)
        in 
        fct (execute_filter r env) (execute_filter l env)
      | _ ->
        let fct = match op with
          | Eq -> (=)
          | Leq -> (<=)
          | Geq -> (>=)
          | Lt -> (<)
          | Gt -> (>)
          | _ -> (!=)
        in fct (comp (execute_value r env) (execute_value l env))  0
    end 
  | _ -> failwith "unexpected"
