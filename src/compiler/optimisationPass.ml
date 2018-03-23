open AlgebraTypes
open Ast

let attributes_of_condition cond =
  let rec aux c acc =
    match c with
    | AlgBinOp(_, a, b) ->
      aux a acc
      |> aux b
    | AlgAtom (Attribute x) ->
      x :: acc
    | _ ->
      acc
  in aux cond [] 
     |> List.sort_uniq Pervasives.compare 


let exclusive_join l1 l2 =
  let rec aux l acc = 
    match l with
    | [] -> acc
    | x::y::tl when x = y -> aux tl (x::acc)
    | x::tl -> aux tl acc
  in 
  let l1 = List.sort_uniq Pervasives.compare l1 in
  let l2 = List.sort_uniq Pervasives.compare l2 in
  let l = List.merge Pervasives.compare l1 l2 in
  aux l []


module SetAttributes = Set.Make (struct
    type t = AlgebraTypes.header
    let compare = Pervasives.compare
  end )

let push_down_select query = 
  let tbl = Hashtbl.create 10 in
  let _ = MetaQuery.get_headers ~f:(fun x y -> Hashtbl.add tbl x y) query in
  let get_headers query =
    Hashtbl.find tbl (MetaQuery.get_uid_from_alg query)
    |> Array.to_list
    |> SetAttributes.of_list 
  in 
  let rec push_down can_be_pushed query =
    let analyze_sub query =
      let header = get_headers query in
      let push, stay =
        can_be_pushed 
        |> List.partition (fun x -> SetAttributes.subset (snd x) header) 
      in stay, push_down push query
    in 
    let to_insert, req = 
      match query with
      | AlgUnion(u, a, b) ->
        let i1, a' = analyze_sub a in 
        let i2, b' = analyze_sub b in
        exclusive_join i1 i2, AlgUnion(u, a', b')

      | AlgMinus(u, a, b) ->
        let i1, a' = analyze_sub a in 
        let i2, b' = analyze_sub b in
        exclusive_join i1 i2, AlgMinus(u, a', b')
      
      | AlgProduct(u, a, b) ->
        let i1, a' = analyze_sub a in 
        let i2, b' = analyze_sub b in
        exclusive_join i1 i2, AlgProduct(u, a', b')
       
      | AlgProjection(u, a, headers) ->
        let i, a' = analyze_sub a in
        i, AlgProjection(u, a', headers)

      | AlgRename(u, a, name) ->
        let i, a' = analyze_sub a in
        i, AlgRename(u, a', name)

      | AlgSelect(u, a, filter) ->
        let attrs = attributes_of_condition filter |> SetAttributes.of_list in
        let a' = push_down ((filter, attrs) :: can_be_pushed) a in
        [], a'

      | AlgInput(u, str) ->
        can_be_pushed, query

    in List.fold_left (fun a (cond, _) -> AlgSelect(AlgebraTypes.new_uid (), a, cond))
         req
         to_insert
  in push_down [] query




(* SELECT compressor *)

let rec select_compressor alg =
  match alg with 
  | AlgSelect(_, AlgSelect(_, sub, e1), e2) ->
    select_compressor (AlgSelect(AlgebraTypes.new_uid(), sub, AlgBinOp(Ast.And, e2, e1)))
  | AlgUnion(u, a, b) ->
    AlgUnion(u, (select_compressor a), (select_compressor b))
  | AlgMinus(u, a, b) ->
    AlgMinus(u, (select_compressor a), (select_compressor b))
  | AlgProduct(u, a, b) ->
    AlgProduct(u, (select_compressor a), (select_compressor b))
  | AlgRename(u, a, b) ->
    AlgRename(u, select_compressor a, b)
  | AlgProjection(u, a, b) ->
    AlgProjection(u, select_compressor a, b)
  | AlgSelect(u, a, b) ->
    AlgSelect(u, select_compressor a, b)
  | AlgInput(u, str) ->
    AlgInput(u, str)


(* Projections optimizer *)
      (*
let insert_projections alg = 
  let tbl = Hashtbl.create 10 in
  let _ = MetaQuery.get_headers ~f:(fun x y -> Hashtbl.add tbl x y) alg in
  let get_headers alg =
    Hashtbl.find tbl (MetaQuery.get_uid_from_alg alg)
    |> Array.to_list
    |> SetAttributes.of_list 
  in 
  let rec aux alg =
    let min_header_end = 
      match alg with
      | AlgProjection(u, a, b) ->

  in aux alg
         *)
