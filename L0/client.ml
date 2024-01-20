open Js_of_ocaml
open Js_of_ocaml.Firebug

module Predefined = struct
  module Expr = struct
    let write = {| var x = 1; write(x)|}
    (* let write_bc = [%blob "1write.bc.json"] *)
  end
(* 
  module Funs = struct
    let fac = [%blob "1append.lama"]
    let fac_bc = [%blob "1append.bc.json"]
  end

  module Other = struct
    let append = [%blob "1append.lama"]
    let append_bc = [%blob "1append.bc.json"]
    let test50arrays = [%blob "test050.lama"]
    let test50arrays_bc = [%blob "test050.bc.json"]
    let test081zip = [%blob "081zip.lama"]
    let test081zip_bc = [%blob "081zip.bc.json"]
  end *)
end

(* let eval_bc_string contents =
  print_endline contents;
  let j = Yojson.Safe.from_string contents in
  let bc = LibSerialize.json_to_bytecode j in
  let rez : int list = SM.run bc [] in
  Format.printf "Result: @[%a@]\n%!" Format.(pp_print_list pp_print_int) rez;
  ()

let __ () = eval_bc_string Predefined.Other.append *)

let () = 
  let open L0 in 
  let ast = 
    match Parser.parse {| 1+x|} with 
    | `Fail _ -> assert false 
    | `Ok ast -> ast
  in 
  print_endline "Parsed";
  let bc = SM.compile ast in 
  Printf.printf "%s\n%!" (GT.show SM.t bc)
(*
module Eval_bc_gui = struct 
  let clear_output_area () =
    (Dom_html.getElementById_exn "output_area")##.textContent := Js.null

  let get_stru_text_exn () =
    Dom_html.getElementById_coerce "input_area" Dom_html.CoerceTo.textarea
    |> Option.get

  let run_clicked () =
    clear_output_area ();
    let textarea = get_stru_text_exn () in
    (* (Dom_html.getElementById_exn "output_area")##.textContent
      := Js.some textarea##.value *)
    let j = Yojson.Safe.from_string (Js.to_string textarea##.value) in
    let bc = LibSerialize.json_to_bytecode j in
    Printf.printf "%s %d\n" __FILE__ __LINE__;
    let rez : int = L0.SM.eval (fun s -> failwith "WTF") [] bc in
    (Dom_html.getElementById_exn "output_area")##.textContent
    := Js.some
      @@ Js.string
            (Format.asprintf "Result: @[%a@]\n%!"
              Format.pp_print_int
              rez)

  let () =
    (Dom_html.getElementById_exn "send1")##.onclick
    := Dom.handler (fun _ ->
          run_clicked ();
          Js._true)

  let () =
    let input_area = Dom_html.createTextarea Dom_html.document in
    input_area##setAttribute (Js.string "id") (Js.string "input_area");
    Dom.appendChild (Dom_html.getElementById_exn "left") input_area

  let () =
    let examples =
      [
         ("write", {|x+1 |});
        (*("append", Predefined.Other.append_bc);
        ("test50array", Predefined.Other.test50arrays_bc);
        ("write", Predefined.Expr.write_bc); *)
      ]
    in
    let _combo =
      Dom_html.getElementById_coerce "demos" Dom_html.CoerceTo.select
      |> Option.get
    in
    List.iter
      (fun (name, _) ->
        _combo##add
          (let g = Dom_html.createOption Dom_html.document in
            g##.label := Js.string name;
            g)
          Js.null)
      examples;
    let on_change () =
      console##log _combo##.selectedIndex;
      let textarea = get_stru_text_exn () in
  
      textarea##.value :=
        Js.string (snd (List.nth examples _combo##.selectedIndex))
    in
    _combo##.onchange :=
      Dom_html.handler (fun _ ->
          on_change ();
          Js._true);
    _combo##.selectedIndex := 0;
    on_change ()
end *)

module Lama2JSON = struct
  let () =
    let input_area = Dom_html.createTextarea Dom_html.document in
    input_area##setAttribute (Js.string "id") (Js.string "input_area_lama2json");
    Dom.appendChild (Dom_html.getElementById_exn "left_lama2json") input_area

  (* let () =
    (Dom_html.getElementById_exn "left_lama2json")##.onclick
    := Dom.handler (fun _ ->
           console##log (Js.string "parse lama here");
           Js._true) *)


  let waiting_output () =
    let out_container = Dom_html.getElementById_exn "output_lama2json" in 
    out_container##.textContent := Js.some (Js.string "waiting...")
          
  let set_output text ast =
    let out_container = (Dom_html.getElementById_exn "output_lama2json") in 
    out_container##.textContent := Js.null;
    let pre =  Dom_html.createPre Dom_html.document in 
    pre##.textContent := Js.some (Js.string text);
    Dom.appendChild out_container pre;
    print_endline "set_output finished"        
  let () =
    let examples =
      [
        ("test1", {|1+1 |});
        ("test2", {|1+2*3 |});
        (* ("zip", Predefined.Other.test081zip);
        ("append", Predefined.Other.append);
        ("test50array", Predefined.Other.test50arrays);
        ("write", Predefined.Expr.write); *)
      ]
    in
    let _combo =
      Dom_html.getElementById_coerce "lamaDemos" Dom_html.CoerceTo.select
      |> Option.get
    in
    List.iter
      (fun (name, code_) ->
        _combo##add
          (let g = Dom_html.createOption Dom_html.document in
           g##.label := Js.string name;
           Printf.printf "option %S created with value %S\n%!" name code_;
           g)
          Js.null)
      examples;
    let on_change () =
      console##log _combo##.selectedIndex;
      let textarea =
        Dom_html.getElementById_coerce "input_area_lama2json"
          Dom_html.CoerceTo.textarea
        |> Option.get
      in

      textarea##.value :=
        Js.string (snd (List.nth examples _combo##.selectedIndex))
    in

    _combo##.onchange :=
      Dom_html.handler (fun _ ->
          on_change ();
          Js._true);
    _combo##.selectedIndex := 0;
    (* on_change (); *)
    ()

  let () =
    (Dom_html.getElementById_exn "lamaToJsonBtn")##.onclick
    := Dom.handler (fun _ ->
           console##log (Js.string "parsing...");
           let contents =
             let textarea =
               Dom_html.getElementById_coerce "input_area_lama2json"
                 Dom_html.CoerceTo.textarea
               |> Option.get
             in
             Js.to_string textarea##.value
           in

           (* let contents = In_channel.with_open_text name In_channel.input_all in *)
           let ast =
             (* let name = "asdf.lama" in *)
             waiting_output ();
             let rez = L0.Parser.parse contents in
             match rez with
             | `Fail s ->
                 Printf.eprintf "Lama Parsing error:\n%s\n%!" s;
                 exit 1
             | `Ok prog -> 
              set_output "parsed" rez;
              prog
           in
           Js._true)
end