# Question, given an array, return the 3 largest numbers in the form of
# a sorted array.

# Sample input: [10, 5, 9, 10, 12]
# Return: [10, 10, 12]


# def findThreeLargestNumbers(array):
#     threeLargest = [None, None, None]
#     for val in array:
#         updateThreeLargest(threeLargest, val)
#     return threeLargest


# def updateThreeLargest(threeLargest, val):
#     if threeLargest[2] is None or val > threeLargest[2]:
#         handleUpdate(threeLargest, val, 2)
#     elif threeLargest[1] is None or val > threeLargest[1]:
#         handleUpdate(threeLargest, val, 1)
#     elif threeLargest[0] is None or val > threeLargest[0]:
#         handleUpdate(threeLargest, val, 0)


# def handleUpdate(threeLargest, val, idx):
#     for i in range(idx + 1):
#         if idx == i:
#             threeLargest[idx] = val
#         else:
#             threeLargest[i] = threeLargest[i + 1]


# New practise code:

def findThreeLargest(array):
    threeLargest = [None, None, None]
    for val in array:
        updateThreeLargest(threeLargest, val)
    return threeLargest


def updateThreeLargest(threeLargest, val):
    if threeLargest[2] is None or val > threeLargest[2]:
        handleUpdate(threeLargest, val, 2)
    elif threeLargest[1] is None or val > threeLargest[1]:
        handleUpdate(threeLargest, val, 1)
    elif threeLargest[0] is None or val > threeLargest[0]:
        handleUpdate(threeLargest, val, 0)


def handleUpdate(threeLargest, val, idx):
    for i in range(idx + 1):
        if i == idx:
            threeLargest[idx] = val
        else:
            threeLargest[i] = threeLargest[i + 1]

# Try out the code:

print(findThreeLargest([10, 5, 9, 10, 12]))
