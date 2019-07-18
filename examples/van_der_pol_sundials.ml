open Owl
open Owl_ode
open Owl_ode.Types
open Owl_plplot

let tau = 150E-3

let f =
  let mu = 10. in
  let lambda = 0.1 in
  fun y _t ->
    let y = Mat.to_array y in
    [| [| y.(1); -.y.(0) +. (mu *. y.(1) *. (lambda -. Maths.sqr y.(0))) |] |]
    |> Mat.of_arrays


let y0 = Mat.of_array [| 0.02; 0.03 |] 1 2

let print_dim x =
  let d1, d2 = Mat.shape x in
  Printf.printf "%i, %i\n" d1 d2


(* use Ode provided cvode integrator *)
let () =
  let tspec = T1 { t0 = 0.0; dt = 1E-2; duration = 30.0 } in
  let ts, ys = Ode.odeint (module Owl_ode_sundials.Owl_Cvode) f y0 tspec () in
  (* save ts and ys *)
  Mat.save_txt Mat.(ts @|| ys) "van_der_pol_dynamics.txt"


(*(* create our own cvode integrator *)*)
let () =
  let tspec = T1 { t0 = 0.0; dt = 1E-2; duration = 30.0 } in
  let custom_cvode =
    Owl_ode_sundials.cvode ~stiff:false ~relative_tol:1E-3 ~abs_tol:1E-8
  in
  let ts, ys = Ode.odeint custom_cvode f y0 tspec () in
  (* save ts and ys *)
  Mat.save_txt Mat.(ts @|| ys) "van_der_pol_dynamics_custom.txt";
  let t', ys' = Ode.odeint (module Native.D.RK4) f y0 tspec () in
  let t'', ys'' = Ode.odeint (module Native.D.RK45) f y0 tspec () in
  Printf.printf "RK4: %d; RK45: %d;\n%!" (Mat.row_num t') (Mat.row_num t'');
  let fname = "vdp.png" in
  let h = Plot.create ~n:1 ~m:2 fname in
  let open Plot in
  set_foreground_color h 0 0 0;
  set_background_color h 255 255 255;
  set_title h fname;
  subplot h 0 0;
  plot ~h ~spec:[ RGB (0, 0, 255); LineStyle 1 ] (Mat.col ys 0) (Mat.col ys 1);
  plot ~h ~spec:[ RGB (0, 255, 0); LineStyle 1 ] (Mat.col ys' 0) (Mat.col ys' 1);
  plot ~h ~spec:[ RGB (255, 0, 0); LineStyle 1 ] (Mat.col ys'' 0) (Mat.col ys'' 1);
  legend_on h ~position:NorthEast [| "CVode"; "RK4"; "RK45" |];
  subplot h 1 0;
  plot ~h ~spec:[ RGB (0, 0, 255); LineStyle 1 ] ts Mat.(col ys 1);
  plot ~h ~spec:[ RGB (0, 0, 255); LineStyle 3 ] ts Mat.(col ys 0);
  plot ~h ~spec:[ RGB (0, 255, 0); LineStyle 1 ] t' (Mat.col ys' 1);
  plot ~h ~spec:[ RGB (0, 255, 0); LineStyle 3 ] t' (Mat.col ys' 0);
  plot ~h ~spec:[ RGB (255, 0, 0); LineStyle 1 ] t'' (Mat.col ys'' 1);
  plot ~h ~spec:[ RGB (255, 0, 0); LineStyle 3 ] t'' (Mat.col ys'' 0);
  legend_on h ~position:NorthEast [| "CVode"; "CVode"; "RK4"; "RK4"; "RK45"; "RK45" |];
  output h
