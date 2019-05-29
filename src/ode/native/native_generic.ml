(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

open Types

module Make (M : Owl_types_ndarray_algodiff.Sig with type elt = float) = struct
  module C = Common.Make (M)

  type f_t = M.arr -> float -> M.arr

  module M = struct
    include M

    (* TODO: implement this in owl *)
    let ( $* ) = M.scalar_mul
    let ( *$ ) = M.mul_scalar
    let ( /$ ) = M.div_scalar
    let ( + ) = M.add
  end

  let euler_s ~(f : f_t) ~dt y0 t0 =
    let y = M.(y0 + (f y0 t0 *$ dt)) in
    let t = t0 +. dt in
    y, t


  let midpoint_s ~(f : f_t) ~dt y0 t0 =
    let k1 = M.(dt $* f y0 t0) in
    let k2 = M.(dt $* f (y0 + (k1 *$ 0.5)) (t0 +. (0.5 *. dt))) in
    let y = M.(y0 + k2) in
    let t = t0 +. dt in
    y, t


  let rk4_s ~(f : f_t) ~dt y0 t0 =
    let k1 = M.(dt $* f y0 t0) in
    let k2 = M.(dt $* f (y0 + (k1 *$ 0.5)) (t0 +. (0.5 *. dt))) in
    let k3 = M.(dt $* f (y0 + (k2 *$ 0.5)) (t0 +. (0.5 *. dt))) in
    let k4 = M.(dt $* f (y0 + k3) (t0 +. dt)) in
    let dy = M.((k1 + (2. $* k2) + (2. $* k3) + k4) /$ 6.) in
    let y = M.(y0 + dy) in
    let t = t0 +. dt in
    y, t


  let rk23_s ~tol ~dtmax f =
    (* Bogacki-Shampine parameters *)
    let a = [| 0.0; 0.5; 0.75 |] in
    let b = [| [||]; [| 0.5 |]; [| 0.0; 3.0 /. 4.0 |] |] in
    let c = [| 2.0 /. 9.0; 1.0 /. 3.0; 4.0 /. 9.0 |] in
    let dc =
      [| c.(0) -. (7.0 /. 24.0)
       ; c.(1) -. (1.0 /. 4.0)
       ; c.(2) -. (1.0 /. 3.0)
       ; -1.0 /. 8.0
      |]
    in
    fun y0 t0 dt ->
      (* Compute k_i function values. *)
      let k1 = f y0 t0 in
      let k2 = M.(f (y0 + (k1 *$ (dt *. b.(1).(0)))) (t0 +. (a.(1) *. dt))) in
      let k3 = M.(f (y0 + (k2 *$ (dt *. b.(2).(1)))) (t0 +. (a.(2) *. dt))) in
      let t = t0 +. dt in
      let y =
        M.(y0 + (k1 *$ (dt *. c.(0))) + (k2 *$ (dt *. c.(1))) + (k3 *$ (dt *. c.(2))))
      in
      let k4 = f y t in
      (* Estimate current error and current maximum error.*)
      let err =
        M.l1norm'
          M.(dt $* (k1 *$ dc.(0)) + (k2 *$ dc.(1)) + (k3 *$ dc.(2)) + (k4 *$ dc.(3)))
      in
      let err_max = tol *. max (M.l1norm' y0) 1.0 in
      (* Update step size *)
      let dt =
        if err > 0. then min dtmax (0.85 *. dt *. ((err_max /. err) ** 0.2)) else dt
      in
      t, y, dt, err <= err_max


  let rk45_s ~tol ~dtmax f =
    (* Cash-Karp parameters *)
    let a = [| 0.0; 0.2; 0.3; 0.6; 1.0; 0.875 |] in
    let b =
      [| [||]
       ; [| 0.2 |]
       ; [| 3.0 /. 40.0; 9.0 /. 40.0 |]
       ; [| 0.3; -0.9; 1.2 |]
       ; [| -11.0 /. 54.0; 2.5; -70.0 /. 27.0; 35.0 /. 27.0 |]
       ; [| 1631.0 /. 55296.0
          ; 175.0 /. 512.0
          ; 575.0 /. 13824.0
          ; 44275.0 /. 110592.0
          ; 253.0 /. 4096.0
         |]
      |]
    in
    let c =
      [| 37.0 /. 378.0; 0.0; 250.0 /. 621.0; 125.0 /. 594.0; 0.0; 512.0 /. 1771.0 |]
    in
    let dc =
      [| c.(0) -. (2825.0 /. 27648.0)
       ; c.(1) -. 0.0
       ; c.(2) -. (18575.0 /. 48384.0)
       ; c.(3) -. (13525.0 /. 55296.0)
       ; c.(4) -. (277.00 /. 14336.0)
       ; c.(5) -. 0.25
      |]
    in
    fun y0 t0 dt ->
      (* Compute k_i function values. *)
      let k1 = f y0 t0 in
      let k2 = M.(f (y0 + (k1 *$ (dt *. b.(1).(0)))) (t0 +. (a.(1) *. dt))) in
      let k3 =
        M.(
          f
            (y0 + (k1 *$ (dt *. b.(2).(0))) + (k2 *$ (dt *. b.(2).(1))))
            (t0 +. (a.(2) *. dt)))
      in
      let k4 =
        M.(
          f
            (y0
            + (k1 *$ (dt *. b.(3).(0)))
            + (k2 *$ (dt *. b.(3).(1)))
            + (k3 *$ (dt *. b.(3).(2))))
            (t0 +. (a.(3) *. dt)))
      in
      let k5 =
        M.(
          f
            (y0
            + (k1 *$ (dt *. b.(4).(0)))
            + (k2 *$ (dt *. b.(4).(1)))
            + (k3 *$ (dt *. b.(4).(2)))
            + (k4 *$ (dt *. b.(4).(3))))
            (t0 +. (a.(4) *. dt)))
      in
      let k6 =
        M.(
          f
            (y0
            + (k1 *$ (dt *. b.(5).(0)))
            + (k2 *$ (dt *. b.(5).(1)))
            + (k3 *$ (dt *. b.(5).(2)))
            + (k4 *$ (dt *. b.(5).(3)))
            + (k5 *$ (dt *. b.(5).(4))))
            (t0 +. (a.(5) *. dt)))
      in
      (* Estimate current error and current maximum error.*)
      let err =
        M.l1norm'
          M.(
            dt
            $* (k1 *$ dc.(0))
               + (k2 *$ dc.(1))
               + (k3 *$ dc.(2))
               + (k4 *$ dc.(3))
               + (k5 *$ dc.(4))
               + (k6 *$ dc.(5)))
      in
      let err_max = tol *. max (M.l1norm' y0) 1.0 in
      (* Update step size *)
      let dt =
        if err > 0. then min dtmax (0.85 *. dt *. ((err_max /. err) ** 0.2)) else dt
      in
      let t = t0 +. dt in
      let y =
        M.(
          y0
          + (k1 *$ (dt *. c.(0)))
          + (k2 *$ (dt *. c.(1)))
          + (k3 *$ (dt *. c.(2)))
          + (k4 *$ (dt *. c.(3)))
          + (k5 *$ (dt *. c.(4)))
          + (k6 *$ (dt *. c.(5))))
      in
      t, y, dt, err <= err_max


  let prepare step f y0 tspec () =
    let tspan, dt =
      match tspec with
      | T1 { t0; duration; dt } -> (t0, t0 +. duration), dt
      | T2 { tspan; dt } -> tspan, dt
      | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED
    in
    let step = step ~f ~dt in
    C.integrate ~step ~tspan ~dt y0


  let adaptive_prepare step f y0 tspec () =
    let (t0, t1), _dt =
      match tspec with
      | T1 { t0; duration; dt } -> (t0, t0 +. duration), dt
      | T2 { tspan; dt } -> tspan, dt
      | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED
    in
    let dtmax = (t1 -. t0) /. 128.0 in
    let step = step ~dtmax f in
    C.adaptive_integrate ~step ~tspan:(t0, t1) ~dtmax y0


  (* ----- helper functions ----- *)

  let to_state_array ?(axis = 0) (dim1, dim2) ys =
    let unpack =
      if axis = 0
      then M.to_rows (* TODO: add to_cols to types_ndarray_basic *)
      else if axis = 1
      then M.to_cols
      else raise Owl_exception.INDEX_OUT_OF_BOUND
    in
    let ys = unpack ys in
    if M.numel ys.(0) <> dim1 * dim2 then raise Owl_exception.DIFFERENT_SHAPE;
    Array.map (fun y -> M.reshape y [| dim1; dim2 |]) ys
end
