(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

open Common
open Types

type 'a f_t = (float, 'a) M.t -> (float, 'a) M.t -> float -> (float, 'a) M.t

val symplectic_euler_s :
  f:'a f_t ->
  dt:float ->
  (float, 'a) M.t ->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * (float, 'a) M.t * float

val leapfrog_s:
  f:'a f_t ->
  dt:float ->
  (float, 'a) M.t ->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * (float, 'a) M.t * float

val pseudoleapfrog_s:
  f:'a f_t ->
  dt:float ->
  (float, 'a) M.t ->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * (float, 'a) M.t * float

val ruth3_s :
  f:'a f_t ->
  dt:float ->
  (float, 'a) M.t ->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * (float, 'a) M.t * float

val ruth4_s :
  f:'a f_t ->
  dt:float ->
  (float, 'a) M.t ->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * (float, 'a) M.t * float

val prepare:
  (f:('a -> 'b -> 'c) ->
   dt:float ->
   (float, 'd) M.t ->
   (float, 'd) M.t ->
   float ->
   (float, 'd) M.t * (float, 'd) M.t * float) ->
  ('a * 'b -> 'c) ->
  (float, 'd) M.t * (float, 'd) M.t ->
  tspec_t -> unit -> (float, 'd) M.t * (float, 'd) M.t * (float, 'd) M.t
