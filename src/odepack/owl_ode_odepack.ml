open Owl
open Bigarray
open Owl_ode.Types
module C = Owl_ode.Common.Make (Owl_dense_ndarray.D)

let wrap x = reshape_1 x Mat.(numel x)

let unwrap (dim1, dim2) x =
  genarray_of_array2 (reshape_2 (genarray_of_array1 x) dim1 dim2)


let fwrap dims (f : Owl.Mat.mat -> float -> Owl.Mat.mat)
    : float -> Odepack.vec -> Odepack.vec -> unit
  =
 fun t y y' ->
  let y = Bigarray.Array1.change_layout y Bigarray.c_layout |> unwrap dims in
  let temp =
    f y t |> wrap |> fun y -> Bigarray.Array1.change_layout y Bigarray.fortran_layout
  in
  Bigarray.Array1.blit temp y'


let lsoda_i ~relative_tol ~abs_tol f y0 tspec () =
  let (t0, t1), dt =
    match tspec with
    | T1 { t0; duration; dt } -> (t0, t0 +. duration), dt
    | T2 { tspan; dt } -> tspan, dt
    | T3 _ -> raise Owl_exception.(NOT_IMPLEMENTED "T3 not implemented")
  in
  let state_t, n = C.get_state_t y0 in
  let n_steps = C.steps t0 t1 dt in
  let ys =
    match state_t with
    | Row -> Mat.empty n_steps n
    | Col -> Mat.empty n n_steps
    | Matrix -> Mat.empty n_steps n
  in
  let ts = ref [] in
  let t = ref t0 in
  let y = ref y0 in
  let dim1, dim2 = Mat.shape y0 in
  let y0 = Bigarray.Array1.change_layout (wrap @@ Mat.copy y0) Bigarray.fortran_layout in
  let ode =
    Odepack.lsoda ~rtol:relative_tol ~atol:abs_tol (fwrap (dim1, dim2) f) y0 t0 t0
  in
  let step ode t =
    let () = Odepack.advance ~time:t ode in
    let y' = Odepack.vec ode in
    let t' = Odepack.time ode in
    unwrap (dim1, dim2) (Bigarray.Array1.change_layout y' Bigarray.c_layout), t'
  in
  for i = 0 to pred n_steps do
    if i > 0
    then (
      let y', t' = step ode (!t +. dt) in
      y := y';
      t := t');
    (match state_t with
    | Row -> Mat.set_slice [ [ i ]; [] ] ys !y
    | Col -> Mat.set_slice [ []; [ i ] ] ys !y
    | Matrix -> Mat.set_slice [ [ i ]; [] ] ys Mat.(reshape !y [| 1; -1 |]));
    ts := !t :: !ts
  done;
  let ts = [| !ts |> List.rev |> Array.of_list |] |> Mat.of_arrays in
  match state_t with
  | Row | Matrix -> Mat.(transpose ts), ys
  | Col -> ts, ys


let lsoda_s ~relative_tol ~abs_tol (f : Mat.mat -> float -> Mat.mat) ~dt y0 t0
    : Mat.mat * float
  =
  let dim1, dim2 = Mat.shape y0 in
  let t1 = t0 +. dt in
  let y0 = Bigarray.Array1.change_layout (wrap y0) Bigarray.fortran_layout in
  let y' =
    Odepack.(
      vec @@ lsoda ~rtol:relative_tol ~atol:abs_tol (fwrap (dim1, dim2) f) y0 t0 t1)
  in
  (*Mat.copy @@ *)
  unwrap (dim1, dim2) (Bigarray.Array1.change_layout y' Bigarray.c_layout), t1


let lsoda ~relative_tol ~abs_tol =
  (module struct
    type state = Mat.mat
    type f = Mat.mat -> float -> Mat.mat
    type step_output = Mat.mat * float
    type solve_output = Mat.mat * Mat.mat

    let step = lsoda_s ~relative_tol ~abs_tol
    let solve = lsoda_i ~relative_tol ~abs_tol
  end : Solver
    with type state = Owl.Mat.mat
     and type f = Owl.Mat.mat -> float -> Owl.Mat.mat
     and type step_output = Owl.Mat.mat * float
     and type solve_output = Owl.Mat.mat * Owl.Mat.mat)


module Lsoda = struct
  type state = Mat.mat
  type f = Mat.mat -> float -> Mat.mat
  type step_output = Mat.mat * float
  type solve_output = Mat.mat * Mat.mat

  let relative_tol = 1E-6
  let abs_tol = 1E-6
  let step = lsoda_s ~relative_tol ~abs_tol
  let solve = lsoda_i ~relative_tol ~abs_tol
end
