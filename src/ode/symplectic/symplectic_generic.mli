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
   ('d, 'e) M.t -> 
   ('d, 'e) M.t -> 
   float -> 
   ('d, 'e) M.t * ('d, 'e) M.t * float) ->
  ('a * 'b -> 'c) ->
  ('d, 'e) M.t * ('d, 'e) M.t ->
  tspec_t -> unit -> float array * ('d, 'e) M.t * ('d, 'e) M.t 
