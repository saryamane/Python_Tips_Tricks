# Write a function that takes an array of integers and returns an array
# of all permutations of those integers. If your input array is empty, 
# it should return an empty array as well.

# Example: [1,2,3]
# O/p: [1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2],[3,2,1]

def getPermutations(array):
    permutations = []
    helperPermutation(array,[],permutations) # This helper method will update the permutations array as it finds it recurssively.
    return permutations


def helperPermutation(array, currentPerm, permutations):
    if not len(array) and len(currentPerm):
        permutations.append(currentPerm)
    else:
        for j in range(len(array)):
            newArray = array[:j] + array[j+1:]
            newPerm = currentPerm + [array[j]]
            helperPermutation(newArray, newPerm, permutations)


print(getPermutations([1,2,3,4,5,6]))
