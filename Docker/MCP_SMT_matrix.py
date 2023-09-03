from z3 import * # The Z3 Theorem Prover
import numpy as np # Numpy for matrix operations
import sys
import time

# receive instance number from command line argument
instance = sys.argv[1]
# open the file in Instances folder
f = open(f"./../Instances/inst{instance}.dat", "r")
# the first line is the number of couriers
m = int(f.readline())
# the second line is the number of items
n = int(f.readline())
# the third line is the load size of each courier
load_size = [int(x) for x in f.readline().split()]
# the fourth line is the size of each item
item_size = [int(x) for x in f.readline().split()]
# the rest is the distance matrix
distance = []
for i in range(n+1):
    distance.append([int(x) for x in f.readline().split()])
# close the file
f.close()
print("couriers:", m)
print("items:", n)
print("load_size:", load_size)
print("item_size:", item_size)
# output the distance matrix as a numpy array
distance = np.array(distance)
print("distance:\n", distance)
max_path_length = n-(m-1)
paths = [[Int("p_%s_%s" % (i,j)) for j in range(max_path_length)] for i in range(m)] 
# create a matrix of mxn boolean variables for the assignment of items to couriers
assignment = [[Bool("a_%s_%s" % (i,j)) for j in range(n)] for i in range(m)]
# Create a solver instance
s = Solver()
constraints = []
constraints.append(n>=m)

# Each item has a size > 0 and <= max(load size)
for i in range(n):
    constraints.append(And(item_size[i] > 0, item_size[i] <= max(load_size)))

# Each item is delivered at most by one courier, and at least by one courier
for i in range(n):
    constraints.append(Sum([If(paths[c][j] == i, 1, 0) for c in range(m) for j in range(max_path_length)]) == 1)

# assignment constraints 
for c in range(m):
    for i in range(n):
        constraints.append(assignment[c][i] == Or([paths[c][j] == i for j in range(max_path_length)]))

# Each courier can carry at most its load size
for c in range(m):
    constraints.append(Sum([If(assignment[c][i], item_size[i], 0) for i in range(n)]) <= load_size[c])

# Each courier must deliver at least one item
for c in range(m):
    constraints.append(Sum([If(assignment[c][i], 1, 0) for i in range(n)]) >= 1)

best_max_distance = math.inf
s.add(constraints)
courier_distances = [[0] for c in range(m)]
courier_loads = [[0] for c in range(m)]
best_courier_distances = [[0] for c in range(m)]
break_counter = 0
loop_counter = 0
st = time.time()
for l in range(1000):
    if s.check() == sat:
        loop_counter += 1
        model = s.model()
        # get the values of the paths
        paths_values = [[model[paths[i][j]] for j in range(max_path_length)] for i in range(m)]
        # get path for each courier as a list of items, taking only the values in the range [0,n-1]
        paths_items = [[paths_values[i][j].as_long() for j in range(max_path_length) if paths_values[i][j].as_long() < n] for i in range(m)]
        paths_items = [list(filter(lambda x: x != -1, paths_items[i])) for i in range(m)] 
        # get the total distance for each courier by adding also the distance from the depot to the first item and from the last item to the depot
        for c in range(m):
            dist = distance[n][paths_items[c][0]] + distance[paths_items[c][-1]][n]
            for i in range(len(paths_items[c])-1):
                dist += distance[paths_items[c][i]][paths_items[c][i+1]]
            courier_distances[c][0] = dist

        # only accept solutions with max distance < best_max_distance
        # and update best_max_distance
        max_distance = max([courier_distances[c][0] for c in range(m)])
        if max_distance < best_max_distance:
            best_max_distance = max_distance
            break_counter = loop_counter
            best_courier_distances = courier_distances.copy()
            print("max_distance:", max_distance)
            print("paths_items:", paths_items)
            print("courier_distances:", courier_distances)
        else:
            if loop_counter - break_counter > 200:
                break
    else:
        break
et = time.time()
elapsed_time = et - st
print("elapsed_time:", elapsed_time)
