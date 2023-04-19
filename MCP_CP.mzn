int: m; %m couriers
int: n; %n items
constraint n>=m;
% To achieve a fair division among drivers, the objective is to minimize the maximum distance travelled by any courier. 

array[1..m] of int: load_sizes; %each courier has a load size li
set of int: d_points = 0..n; %each item has a distribution point j
array[1..n] of var int: sizes; %each item has a size sj
constraint forall(i in 1..n)(
    sizes[i] > 0  
    %each item has a size sj
);

array[1..n,1..n] of int: distances;
array[1..m, 1..n] of bool: items_in_courier = array2d(1..m, 1..n, [false | i, j in 1..m]);
constraint forall(c in 1..m) (
    sum(i in 1..n)(items_in_courier[c,i] * sizes[i]) <= load_sizes[c]
    %sum of the sizes of the items present in that courier is less than            
    %or equal to the load size of that courier
); 

array[1..n] of bool: dist_mask = [false| i in 1..n]; 
%mask where 1 is row/column of distance 
%to not take in consideration anymore







