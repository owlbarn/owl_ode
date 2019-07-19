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

  type f_t = M.arr * M.arr -> float -> M.arr

  module M = struct
    include M

    (* TODO: implement this in owl *)
    let ( *$ ) = M.mul_scalar
    let ( + ) = M.add
  end

  let prepare step f (x0, p0) tspec () =
    let tspan, dt =
      match tspec with
      | T1 { t0; duration; dt } -> (t0, t0 +. duration), dt
      | T2 { tspan; dt } -> tspan, dt
      | T3 _ -> raise Owl_exception.(NOT_IMPLEMENTED "T3 not implemented")
    in
    let step = step f ~dt in
    C.symplectic_integrate ~step ~tspan ~dt (x0, p0)


  let symplectic_euler_s (f : f_t) ~dt (xs, ps) t0 =
    let t = t0 +. dt in
    let fxs = f (xs, ps) t in
    let ps' = M.(ps + (fxs *$ dt)) in
    let xs' = M.(xs + (ps' *$ dt)) in
    (xs', ps'), t


  let symplectic_euler =
    (module struct
      type state = M.arr * M.arr
      type f = M.arr * M.arr -> float -> M.arr
      type step_output = (M.arr * M.arr) * float
      type solve_output = M.arr * M.arr * M.arr

      let step = symplectic_euler_s
      let solve = prepare step
    end : Solver
      with type state = M.arr * M.arr
       and type f = M.arr * M.arr -> float -> M.arr
       and type step_output = (M.arr * M.arr) * float
       and type solve_output = M.arr * M.arr * M.arr)


  let leapfrog_s (f : f_t) ~dt (xs, ps) t0 =
    let t = t0 +. dt in
    let fxs = f (xs, ps) t in
    let xs' = M.(xs + (ps *$ dt) + (fxs *$ (dt *. dt *. 0.5))) in
    let fxs' = f (xs', ps) (t +. dt) in
    let ps' = M.(ps + ((fxs + fxs') *$ (dt *. 0.5))) in
    (xs', ps'), t


  let leapfrog =
    (module struct
      type state = M.arr * M.arr
      type f = M.arr * M.arr -> float -> M.arr
      type step_output = (M.arr * M.arr) * float
      type solve_output = M.arr * M.arr * M.arr

      let step = leapfrog_s
      let solve = prepare step
    end : Solver
      with type state = M.arr * M.arr
       and type f = M.arr * M.arr -> float -> M.arr
       and type step_output = (M.arr * M.arr) * float
       and type solve_output = M.arr * M.arr * M.arr)


  (* For the values used in the implementations below
     see Candy-Rozmus (https://www.sciencedirect.com/science/article/pii/002199919190299Z)
     and https://en.wikipedia.org/wiki/Symplectic_integrator *)
  let symint ~coeffs (f : f_t) ~dt =
    let symint_step ~coeffs f (xs, ps) t dt =
      List.fold_left
        (fun ((xs, ps), t) (ai, bi) ->
          let ps' = M.(ps + (f (xs, ps) t *$ (dt *. bi))) in
          let xs' = M.(xs + (ps' *$ (dt *. ai))) in
          let t = t +. (dt *. ai) in
          (xs', ps'), t)
        ((xs, ps), t)
        coeffs
    in
    fun (xs, ps) t -> symint_step ~coeffs f (xs, ps) t dt


  let leapfrog_c = [ 0.5, 0.0; 0.5, 1.0 ]
  let pseudoleapfrog_c = [ 1.0, 0.5; 0.0, 0.5 ]
  let ruth3_c = [ 2.0 /. 3.0, 7.0 /. 24.0; -2.0 /. 3.0, 0.75; 1.0, -1.0 /. 24.0 ]

  let ruth4_c =
    let c = Owl.Maths.pow 2.0 (1.0 /. 3.0) in
    [ 0.5, 0.0; 0.5 *. (1.0 -. c), 1.0; 0.5 *. (1.0 -. c), -.c; 0.5, 1.0 ]
    |> List.map (fun (v1, v2) -> v1 /. (2.0 -. c), v2 /. (2.0 -. c))


  let _leapfrog_s' f ~dt = symint ~coeffs:leapfrog_c f ~dt
  let pseudoleapfrog_s f ~dt = symint ~coeffs:pseudoleapfrog_c f ~dt

  let pseudoleapfrog =
    (module struct
      type state = M.arr * M.arr
      type f = M.arr * M.arr -> float -> M.arr
      type step_output = (M.arr * M.arr) * float
      type solve_output = M.arr * M.arr * M.arr

      let step = pseudoleapfrog_s
      let solve = prepare step
    end : Solver
      with type state = M.arr * M.arr
       and type f = M.arr * M.arr -> float -> M.arr
       and type step_output = (M.arr * M.arr) * float
       and type solve_output = M.arr * M.arr * M.arr)


  let ruth3_s f ~dt = symint ~coeffs:ruth3_c f ~dt

  let ruth3 =
    (module struct
      type state = M.arr * M.arr
      type f = M.arr * M.arr -> float -> M.arr
      type step_output = (M.arr * M.arr) * float
      type solve_output = M.arr * M.arr * M.arr

      let step = ruth3_s
      let solve = prepare step
    end : Solver
      with type state = M.arr * M.arr
       and type f = M.arr * M.arr -> float -> M.arr
       and type step_output = (M.arr * M.arr) * float
       and type solve_output = M.arr * M.arr * M.arr)


  let ruth4_s f ~dt = symint ~coeffs:ruth4_c f ~dt

  let ruth4 =
    (module struct
      type state = M.arr * M.arr
      type f = M.arr * M.arr -> float -> M.arr
      type step_output = (M.arr * M.arr) * float
      type solve_output = M.arr * M.arr * M.arr

      let step = ruth4_s
      let solve = prepare step
    end : Solver
      with type state = M.arr * M.arr
       and type f = M.arr * M.arr -> float -> M.arr
       and type step_output = (M.arr * M.arr) * float
       and type solve_output = M.arr * M.arr * M.arr)


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

    but http://ocaml.xyz/apidoc/owl_M.arrhs_root.html does not seem
    powerful enough for that in general.
    *)

let leapfrog_implicit ~f y0 (t0, t1) dt =
  let _, elts = M.shape y0 in
  assert (M.s.is_even elts);

  let steps = steps t0 t1 dt in
  let sol = M.empty steps elts in

  sol.${[[0]]}<- y0;
         for idx = 1 to steps-1 do
          (* TODO *)
          ()
         done;
         sol
  *)

  (* ----- helper functions ----- *)

  let to_state_array ?(axis = 0) (dim1, dim2) xs ps =
    let unpack =
      if axis = 0
      then M.to_rows
      else if axis = 1
      then M.to_cols
      else raise Owl_exception.INDEX_OUT_OF_BOUND
    in
    let xs = unpack xs in
    let ps = unpack ps in
    if M.numel xs.(0) <> dim1 * dim2
    then raise Owl_exception.(DIFFERENT_SHAPE ([| M.numel xs.(0) |], [| dim1 * dim2 |]));
    if M.numel ps.(0) <> dim1 * dim2
    then raise Owl_exception.(DIFFERENT_SHAPE ([| M.numel ps.(0) |], [| dim1 * dim2 |]));
    ( Array.map (fun x -> M.reshape x [| dim1; dim2 |]) xs
    , Array.map (fun p -> M.reshape p [| dim1; dim2 |]) ps )
end
