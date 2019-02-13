(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

open Common
open Types

type 'a f_t = (float, 'a) M.t -> float -> (float, 'a) M.t

val euler_s :
  f:'a f_t ->
  dt:float->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * float

val midpoint_s :
  f:'a f_t ->
  dt:float->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * float


val rk4_s :
  f:'a f_t ->
  dt:float->
  (float, 'a) M.t ->
  float ->
  (float, 'a) M.t * float

val prepare :
  (f: 'a ->
   dt: float ->
   (float, 'b) M.t ->
   float ->
   (float, 'b) M.t * float) ->
  'a ->
  (float, 'b) M.t ->
  tspec_t ->
  unit ->
  (float, 'b) M.t * (float, 'b) M.t

val adaptive_prepare :
  (dtmax:float ->
   'a ->
   (float, 'b) M.t ->
   float ->
   float ->
   float * (float, 'b) M.t * float * bool) ->
  'a ->
  (float, 'b) M.t ->
  tspec_t ->
  unit ->
  (float, 'b) M.t * (float, 'b) M.t

val rk23_s :
  tol:float ->
  dtmax:float ->
  'a f_t ->
  (float, 'a) M.t ->
  float ->
  float ->
  float * (float, 'a) M.t * float * bool

val rk45_s :
  tol:float ->
  dtmax:float ->
  'a f_t ->
  (float, 'a) M.t ->
  float ->
  float ->
  float * (float, 'a) M.t * float * bool
