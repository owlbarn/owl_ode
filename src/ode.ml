open Owl
open Bigarray

let wrap x = reshape_1 x Mat.(numel x) 

let unwrap (dim1, dim2) x = 
  genarray_of_array2 (reshape_2 (genarray_of_array1 x) dim1 dim2)

let odeint ?(stiff=false) ~f ?(t0=0.) ~y0 =
  let dim1, dim2 = Mat.shape y0 in
  assert ((Mat.shape (f t0 y0)) = (dim1, dim2));
  (* rhs function that sundials understands *)
  let f_wrapped t y yd =
    let y = unwrap (dim1, dim2) y in
    let dy = f t y in
    Array1.blit (wrap dy) yd in
  let y = wrap y0 in
  let yvec = Nvector_serial.wrap y in
  let session = match stiff with
    | false -> Cvode.(init Adams Functional default_tolerances f_wrapped t0 yvec) 
    | true  -> Cvode.(init BDF   Functional default_tolerances f_wrapped t0 yvec) in
  fun ~dt ~duration () ->
    Cvode.set_stop_time session duration;
    let n_steps = int_of_float (duration /. dt) in
    let rec run i tacc yacc = 
      if i < n_steps then begin
        let t = dt *. float i in
        let (t', _) = Cvode.solve_normal session t yvec in
        let y' = Mat.copy (unwrap (dim1, dim2) y) in
        run (succ i) (t'::tacc) (y'::yacc) 
      end else 
        tacc |> List.rev |> Array.of_list,
        yacc |> List.rev |> Array.of_list 
    in run 1 [t0] [y0] 


(* miscellaneous helper functions *)

let print_dim x = 
  let dim1, dim2 = Mat.shape x in 
  Printf.printf "%i, %i\n%!" dim1 dim2


