def get_path(successor, n, m):
    paths_per_courier = [[] for _ in range(m)]
    for c in range(1, m+2):
        x = successor[n-1+c]
        while x <= n:
            paths_per_courier[c-1].append(x)
            x = successor[x-1]
    print(paths_per_courier)

# Example usage:
m = 3 # number of couriers
n = 7
successor = [6, 11, 7, 2, 4, 13, 12, 5, 3, 1, 9, 10, 8]
get_path(successor, n, m)



