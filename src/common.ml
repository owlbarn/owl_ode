open Owl
(* TODO: update implementations of multiple order RK on the line of
 * symplectic.ml *)

type timespan = float * float
(** Representation of a time span. *)  

let steps t0 t1 dt =
  (* NOTE: switched Float.floor to Maths.floor; 
   * Float module seems not to be only supported in ocaml 4.07.0 *)
  (t1 -. t0)/.dt |> Maths.floor |> int_of_float

type major =
  | Row
  | Col

let get_major y0 = 
  let dim1, dim2 = Mat.shape y0 in
  assert ((dim1=1)||(dim2=1));
  if dim1=1 then Row, dim2
  else Col, dim1

let integrate ~step ~tspan:(t0, t1) ~dt y0 =
  let major, n = get_major y0 in
  let n_steps = steps t0 t1 dt in
  let ys = match major with
    | Row -> Owl.Mat.empty n_steps n 
    | Col -> Owl.Mat.empty n n_steps in
  let ts = ref [] in
  let t = ref t0 in
  let y = ref y0 in
  for i = 0 to (pred n_steps) do
    if i > 0 then begin
      let y', t' = step !y !t in
      y := y';
      t := t'
    end;
    begin match major with
      | Row -> Mat.set_slice [[i]; []] ys !y
      | Col -> Mat.set_slice [[]; [i]] ys !y
    end;
    ts := !t::!ts;
  done;
  !ts |> List.rev |> Array.of_list,
  ys



let symplectic_integrate ~step ~tspan:(t0, t1) ~dt x0 p0 =
  assert ((Mat.shape x0)=(Mat.shape p0));
  let major, n = get_major x0 in
  let n_steps = steps t0 t1 dt in
  let xs, ps = match major with
    | Row -> Mat.empty n_steps n, Mat.empty n_steps n
    | Col -> Mat.empty n n_steps, Mat.empty n n_steps in
  let ts = ref [] in
  let t = ref t0 in
  let x = ref x0 in
  let p = ref p0 in
  for i = 0 to (pred n_steps) do
    if i > 0 then begin
      let x', p', t' = step !x !p !t in
      x := x';
      p := p';
      t := t'
    end;
    begin match major with
      | Row -> Mat.set_slice [[i]; []] xs !x; Mat.set_slice [[i]; []] ps !p
      | Col -> Mat.set_slice [[]; [i]] xs !x; Mat.set_slice [[]; [i]] ps !p
    end;
    ts := !t::!ts;
  done;
  !ts |> List.rev |> Array.of_list,
  xs, ps 


