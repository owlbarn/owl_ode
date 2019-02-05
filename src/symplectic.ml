let symplectic_euler ~f ~tspan ~dt x0 p0 () =
  let step xs ps t0 =
    let t = t0 +. dt in
    let fxs = f xs ps t in
    let ps' = Owl.Mat.(ps + fxs *$ dt) in
    let xs' = Owl.Mat.(xs + ps' *$ dt) in
    xs', ps', t
  in
  Common.symplectic_integrate ~step ~tspan ~dt x0 p0 

let leapfrog ~f ~tspan ~dt x0 p0 () =
  let step xs ps t0 =
    let t = t0 +. dt in
    let fxs = f xs ps t in
    let xs' = Owl.Mat.(xs + ps *$ dt + fxs *$ (dt*.dt*.0.5)) in
    let fxs' = f xs' ps (t +. dt) in
    let ps' = Owl.Mat.(ps + (fxs + fxs') *$ (dt*.0.5)) in
    xs', ps', t
  in
  Common.symplectic_integrate ~step ~tspan ~dt x0 p0 


(* For the values used in the implementations below
   see Candy-Rozmus (https://www.sciencedirect.com/science/article/pii/002199919190299Z)
   and https://en.wikipedia.org/wiki/Symplectic_integrator *)
let symint ~coeffs ~f ~dt ~tspan x0 p0 () =
  let symint_step ~coeffs ~f xs ps t dt =
    List.fold_left (fun (xs, ps, t) (ai, bi) ->
        let ps' = Owl.Mat.(ps + (f xs ps t) *$ (dt*.bi)) in
        let xs' = Owl.Mat.(xs + ps' *$ (dt *. ai)) in
        let t = t +. dt*.ai in
        (xs', ps', t))
      (xs, ps, t)
      coeffs
  in
  let step xs ps t = symint_step ~coeffs ~f xs ps t dt in
  Common.symplectic_integrate ~step ~tspan ~dt x0 p0 

let cleapfrog = [ (0.5, 0.0); (0.5, 1.0) ]
let cpseudoleapfrog = [ (1.0, 0.5); (0.0, 0.5) ]
let cruth3 = [ (2.0/.3.0, 7.0/.24.0); (-2.0/.3.0, 0.75); (1.0, -1.0/.24.0)]
let cruth4 = let c = Owl.Maths.pow 2.0 (1.0/.3.0) in
  [ (0.5, 0.0); (0.5*.(1.0-.c), 1.0); (0.5*.(1.0-.c), -.c); (0.5, 1.0)]
  |> List.map (fun (v1,v2) -> v1 /. (2.0 -. c), (v2 /. (2.0 -. c)))

let leapfrog' ~f ~tspan ~dt x0 p0 = symint ~coeffs:cleapfrog ~f ~tspan ~dt x0 p0 
let pseudoleapfrog ~f ~tspan ~dt x0 p0 = symint ~coeffs:cpseudoleapfrog ~f ~tspan ~dt x0 p0 
let ruth3 ~f ~tspan ~dt x0 p0 = symint ~coeffs:cruth3 ~f ~dt ~tspan x0 p0 
let ruth4 ~f ~tspan ~dt x0 p0 = symint ~coeffs:cruth4 ~f ~dt ~tspan x0 p0 


(*
    (* XXX: 
    We would like to do

        pint = so.fsolve(
            lambda pint: p - pint + 0.5*h*acc(x, pint, t0+i*h),
            p
        )[0]
        xnew = x + h*pint
        pnew = pint + 0.5*h*acc(xnew, pint, t0+(i+1)*h)
        sol[i+1] = np.array((pnew, xnew))

    but http://ocaml.xyz/apidoc/owl_maths_root.html does not seem
    powerful enough for that in general.
    *)

let leapfrog_implicit ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
   for idx = 1 to steps-1 do
    (* TODO *)
    ()
   done;
   sol
*)


