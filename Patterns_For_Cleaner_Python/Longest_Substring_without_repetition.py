# Longest Substring Without Repeating Characters

# Given a string, find the length of the longest substring without repeating characters.

# Working Example 1:

# start = 5
# max_length = 3
# {a: 3,
# b: 7,
# c: 5
# }

# Input: "abcabcbb"
# Output: 3
# Explanation: The answer is "abc", with the length of 3.
# Example 2:

# Input: "bbbbb"
# Output: 1
# Explanation: The answer is "b", with the length of 1.
# Working Example 3:

# start = 3
# max_length = 3
# {p: 0,
# w: 5,
# k: 3,
# e: 4
# }

# Input: "pwwkew"
# Output: 3
# Explanation: The answer is "wke", with the length of 3.
#              Note that the answer must be a substring, "pwke" is a subsequence and not a substring.


class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        usedchar = {}
        max_length, start = 0
        for i, c in enumerate(s):
            if c in usedchar and start <= usedchar[c]:
                start = usedchar[c] + 1
            else:
                max_length = max(max_length, i - start + 1)

            usedchar[c] = i

        return max_length
