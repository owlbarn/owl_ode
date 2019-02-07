open Owl
open Owl_ode
open Owl_ode.Types

let () = Printexc.record_backtrace true

let tau = 150E-3 
let f = 
  let mu = 10. in
  let lambda = 0.1 in
  fun y _t ->
    let y = Mat.to_array y in
    [|[| y.(1) |]; 
      [| -.y.(0) +. mu *. y.(1) *. (lambda -. Maths.sqr y.(0))|]|]
    |> Mat.of_arrays

let y0 = Mat.of_array [|0.02; 0.03|] 2 1

(* use Ode provided cvode integrator *)
let () = 
  let tspec = T1 {t0=0.0; dt=1E-2; duration=30.0} in
  let ts, ys = Ode.odeint (module Owl_ode_sundials.Owl_Cvode) f y0 tspec () in
  (* save ts and ys *)
  let ts = [| ts |] |> Mat.of_arrays |> Mat.transpose in
  let ys = ys |> Mat.transpose in
  Mat.save_txt Mat.(ts @|| ys) "van_der_pol_dynamics.txt"

(* create our own cvode integrator *)
module Custom_Cvode = struct
  type s = Mat.mat
  type t = Mat.mat
  type output = float array * Mat.mat
  let solve = Owl_ode_sundials.cvode ~stiff:false ~relative_tol:1E-3 ()
end

let () = 
  let tspec = T1 {t0=0.0; dt=1E-2; duration=30.0} in
  let ts, ys = Ode.odeint (module Custom_Cvode) f y0 tspec () in
  (* save ts and ys *)
  let ts = [| ts |] |> Mat.of_arrays |> Mat.transpose in
  let ys = ys |> Mat.transpose in
  Mat.save_txt Mat.(ts @|| ys) "van_der_pol_dynamics_custom.txt";
  let _, ys' = Ode.odeint (module Native.RK4) f y0 tspec () in
  let ys' = Mat.transpose ys' in
  let fname = "vdp.png" in
  let h = Plot.create fname in
  let open Plot in
  set_foreground_color h 0 0 0;
  set_background_color h 255 255 255;
  set_title h fname;
  plot ~h ~spec:[ RGB (0,0,255); LineStyle 1 ] (Mat.col ys 0) (Mat.col ys 1);
  plot ~h ~spec:[ RGB (0,255,0); LineStyle 1 ] (Mat.col ys' 0) (Mat.col ys' 1);
  legend_on h ~position:NorthEast [|"CVode"; "RK4"|];
  output h
