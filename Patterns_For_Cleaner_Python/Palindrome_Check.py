# Palindrome check:

# Function that takes non-empty string, and returns a boolean, saying
# whether that string is Palindrome or not. Palindrome is defined as a
# string that is written the same forward and backward.

# E.g. "abcdcba" : True

def isPalindrome(string):
    orig_str = list(string)
    rev_str = orig_str[::-1]
    return orig_str == rev_str

# This is O(n) in both time and space complexity.

# Another approach:

# Can you try by recurrsion approach.

def isPalindrome(string, i=0):
    j = length(string) - 1 - i
    return True if i >= j else string[i] == string[j]
    and isPalindrome(string, i+1)

# Good one on the recurrsion technique.

# Can you do O(1) space using iterative array based approach:

def isPalindrome(string):
    leftIdx = 0
    rightIdx = length(string) - 1
    while leftIdx < rightIdx:
        if string[leftIdx] != string[rightIdx]:
            return False
        leftIdx += 1
        rightIdx -= 1
    return True
