type timespan = float * float
(** Representation of a time span. *)  

let steps t0 t1 dt =
  (t1 -. t0)/.dt |> Float.floor |> int_of_float

(** Private function, allow to get the slices indexes for xs and ys *)
let slices idx elts =
  [[idx]; [0; elts/2-1]], [[idx]; [elts/2; elts-1]]

(* opening Owl.Mat or Owl.Arr messes up badly all the integer operations *)
let (.${}) = Owl.Mat.(.${})
let (.${}<-) = Owl.Mat.(.${}<-)

let symplectic_euler ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
  for idx = 1 to steps-1 do
    let xi, pi = slices (idx-1) elts in
    let xi', pi' = slices idx elts in
    let xs, ps = sol.${xi}, sol.${pi} in
    let t = t0 +. dt *. (float_of_int idx) in
    let fxs = f xs ps t in
    let ps' = Owl.Mat.(ps + fxs *$ dt) in
    sol.${pi'}<- ps';
    sol.${xi'}<- Owl.Mat.(xs + ps' *$ dt);
  done;
  sol

let leapfrog ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
  for idx = 1 to steps-1 do
    let xi, pi = slices (idx-1) elts in
    let xi', pi' = slices idx elts in
    let xs, ps = sol.${xi}, sol.${pi} in
    let t = t0 +. dt *. (float_of_int idx) in
    let fxs = f xs ps t in
    let xs' = Owl.Mat.(xs + ps *$ dt + fxs *$ (dt*.dt*.0.5)) in
    let fxs' = f xs' ps (t +. dt) in
    sol.${xi'}<- xs';
    sol.${pi'}<- Owl.Mat.(ps + (fxs + fxs') *$ (dt*.0.5));
  done;
  sol

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

(* TODO: impl below is rushed up and definitely broken*)

(* For the values used in the implementations below
   see Candy-Rozmus (https://www.sciencedirect.com/science/article/pii/002199919190299Z)
   and https://en.wikipedia.org/wiki/Symplectic_integrator *)

let symint_step ~coeffs ~f xs ps t dt =
  List.fold_left (fun (xs, ps, t) (ai, bi) ->
      let ps' = Owl.Mat.(ps + (f xs ps t) *$ (dt*.bi)) in
      let xs' = Owl.Mat.(xs + ps' *$ (dt *. ai)) in
      let t = t +. dt*.ai in
      (xs', ps', t))
    (xs, ps, t)
    coeffs

let symint ~coeffs ~f y0 (t0, t1) dt =
  let _, elts = Owl.Mat.shape y0 in
  assert (Owl.Maths.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = Owl.Mat.empty steps elts in

  sol.${[[0]]}<- y0;
  let t = ref t0 in
  for idx = 1 to steps-1 do
    let xi, pi = slices (idx-1) elts in
    let xi', pi' = slices idx elts in
    let xs, ps = sol.${xi}, sol.${pi} in
    let xs', ps', t' = symint_step ~coeffs ~f xs ps !t dt in
    t := t';
    sol.${xi'}<- xs';
    sol.${pi'}<- ps';
  done;
  sol

let cleapfrog = [ (0.5, 0.0); (0.5, 1.0) ]
let cpseudoleapfrog = [ (1.0, 0.5); (0.0, 0.5) ]
let cruth3 = [ (2.0/.3.0, 7.0/.24.0); (-2.0/.3.0, 0.75); (1.0, -1.0/.24.0)]
let cruth4 = let c = Owl.Maths.pow 2.0 (1.0/.3.0) in
  [ (0.5, 0.0); (0.5*.(1.0-.c), 1.0); (0.5*.(1.0-.c), -.c); (0.5, 1.0)]
  |> List.map (fun (v1,v2) -> v1 /. (2.0 -. c), (v2 /. (2.0 -. c)))

let leapfrog' ~f y0 (t0, t1) dt = symint ~coeffs:cleapfrog ~f y0 (t0, t1) dt
let pseudoleapfrog ~f y0 (t0, t1) dt = symint ~coeffs:cpseudoleapfrog ~f y0 (t0, t1) dt
let ruth3 ~f y0 (t0, t1) dt = symint ~coeffs:cruth3 ~f y0 (t0, t1) dt
let ruth4 ~f y0 (t0, t1) dt = symint ~coeffs:cruth4 ~f y0 (t0, t1) dt
