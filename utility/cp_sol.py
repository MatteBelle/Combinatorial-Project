import sys

to_split = sys.argv[1]
# split the string into a list of strings, separated by -
split = to_split.split('-')
# get the number of couriers
obj_val = split[0]
# get the number of cuuriers
m = split[1]
# get the number of nodes
n = split[2]
# get the successor list
successor = split[3]

def get_path(successor, n, m):
    paths_per_courier = [[] for _ in range(m)]
    for c in range(1, m+2):
        x = successor[n-1+c]
        while x <= n:
            paths_per_courier[c-1].append(x)
            x = successor[x-1]
    print(paths_per_courier)

# convert each string to an integer
obj_val = int(obj_val)
m = int(m)
n = int(n)
successor = successor.split('[')[1].split(']')[0].split(',')
successor = [int(x) for x in successor]

get_path(successor, n, m)
