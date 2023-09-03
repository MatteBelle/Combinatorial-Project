def get_path(successor, n, m):
    paths_per_courier = [[] for _ in range(m)]
    for c in range(1, m+2):
        x = successor[n-1+c]
        while x <= n:
            paths_per_courier[c-1].append(x)
            x = successor[x-1]
    print(paths_per_courier)

# Example usage:
m = 20# number of couriers
n = 143 # number of items
successor = [78, 41, 175, 135, 16, 102, 124, 107, 83, 168, 58, 36, 64, 103, 40, 42, 54, 32, 92, 65, 113, 8, 20, 25, 183, 76, 137, 115, 53, 108, 182, 67, 104, 179, 112, 173, 126, 177, 18, 26, 5, 22, 125, 89, 169, 39, 117, 172, 96, 30, 93, 118, 44, 47, 136, 73, 85, 35, 17, 171, 82, 139, 77, 94, 52, 72, 2, 79, 51, 170, 109, 59, 98, 105, 19, 91, 97, 81, 63, 178, 106, 129, 60, 120, 101, 6, 11, 164, 141, 167, 12, 56, 99, 88, 87, 143, 55, 13, 29, 138, 131, 114, 180, 123, 4, 43, 181, 122, 95, 71, 74, 165, 61, 132, 110, 50, 15, 174, 57, 119, 127, 121, 86, 49, 133, 100, 27, 21, 140, 75, 37, 128, 116, 28, 142, 23, 166, 90, 111, 176, 14, 48, 9, 130, 134, 1, 84, 10, 45, 70, 7, 62, 66, 68, 3, 33, 38, 80, 34, 69, 46, 31, 24, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 144]

get_path(successor, n, m)

