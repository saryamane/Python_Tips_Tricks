def threeNumberSum(array, targetSum):
    array.sort()
    triplets = []

    for i in range(len(array) - 2):

        first_idx = i + 1
        second_idx = len(array) - 1

        while first_idx < second_idx:
            currentSum = array[i] + array[first_idx] + array[second_idx]
            if currentSum == targetSum:
                triplets.append([array[i], array[first_idx], array[second_idx]])
                first_idx += 1
                second_idx -= 1
            elif currentSum < targetSum:
                first_idx += 1
            elif currentSum > targetSum:
                second_idx -= 1
    return triplets

# Time complexity: O(N^2)

# Space complexity: O(N)
