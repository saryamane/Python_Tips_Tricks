# # Given a sorted array, find the given number, using binary search,
# # and return the index of the number if found, else -1 if not found.

# def binary_Search(array, num):
#     leftPtr = 0
#     rightPtr = len(array) - 1
#     middlePtr = (leftPtr + rightPtr) // 2
#     while leftPtr <= rightPtr:
#         if array[middlePtr] < num:
#             rightPtr = middlePtr - 1
#             middlePtr = (leftPtr + rightPtr) // 2
#         elif array[middlePtr] > num:
#             leftPtr = middlePtr + 1
#             middlePtr = (leftPtr + rightPtr) // 2
#         else:
#             return middlePtr
#     return -1

# # O(logN) -> Time complexity, eliminate half input everytime we traverse.
# # O(1) -> Space complexity (Iterative)
# # O(N) -> Space when implemented recursively.


# def binarySearch(array, target):
#     return binarySearchHelper(array, target, 0, len(array)-1)


# def binarySearchHelper(array, target, left, right):
#     if left > right:
#         return -1

#     middle = (left + right) // 2
#     potentialMatch = array[middle]

#     if target == potentialMatch:
#         return middle
#     elif target < potentialMatch:
#         binarySearchHelper(array, target, left, middle - 1)
#     else:
#         binarySearchHelper(array, target, middle + 1, right)

# # Let's do an iterative method to solve this binary search problem.


# def binarySearch(array, target):
#     left = 0
#     right = len(array) - 1

#     while left <= right:
#         middle = (left + right) // 2
#         potentialMatch = array[middle]

#         if target == potentialMatch:
#             return middle
#         elif target < potentialMatch:
#             right = middle - 1
#         else:
#             left = middle + 1
#     return -1

# # Practise code:

# def binarySearch(array, target):
#     leftPtr = 0
#     rightPtr = len(array) - 1

#     while leftPtr <= rightPtr:
#         middle = (leftPtr + rightPtr) // 2
#         potentialMatch = array[middle]

#         if target == potentialMatch:
#             return middle
#         elif target > potentialMatch:
#             leftPtr = middle + 1
#         elif target < potentialMatch:
#             rightPtr = middle - 1
#     return -1


# Let's practise a recursive solution to this.

def binarySearch(array, target):
    print("I/p array is:", array)
    print("Target is:", target)
    return binarySearchHelper(array, target, 0, len(array) - 1)


def binarySearchHelper(array, target, left, right):
    if left > right:
        return -1
    
    middle = (left + right) // 2
    print("My middle value is :", middle)
    match = array[middle]
    print(match)

    if str(match) == str(target):
        print('Not matching, with middle value:', middle)
        return int(middle)
    elif target > match:
        print('target is greater')
        binarySearchHelper(array, target, middle + 1, right)
    elif target < match:
        print('target is less')
        binarySearchHelper(array, target, left, middle - 1)


print(binarySearch([1,2,3,111],111))
