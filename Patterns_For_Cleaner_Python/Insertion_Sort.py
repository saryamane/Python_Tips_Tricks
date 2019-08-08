# Insertion sort algorithm

# Not most performant, easy to understand and solve for.
# Create a list in the begining called tentative list.

# space complexity = O(1)
# Time complexity is = O(N^2), best case would be O(N) if the array
# is given to us in the sorted order.


def insertionSort(array):
    for i in range(1, len(array)):
        j = i
        while j > 0 and array[j] < array[j - 1]:
            swap(j, j - 1, array)
            j -= 1
    return array

def swap(i, j, array):
    array[i], array[j] = array[j], array[i]
