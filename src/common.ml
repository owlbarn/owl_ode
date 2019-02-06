open Owl
(* TODO: update implementations of multiple order RK on the line of
 * symplectic.ml *)

type timespan = float * float
(** Representation of a time span. *)  

let steps t0 t1 dt =
  (t1 -. t0)/.dt |> Maths.floor |> int_of_float

let integrate ~step ~tspan:(t0, t1) ~dt y0 =
  let n = Mat.col_num y0 in
  let n_steps = steps t0 t1 dt in
  let ys = Owl.Mat.empty n_steps n in
  let ts = ref [] in
  let t = ref t0 in
  let y = ref y0 in
  for i = 0 to (pred n_steps) do
    if i > 0 then begin
      let y', t' = step !y !t in
      y := y';
      t := t'
    end;
    Mat.set_slice [[i]; []] ys !y;
    ts := !t::!ts;
  done;
  !ts |> List.rev |> Array.of_list,
  ys



let symplectic_integrate ~step ~tspan:(t0, t1) ~dt x0 p0 =
  let n = Mat.col_num x0 in
  assert (n=(Mat.col_num p0));
  let n_steps = steps t0 t1 dt in
  let xs = Owl.Mat.empty n_steps n in
  let ps = Owl.Mat.empty n_steps n in
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
    Mat.set_slice [[i]; []] xs !x;
    Mat.set_slice [[i]; []] ps !p;
    ts := !t::!ts;
  done;
  !ts |> List.rev |> Array.of_list,
  xs, ps 


