# Bubble sort algorithm
# Very straightforward to implement in code.
# Merge, Quick and Heap are more complicated.

# Iterate multiple times, and initiate swaps to correct order.
# Check if the curr and curr + 1 are in correct order.
# If sorted, we move on, else we swap their position.

# Eg. [8, 5, 2, 9, 5, 6, 3]

# If swaps were done, then we need to iterate again, else we are done.
# Bubble sort happens in place.

# Space is going to be in place
# Space complexity is O(1)
# Time complexity: worst case is O(N^2), best case is O(N), when given array is sorted.
#


def bubbleSort(array):
    isSorted = False
    counter = 0
    while not isSorted:
        isSorted = True
        for i in range(len(array) - 1 - counter):
            if array[i] > array[i + 1]:
                swap(i, i+1, array)
                isSorted = False
        counter += 1
    return array


def swap(i, j, array):
    array[i], array[j] = array[j], array[i]
