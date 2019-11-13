# Write a function that takes an array of unique integers and returns its powerset.
# For e.g. Powerset of [1,2] is [[],[1],[2],[1,2]] and so on.

# We start with an iterative approach.

def powerset(array):
    subsets = [[]]
    for ele in array:
        for i in range(len(subsets)):
            currentSubset = subsets[i]
            subsets.append(currentSubset + [ele])
    return subsets


print(powerset([1,2,3]))

# Space and Time complexity is O(n*2^n)


# Let's now do a recursive approach to this.

def powersetRecursive(array, idx=None):
    if idx is None:
        idx = len(array) - 1
    elif idx < 0:
        return [[]]

    ele = array[idx]
    subsets = powersetRecursive(array, idx - 1)

    for i in range(len(subsets)):
        currentSubset = subsets[i]
        subsets.append(currentSubset + [ele])
    return subsets


print(powersetRecursive([1,2,3,4]))

# Space and Time complexity for the recurrsive approach is also O(n*2^n)

