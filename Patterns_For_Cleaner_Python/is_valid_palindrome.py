# Given a string, determine if it is a palindrome, considering
# only alphanumeric characters and ignoring cases.

# Note: For the purpose of this problem, we define empty string as
# valid palindrome.

# Example 1:

# Input: "A man, a plan, a canal: Panama"
# Output: true
# Example 2:

# Input: "race a car"
# Output: false


import re
pattern = re.compile("\W+")


class Solution:
    def isPalindrome(self, s: str) -> bool:
        s_new = list(re.sub(pattern, '', s).lower())
        return s_new == s_new[::-1]


sol = Solution()
print(sol.isPalindrome("A man, a plan, a canal: Panama"))
print(sol.isPalindrome("race a car"))
