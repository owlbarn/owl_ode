(* TODO: update implementations of multiple order RK on the line of
 * symplectic.ml *)

(* TODO: find a better place to place this module *)
module M = struct
  include Owl_dense_matrix_generic
  include Owl_operator.Make_Basic (Owl_dense_matrix_generic)
  include Owl_operator.Make_Extend (Owl_dense_matrix_generic)
  include Owl_operator.Make_Matrix (Owl_dense_matrix_generic)
end



let steps t0 t1 dt =
  (* NOTE: switched Float.floor to Maths.floor; 
   * Float module seems not to be only supported in ocaml 4.07.0 *)
  (t1 -. t0)/.dt |> Owl.Maths.floor |> int_of_float

type major =
  | Row
  | Col

let get_major y0 = 
  let dim1, dim2 = M.shape y0 in
  assert ((dim1=1)||(dim2=1));
  if dim1=1 then Row, dim2
  else Col, dim1

let integrate ~step ~tspan:(t0, t1) ~dt y0 =
  let major, n = get_major y0 in
  let n_steps = steps t0 t1 dt in
  let k = M.kind y0 in
  let ys = match major with
    | Row -> M.empty k n_steps n 
    | Col -> M.empty k n n_steps in
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
      | Row -> M.set_slice [[i]; []] ys !y
      | Col -> M.set_slice [[]; [i]] ys !y
    end;
    ts := !t::!ts;
  done;
  !ts |> List.rev |> Array.of_list,
  ys

let symplectic_integrate ~step ~tspan:(t0, t1) ~dt x0 p0 =
  assert ((M.shape x0)=(M.shape p0));
  let major, n = get_major x0 in
  let n_steps = steps t0 t1 dt in
  let k = M.kind x0 in
  let xs, ps = match major with
    | Row -> M.empty k n_steps n, M.empty k n_steps n
    | Col -> M.empty k n n_steps, M.empty k n n_steps in
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
      | Row -> M.set_slice [[i]; []] xs !x; M.set_slice [[i]; []] ps !p
      | Col -> M.set_slice [[]; [i]] xs !x; M.set_slice [[]; [i]] ps !p
    end;
    ts := !t::!ts;
  done;
  !ts |> List.rev |> Array.of_list,
  xs, ps 

let adaptive_integrate ~step ~tspan:(t0, t1) ~dtmax y0 =
  let major, _ = get_major y0 in
  let dt = dtmax /. 4.0 in
  let rec go (ts, ys) (t0:float) y0 dt =
    if t0 >= t1 then (ts, ys)
    else
      let dt = min dt (t1 -. t0) in
      if t0 +. dt <= t0 then failwith "Singular ODE";
      let t, y, dt, err_ok = step y0 t0 dt  in
      if err_ok then
        (* Update solution if error is OK *)
        go (t::ts, y::ys) t y dt
      else
        go (ts, ys) t0 y0 dt
  in
  let ts, ys = go ([t0], [y0]) t0 y0 dt in
  ts |> List.rev |> Array.of_list,
  match major with
  | Row -> ys |> List.rev |> Array.of_list |> M.of_rows
  | Col -> ys |> List.rev |> Array.of_list |> M.of_cols 






