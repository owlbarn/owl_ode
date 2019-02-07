open Owl
open Types

type f_t = Mat.mat -> float -> Mat.mat

let euler_s ~(f:f_t) ~dt = fun y0 t0 ->
  let y = Mat.(y0 + (f y0 t0) *$ dt) in
  let t = t0 +. dt in
  y, t

let midpoint_s ~(f:f_t) ~dt = fun y0 t0 ->
  let k1 = Mat.(dt $* (f y0 t0)) in
  let k2 = Mat.(dt $* (f (y0 + k1 *$ 0.5) (t0 +. 0.5 *. dt))) in
  let y = Mat.(y0 + k2) in
  let t = t0 +. dt in
  y, t

let rk4_s ~(f:f_t) ~dt = fun y0 t0 ->
  let k1 = Mat.(dt $* (f y0 t0)) in
  let k2 = Mat.(dt $* (f (y0 + k1 *$ 0.5) (t0 +. 0.5 *. dt))) in
  let k3 = Mat.(dt $* (f (y0 + k2 *$ 0.5) (t0 +. 0.5 *. dt))) in
  let k4 = Mat.(dt $* (f (y0 + k3) (t0 +. dt))) in
  let dy = Mat.((k1 + k2 + k3 + k4) /$ 6.) in
  let y = Mat.(y0 + dy) in
  let t = t0 +. dt in
  y, t



let rk45_s ?(tol=1E-7) f y0 tspec () =
  (* Cash-Karp parameters *)
  let a = [| 0.0; 0.2; 0.3; 0.6; 1.0; 0.875 |] 
  in
  let b = [|[||];
            [|0.2|];
            [|3.0/.40.0; 9.0/.40.0|];
            [|0.3; -.0.9; 1.2|];
            [|-.11.0/.54.0; 2.5; -.70.0/.27.0; 35.0/.27.0|];
            [|1631.0/.55296.0; 175.0/.512.0; 575.0/.13824.0; 44275.0/.110592.0; 253.0/.4096.0|]|] 
  in
  let c  = [|37.0/.378.0; 0.0; 250.0/.621.0; 125.0/.594.0; 0.0; 512.0/.1771.0|]
  in
  let dc = [|c.(0)-.2825.0/.27648.0; c.(1)-.0.0; c.(2)-.18575.0/.48384.0;
             c.(3)-.13525.0/.55296.0; c.(4)-.277.00/.14336.0; c.(5)-.0.25|] 
  in

  let (t0,t1), _ = match tspec with
    | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
    | T2 {tspan; dt} -> tspan, dt 
    | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED 
  in
  let dtmax = (t1 -. t0) /. 128.0 in
  let dt = dtmax /. 4.0 in

  let rec go (ts, ys) (t0:float) y0 dt =
    if t0 >= t1 then (ts, ys)
    else
      let dt = if t0 +. dt > t1 then t1 -. t0 else dt in
      if t0 +. dt <= t0 then failwith "Singular ODE";

      (* Compute k[i] function values. *)
      let k1 = f y0 t0 in
      let k2 = Mat.(f (y0 + k1 *$ (dt *. b.(1).(0))) (t0 +. a.(1) *. dt)) in
      let k3 = Mat.(f (y0 + k1 *$ (dt *. b.(2).(0)) + k2 *$ (dt *. b.(2).(1))) (t0 +. a.(2) *. dt)) in
      let k4 = Mat.(f (y0 + k1 *$ (dt *. b.(3).(0)) + k2 *$ (dt *. b.(3).(1)) + k3 *$ (dt *. b.(3).(2))) (t0 +. a.(3) *. dt)) in
      let k5 = Mat.(f (y0 + k1 *$ (dt *. b.(4).(0)) + k2 *$ (dt *. b.(4).(1)) + k3 *$ (dt *. b.(4).(2)) + k4 *$ (dt *. b.(4).(3))) (t0 +. a.(4) *. dt)) in
      let k6 = Mat.(f (y0 + k1 *$ (dt *. b.(5).(0)) + k2 *$ (dt *. b.(5).(1)) + k3 *$ (dt *. b.(5).(2)) + k4 *$ (dt *. b.(5).(3)) + k5 *$ (dt *. b.(5).(4))) (t0 +. a.(5) *. dt)) in

      (* Estimate current error and current maximum error.*)
      let err = Linalg.D.norm Mat.(dt $* (k1*$dc.(0) + k2*$dc.(1) + k3*$dc.(2) + k4*$dc.(3) + k5*$dc.(4) + k6*$dc.(5))) in
      let err_max = tol *. (max (Linalg.D.norm y0) 1.0) in

      (* Update solution if error is OK *)
      let t = t0 +. dt in
      let y = Mat.(y0 + k1*$c.(0) + k2*$c.(1) + k3*$c.(2) + k4*$c.(3) + k5*$c.(4) + k6*$c.(5)) in

      (* Update step size *)
      let dt = if err > epsilon_float then min dtmax (0.85*.dt*.(err_max/.err)**0.2) else dt in

      if err < err_max then
        go (t::ts, y::ys) t y dt
      else
        go (ts, ys) t0 y0 dt
  in
  let ts, ys = go ([t0], [y0]) t0 y0 dt in
  ts |> List.rev |> Array.of_list,
  ys |> List.rev |> Array.of_list |> Owl.Mat.of_rows


let prepare step f y0 tspec () =
  let tspan, dt = match tspec with
    | T1 {t0; duration; dt} -> (t0, t0+.duration), dt
    | T2 {tspan; dt} -> tspan, dt 
    | T3 _ -> raise Owl_exception.NOT_IMPLEMENTED 
  in
  let step = step ~f ~dt in
  Common.integrate ~step ~tspan ~dt y0

module Euler = struct
  type s = Mat.mat
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = prepare euler_s
end

module Midpoint = struct
  type s = Mat.mat
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = prepare midpoint_s
end

module RK4 = struct
  type s = Mat.mat
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = prepare rk4_s
end






module RK45 = struct
  type s = Mat.mat
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = rk45_s ~tol:1e-7
end
