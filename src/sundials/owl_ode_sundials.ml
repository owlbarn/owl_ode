open Owl
open Bigarray
open Owl_ode.Types
module C = Owl_ode.Common.Make (Owl_algodiff_primal_ops.D)

let wrap x = reshape_1 x Arr.(numel x)
let unwrap x = genarray_of_array2 (reshape_2 (genarray_of_array1 x) 1 (Array1.dim x))

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


let make_cvode_session
    ~stiff
    ~relative_tol
    ~abs_tol
    (f : Arr.arr -> float -> Arr.arr)
    y0
    t0
  =
  let tolerances = Cvode.(SStolerances (relative_tol, abs_tol)) in
  (* make a copy of y0 so we don't overwrite it*)
  let y0 = Arr.copy y0 in
  let s = Arr.shape y0 in
  (* rhs function that sundials understands *)
  let f_wrapped t y yd =
    let y = unwrap y in
    let y = Arr.reshape y s in
    let dy = f y t in
    Array1.blit (wrap dy) yd
  in
  let y = wrap y0 in
  let yvec = Nvector_serial.wrap y in
  ( (match stiff with
    | false -> Cvode.(init Adams ~nlsolver:(Sundials_NonlinearSolver.FixedPoint.make yvec) tolerances f_wrapped t0 yvec)
    | true -> Cvode.(init BDF ~nlsolver:(Sundials_NonlinearSolver.FixedPoint.make yvec) tolerances f_wrapped t0 yvec))
  , yvec
  , y )


let cvode_s ~stiff ~relative_tol ~abs_tol (f : Arr.arr -> float -> Arr.arr) ~dt y0 t0 =
  let s = Arr.shape y0 in
  let session, yvec, y = make_cvode_session ~stiff ~relative_tol ~abs_tol f y0 t0 in
  let t1 = t0 +. dt in
  let rec until t1 =
    let t', r = Cvode.solve_normal session t1 yvec in
    match r with
    | Success ->
      let y' = Arr.copy (Arr.reshape (unwrap y) s) in
      y', t'
    | StopTimeReached ->
      let y' = Arr.copy (Arr.reshape (unwrap y) s) in
      y', t'
    | RootsFound -> until t1
  in
  until t1


(* stepper that is used for integration so that we don't
   t need to initiate a separate Cvode session each step *)
let cvode_s'
    ~stiff
    ~relative_tol
    ~abs_tol
    (f : Arr.arr -> float -> Arr.arr)
    ~dt
    y0
    t0
    tstop
  =
  let s = Arr.shape y0 in
  let session, yvec, y = make_cvode_session ~stiff ~relative_tol ~abs_tol f y0 t0 in
  Cvode.set_stop_time session tstop;
  fun _y t ->
    let tout = t +. dt in
    let rec until tout =
      let t', r = Cvode.solve_normal session tout yvec in
      match r with
      | Success ->
        let y' = Arr.copy (Arr.reshape (unwrap y) s) in
        y', t'
      | StopTimeReached ->
        let y' = Mat.copy (Arr.reshape (unwrap y) s) in
        y', t'
      | RootsFound -> until tout
    in
    until tout


let cvode ~stiff ~relative_tol ~abs_tol =
  (module struct
    type state = Arr.arr
    type f = Arr.arr -> float -> Arr.arr
    type step_output = Arr.arr * float
    type solve_output = Arr.arr * Arr.arr

    let step = cvode_s ~stiff ~relative_tol ~abs_tol
    let solve = integrate (cvode_s' ~stiff ~relative_tol ~abs_tol)
  end : Solver
    with type state = Arr.arr
     and type f = Arr.arr -> float -> Arr.arr
     and type step_output = Arr.arr * float
     and type solve_output = Arr.arr * Arr.arr)


module Owl_Cvode = struct
  type state = Arr.arr
  type f = Arr.arr -> float -> Arr.arr
  type step_output = Arr.arr * float
  type solve_output = Arr.arr * Arr.arr

  let stiff = false
  let relative_tol = 1E-4
  let abs_tol = 1E-8
  let step = cvode_s ~stiff ~relative_tol ~abs_tol
  let solve = integrate (cvode_s' ~stiff ~relative_tol ~abs_tol)
end

module Owl_Cvode_Stiff = struct
  type state = Arr.arr
  type f = Arr.arr -> float -> Arr.arr
  type step_output = Arr.arr * float
  type solve_output = Arr.arr * Arr.arr

  let stiff = true
  let relative_tol = 1E-4
  let abs_tol = 1E-8
  let step = cvode_s ~stiff ~relative_tol ~abs_tol
  let solve = integrate (cvode_s' ~stiff ~relative_tol ~abs_tol)
end
