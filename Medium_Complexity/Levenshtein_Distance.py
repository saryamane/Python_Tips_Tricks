# Given 2 strings str1 and str2, write a function that will return
# the minimum number of edit operations required to make str1 equal
# to str2. The edit operations can be delete, update or insert.or

# For eg. "abc", "yabd" -> returns 2, i.e. insert y and replace c with d.
def levenshtein(str1, str2):
    edits = [[x for x in range(len(str1) + 1)] for y in range(len(str2) + 1)]
    for i in range(1, len(str2) + 1):
        edits[i][0] = edits[i - 1][0] + 1
    for i in range(1, len(str2) + 1):
        for j in range(1, len(str1) + 1):
            if str2[i - 1] == str1[j - 1]:
                edits[i][j] = edits[i - 1][j -1]
            else:
                edits[i][j] = 1 + min(edits[i-1][j -1], edits[i-1][j], edits[i][j-1])
    return edits[-1][-1]


# Space complexity = O(NM), where N = len(str1) and M = len(str2)
# Time complexity = O(NM)

# However, within the space, we can do much better of the order of
# O(min(N, M)), but storing only the 2 rows of data in the 2D array.

# This is a classic problem of dynamic programming.
