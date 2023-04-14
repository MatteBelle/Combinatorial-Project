int: m; %m couriers
int: n; %n items
constraint n>=m;

array[1..m] of int: load_sizes; %each courier has a load size li
set of int: d_points = 0..n; %each item has a distribution point j
array[1..n] of var int: sizes; %each item has a size sj
constraint forall(i in 1..n)(
    sizes[i] > 0  
    %each item has a size sj
);

array[0..n,0..n] of int: distances;




