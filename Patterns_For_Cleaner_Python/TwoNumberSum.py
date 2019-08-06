# Write a function, that takes an array and a target number,
# If any two numbers in the array add up to the target Number,
# then the function should return them in a sorted order. If no two
# number sump up, then function should return an empty array.
# Assume there will be at most one pair of numbers summing to the target
# sum.

# I/P: [3,5,-4,8, 11, 1, -1, 6], 10
# O/P: [-1, 11]

def twoNumberSum(array, target):
    for i in range(len(array) - 1):
        firstNum = array[i]
        for j in range(i+1, len(array)):
            secondNum = array[j]
            if firstNum + secondNum == target:
                return sorted(array[firstNum], array[secondNum])
    return []

# Time complexity is O(n^2), Space: O(1)

# We can definitely do something better:


def twoNumberSum(array, target):
    my_map = {}
    for i in range(len(array)-1):
        findNum = target - array[i]
        if findNum in my_map.keys():
            return [min(array[i], findNum), max(array[i], findNum)]
        else:
            my_map[array[i]] = True
    return []

# This gives O(N) time complexity and space complexity

# Can we do this in O(1) space compelxity?

# Hmm, maybe we can sort the array in place in O(NLogN) using Tim sort
# which is the defualt sorting algo from Python.


def twoNumberSum(array, target):
    leftPtr = 0
    rightPtr = len(array) - 1
    array.sort()

    while leftPtr < rightPtr:
        currSum = array[leftPtr] + array[rightPtr]
        if currSum = target:
            return [array[leftPtr], array[rightPtr]]
        elif currSum > target:
            leftPtr += 1
        elif currSum < target:
            rightPtr -= 1
    return []
