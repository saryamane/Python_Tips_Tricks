# Given an input string "abafdxyzabcdcbazyxg"
# Return the longest palindromic substring, which is:
# "xyzabcdcbazyx"


def longestPalindromicSubstring(string):
    currentLongest = [0, 1]
    for i in range(1, len(string)):
        odd = getLongestPalindrome(string, i-1, i+1)
        even = getLongestPalindrome(string, i-1, i)
        currentMax = max(odd, even, key=lambda x: x[1] - x[0])
        currentLongest = max(
            currentMax, currentLongest, key=lambda x: x[1] - x[0]
            )
    return string[currentLongest[0]:currentLongest[1]]

def getLongestPalindrome(string, leftIdx, rightIdx):
    while leftIdx >= 0 and rightIdx < len(string):
        if string[leftIdx] != string[rightIdx]:
            break
        leftIdx -= 1
        rightIdx += 1
    return [leftIdx + 1, rightIdx]
