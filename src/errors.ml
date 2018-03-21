open Lexing

(* small module to format some text *)
module Format = struct
  let green        = 32
  let red          = 31
  let yellow       = 33
  let blue         = 34
  let magenta      = 35
  let cyan         = 36
  let lightgray    = 37
  let darkgray     = 90
  let lightred     = 91
  let lightgreen   = 92
  let lightyellow  = 93
  let lightblue    = 94
  let lightmagenta = 95
  let lightcyan    = 96

  let color_enabled = ref false
  let color color  text = 
    if !color_enabled then
      Printf.sprintf "\027[%dm%s\027[39m" color text
    else  text

  let underline text = 
    Printf.sprintf "\027[4m%s\027[0m" text

end

(* creating all of our errors *)
exception InterpretationError of string
exception ParsingError of string
exception SemanticError of string

(* error of parsing *)
let send_parsing_error infos token = 
  ParsingError 
    (Format.color Format.red "[Parsing Error]" ^ 
     (if infos <> Lexing.dummy_pos then
        Printf.sprintf " %s line %d, character %d : error when seeing token " 
          infos.pos_fname infos.pos_lnum 
          (1 + infos.pos_cnum - infos.pos_bol)
      else "")^ 
     token)
