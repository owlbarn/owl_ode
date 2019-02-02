let damped_noforcing a xs ps _ : Owl.Mat.mat=
  Owl.Mat.(
    xs *$ (-1.0) + ps *$ (-1.0*.a)
  )

let a = 1.0 
let dt = 0.1

let plot_sol fname t sol1 sol2 =
  let open Owl in
  let h = Plot.create fname in
  let open Plot in
  set_foreground_color h 0 0 0;
  set_background_color h 255 255 255;
  set_title h fname;
  plot ~h ~spec:[ RGB (0,0,255); LineStyle 1 ] t (Mat.col sol1 0);
  plot ~h ~spec:[ RGB (0,255,0); LineStyle 1 ] t (Mat.col sol2 0);
  (* XXX: I could not figure out how to make the legend black instead of red *)
  legend_on h ~position:NorthEast [|"1st"; "2nd";|];
  output h

let () =
  let y0 = Owl.Mat.of_array [|-0.25; 0.75|] 1 2 in
  let tspan = (0.0, 15.0) in
  let t = Owl.Arr.linspace 0.0 15.0 (int_of_float @@ Float.floor (15.0/.dt)) in
  let sol1 = Ode.Symplectic.leapfrog ~f:(damped_noforcing a) y0 tspan dt in
  let sol2 = Ode.Symplectic.ruth3 ~f:(damped_noforcing a) y0 tspan dt in
  plot_sol "damped.png" t sol1 sol2;
