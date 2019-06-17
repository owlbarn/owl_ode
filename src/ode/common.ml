(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

(* TODO: update implementations of multiple order RK on the line of
 * symplectic.ml *)

(* TODO: find a better place to place this module *)

module Make (M : Owl_types_ndarray_algodiff.Sig with type elt = float) = struct
  let steps t0 t1 dt =
    (* NOTE: switched Float.floor to Maths.floor;
     * Float module seems not to be only supported in ocaml 4.07.0 *)
    (t1 -. t0) /. dt |> Owl.Maths.floor |> int_of_float |> succ


  type state_type =
    | Row
    | Col
    | Matrix

  let get_state_t y0 =
    let dims = M.shape y0 in
    let dim1, dim2 = dims.(0), dims.(1) in
    if dim1 = 1 then Row, dim2 else if dim2 = 1 then Col, dim1 else Matrix, dim1 * dim2


  let integrate ~step ~tspan:(t0, t1) ~dt y0 =
    let state_t, n = get_state_t y0 in
    let n_steps = steps t0 t1 dt in
    let ys =
      match state_t with
      | Row -> M.empty [| n_steps; n |]
      | Col -> M.empty [| n; n_steps |]
      | Matrix -> M.empty [| n_steps; n |]
    in
    let ts = ref [] in
    let t = ref t0 in
    let y = ref y0 in
    for i = 0 to pred n_steps do
      if i > 0
      then (
        let y', t' = step !y !t in
        y := y';
        t := t');
      (match state_t with
      | Row -> M.set_slice [ [ i ]; [] ] ys !y
      | Col -> M.set_slice [ []; [ i ] ] ys !y
      | Matrix -> M.set_slice [ [ i ]; [] ] ys M.(reshape !y [| 1; -1 |]));
      ts := !t :: !ts
    done;
    let ts = [| !ts |> List.rev |> Array.of_list |] |> M.of_arrays in
    match state_t with
    | Row | Matrix -> M.(transpose ts), ys
    | Col -> ts, ys


  let symplectic_integrate ~step ~tspan:(t0, t1) ~dt x0 p0 =
    if M.shape x0 <> M.shape p0 then raise Owl_exception.(DIFFERENT_SHAPE ((M.shape x0), (M.shape p0)));
    let state_t, n = get_state_t x0 in
    let n_steps = steps t0 t1 dt in
    let xs, ps =
      match state_t with
      | Row -> M.empty [| n_steps; n |], M.empty [| n_steps; n |]
      | Col -> M.empty [| n; n_steps |], M.empty [| n; n_steps |]
      | Matrix -> M.empty [| n_steps; n |], M.empty [| n_steps; n |]
    in
    let ts = ref [] in
    let t = ref t0 in
    let x = ref x0 in
    let p = ref p0 in
    for i = 0 to pred n_steps do
      if i > 0
      then (
        let x', p', t' = step !x !p !t in
        x := x';
        p := p';
        t := t');
      (match state_t with
      | Row ->
        M.set_slice [ [ i ]; [] ] xs !x;
        M.set_slice [ [ i ]; [] ] ps !p
      | Col ->
        M.set_slice [ []; [ i ] ] xs !x;
        M.set_slice [ []; [ i ] ] ps !p
      | Matrix ->
        M.set_slice [ [ i ]; [] ] xs M.(reshape !x [| 1; -1 |]);
        M.set_slice [ [ i ]; [] ] ps M.(reshape !p [| 1; -1 |]));
      ts := !t :: !ts
    done;
    let ts = [| !ts |> List.rev |> Array.of_list |] |> M.of_arrays in
    match state_t with
    | Row | Matrix -> M.transpose ts, xs, ps
    | Col -> ts, xs, ps


  let adaptive_integrate ~step ~tspan:(t0, t1) ~dtmax y0 =
    let state_t, _ = get_state_t y0 in
    let dt = dtmax /. 4.0 in
    let rec go (ts, ys) (t0 : float) y0 dt =
      if t0 >= t1
      then ts, ys
      else (
        let dt = min dt (t1 -. t0) in
        if t0 +. dt <= t0 then failwith "Singular ODE";
        let t, y, dt, err_ok = step y0 t0 dt in
        if err_ok
        then (* Update solution if error is OK *)
          go (t :: ts, y :: ys) t y dt
        else go (ts, ys) t0 y0 dt)
    in
    let ts, ys = go ([ t0 ], [ y0 ]) t0 y0 dt in
    let ts = [| ts |> List.rev |> Array.of_list |] |> M.of_arrays in
    let ys =
      match state_t with
      | Row -> ys |> List.rev |> Array.of_list |> M.of_rows
      (* TODO: add of_cols to types_ndarray_basic *)
      | Col -> ys |> List.rev |> Array.of_list |> M.of_cols
      | Matrix ->
        ys
        |> List.rev
        |> Array.of_list
        |> Array.map (fun y -> M.reshape y [| 1; -1 |])
        |> M.of_rows
    in
    match state_t with
    | Row | Matrix -> M.transpose ts, ys
    | Col -> ts, ys
end
