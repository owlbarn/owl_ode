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
   ('b, 'c) M.t ->
   float ->
   ('b, 'c) M.t * float) ->
  'a ->
  ('b, 'c) M.t ->
  tspec_t ->
  unit ->
  float array * ('b, 'c) M.t

val adaptive_prepare : 
  (dtmax:float ->
   'a ->
   ('b, 'c) M.t ->
   float -> 
   float ->
   float * ('b, 'c) M.t * float * bool) ->
  'a ->
  ('b, 'c) M.t ->
  tspec_t ->
  unit ->
  float array * ('b, 'c) M.t

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
