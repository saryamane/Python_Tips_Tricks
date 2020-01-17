# All time favorite, it is very simple with sorting it and then
# arranging all the numbers of the list. However the catch here is
# to do it in O(N) time and O(1) space complexity.

# Given a list of numbers, and the number to move. Move that number
# to the very end of the list.

# For e.g.
# i/p list: [1,2,2,3,2,4,2,2,2]
# number_to_move = 2
# o/p list: [1,3,4,2,2,2,2,2,2]
# Here the number 1,3 and 4 can be present in any order

# Solution:

def moveElementToEnd(array, toMove):
    i = 0
    j = len(array) - 1
    while i < j:
        while i < j and array[j] == toMove:
            j -= 1
        if array[i] == toMove:
            # swap the elements
            array[i], array[j] = array[j], array[i]
        i += 1
    return array
