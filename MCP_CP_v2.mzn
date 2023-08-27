include "globals.mzn";
%VERSION NUMBER: 2 
%To achieve a fair division among drivers, the objective is to minimize the maximum distance travelled by any courier. 

%VARIABLES DEFINITION:
int: m; %m couriers
set of int: COURIERS = 1..m;
int: n; %n items
set of int: ITEMS = 1..n;
array[COURIERS] of int: load_sizes; %Each courier has a load size li
array[ITEMS] of int: sizes; %Each item has a size sj
set of int: DISTRIB_POINTS = 1..n+1;
int: max_path_length = (n-(m-1)+2); 
%Max path length is given by:
%  - the fact that the first and last destination is the origin point (+2)
%  - every courier must have atleast one item -> if one has all the others it has max n-(m-1)items inside
set of int: PATH = 1..max_path_length;
array[DISTRIB_POINTS,DISTRIB_POINTS] of int: distances;
array[COURIERS, PATH] of var 1..n+1: paths; %paths is a matrix containing for each courier its path in the format [n+1,X,X,X,...,n+1]
var int: items_total = sum(ITEMS); %Sum of items (ex. n=7 items_total = 1+2+...+7)
var int: matrix_total = sum(c in COURIERS,p in PATH)(paths[c,p]); %Total sum of all matrix elements
var int: row_empty = (n+1)*max_path_length; %Total sum of a row if each element is n+1
var int: matrix_empty_total = m*row_empty; %Total sum of all matrix elements if it's "empty" -> all elements are equal to n+ 
var int: total_distance = sum(c in COURIERS)(sum(p in 1..(n-(m-1)+1))(distances[paths[c,p],paths[c,p+1]]));
%Sum of all the distances traveled by the couriers 
array[COURIERS] of var int: courier_distances; %Array containing the distance traveled by each courier
var int: obj_func = max(courier_distances); 
%Objective function to minimize, in this case it's the sum of the maximum distance done by one cuorier and the total distance

%CONSTRAINTS DEFINITION:
constraint n>=m;
constraint redundant_constraint(sum(s in ITEMS) (sizes[s]) <= sum(ls in COURIERS) (load_sizes[ls])); %Sum of item sizes cannot be bigger than total load size
constraint redundant_constraint(forall(i in ITEMS)(
    sizes[i] > 0));  %Each item has a size sj
constraint all_different_except(paths[COURIERS,PATH],{n+1}); %Each item is delivered at most by one courier, only n+1 value can be repeated as it's used as a filler element
constraint forall(c in COURIERS) (
   forall(p in 2..(n-(m-1)))(
    if paths[c,p]==n+1 then paths[c,p+1]=n+1 else true endif)); %Put non-filler elements at path start and fill the rest
constraint redundant_constraint(forall(c in COURIERS) (
  paths[c,1] = n+1 /\ paths[c,(n-(m-1)+2)]=n+1)); %First element and last element in path is the origin (n+1)
constraint matrix_total = matrix_empty_total - items_total; %Each item distrib_point must be present in the path matrix
constraint forall(c in COURIERS) (
  sum(p in PATH)(paths[c,p]) < row_empty); %Each courier must deliver atleast one item
constraint forall(c in COURIERS) (
  sum(p in PATH where paths[c,p]<n+1)(sizes[paths[c,p]]) <= load_sizes[c]); %Each courier's items sizes must not excede his load size
constraint forall(c in COURIERS) (courier_distances[c] = sum(p in 1..(n-(m-1)+1))(distances[paths[c,p],paths[c,p+1]])); 
%Each cuourier distance is given by the sum of the single distances between distib_points and origin point
constraint forall(c in COURIERS)(alldifferent_except(paths[c, 1..max_path_length], {n+1}));

solve 
:: seq_search([int_search(paths, dom_w_deg, indomain_min),
               restart_linear(n*n)
              ]) 
minimize obj_func;

%OUTPUT DEFINITION:
output ["Distance done: \(total_distance)\n"];
output ["Single courier distance: \n"] ++ [
    show(courier_distances[c]) ++ "\n" | c in COURIERS
];
output ["Courier paths: \n"] ++ [
    show([paths[c, p] | p in PATH where paths[c, p] < n+1]) ++ "\n" | c in COURIERS
];
output ["PROVA: \n"] ++ [
    show([paths[c, p] | p in PATH]) ++ "\n" | c in COURIERS
];




