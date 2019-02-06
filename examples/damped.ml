open Owl
open Ode
let damped_noforcing a (xs, ps) _ : Owl.Mat.mat =
  Owl.Mat.(
    xs *$ (-1.0) + ps *$ (-1.0*.a)
  )

let a = 1.0 
let dt = 0.1

let plot_sol fname t sol1 sol2 sol3 =
  let open Owl in
  let h = Plot.create fname in
  let open Plot in
  set_foreground_color h 0 0 0;
  set_background_color h 255 255 255;
  set_title h fname;
  plot ~h ~spec:[ RGB (0,0,255); LineStyle 1 ] t (Mat.col sol1 0);
  plot ~h ~spec:[ RGB (0,255,0); LineStyle 1 ] t (Mat.col sol2 0);
  plot ~h ~spec:[ RGB (255,0,0); LineStyle 1 ] t (Mat.col sol3 0);
  (* XXX: I could not figure out how to make the legend black instead of red *)
  legend_on h ~position:NorthEast [|"Leapfrog"; "Ruth3"; "Symplectic Euler"|];
  output h

module Leapfrog = struct
  type t = Mat.mat * Mat.mat
  type output = float array * Mat.mat * Mat.mat
  let solve = leapfrog 
end

module Ruth3 = struct
  type t = Mat.mat * Mat.mat
  type output = float array * Mat.mat * Mat.mat
  let solve = ruth3
end

module Symplectic_Euler = struct
  type t = Mat.mat * Mat.mat
  type output = float array * Mat.mat * Mat.mat
  let solve = symplectic_euler
end



let () =
  let x0 = Owl.Mat.of_array [|-0.25|] 1 1 in
  let p0 = Owl.Mat.of_array [|0.75|] 1 1 in
  let t0, duration = 0.0, 15.0 in
  let f = damped_noforcing a in
  let tspec = T1 {t0; duration; dt} in
  let t, sol1, _ = odeint (module Leapfrog) f (x0,p0) tspec () in
  let _, sol2, _ = odeint (module Ruth3) f (x0,p0) tspec () in
  let _, sol3, _ = odeint (module Symplectic_Euler) f (x0,p0) tspec () in
  (* XXX: I'd prefer t to be already an Owl array as well *)
  plot_sol "damped.png" (Owl.Mat.of_array t 1 (Array.length t)) sol1 sol2 sol3;
