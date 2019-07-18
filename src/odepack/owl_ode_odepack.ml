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


let integrate step f y0 tspec () =
  let (t0, t1), dt =
    match tspec with
    | T1 { t0; duration; dt } -> (t0, t0 +. duration), dt
    | T2 { tspan; dt } -> tspan, dt
    | T3 _ -> raise Owl_exception.(NOT_IMPLEMENTED "T3 not implemented")
  in
  let step = step f ~dt y0 t0 t1 in
  (* TODO: Maybe this kind of checks should go to Common -- with an odeint equivalent
       and be used everywhere. We will just pass the step function to be used in
       the integration loop: that one will take the ~f parameter. *)
  C.integrate ~step ~dt ~tspan:(t0, t1) y0


let lsoda_s ~relative_tol ~abs_tol (f : Mat.mat -> float -> Mat.mat) ~dt y0 t0
    : Mat.mat * float
  =
  let dim1, dim2 = Mat.shape y0 in
  let t1 = t0 +. dt in
  let until t1 =
    let y0 = Bigarray.Array1.change_layout (wrap y0) Bigarray.fortran_layout in
    let y' =
      Odepack.(
        vec @@ lsoda ~rtol:relative_tol ~atol:abs_tol (fwrap (dim1, dim2) f) y0 t0 t1)
    in
    (*Mat.copy @@ *)
    unwrap (dim1, dim2) (Bigarray.Array1.change_layout y' Bigarray.c_layout)
  in
  until t1, t1


let lsoda_s' ~relative_tol ~abs_tol (f : Mat.mat -> float -> Mat.mat) ~dt y0 t0 _tstop
    : Mat.mat -> float -> Mat.mat * float
  =
 fun _y t ->
  let dim1, dim2 = Mat.shape y0 in
  let tout = t +. dt in
  let until tout =
    let y0 = Bigarray.Array1.change_layout (wrap y0) Bigarray.fortran_layout in
    let y' =
      Odepack.(
        vec @@ lsoda ~rtol:relative_tol ~atol:abs_tol (fwrap (dim1, dim2) f) y0 t0 tout)
    in
    (*Mat.copy @@ *)
    unwrap (dim1, dim2) (Bigarray.Array1.change_layout y' Bigarray.c_layout)
  in
  until tout, tout


let lsoda ~relative_tol ~abs_tol =
  (module struct
    type state = Mat.mat
    type f = Mat.mat -> float -> Mat.mat
    type step_output = Mat.mat * float
    type solve_output = Mat.mat * Mat.mat

    let step = lsoda_s ~relative_tol ~abs_tol
    let solve = integrate (lsoda_s' ~relative_tol ~abs_tol)
  end : Solver
    with type state = Owl.Mat.mat
     and type f = Owl.Mat.mat -> float -> Owl.Mat.mat
     and type step_output = Owl.Mat.mat * float
     and type solve_output = Owl.Mat.mat * Owl.Mat.mat)


module Owl_Lsoda = struct
  type state = Mat.mat
  type f = Mat.mat -> float -> Mat.mat
  type step_output = Mat.mat * float
  type solve_output = Mat.mat * Mat.mat

  let relative_tol = 1E-6
  let abs_tol = 1E-6
  let step = lsoda_s ~relative_tol ~abs_tol
  let solve = integrate (lsoda_s' ~relative_tol ~abs_tol)
end
