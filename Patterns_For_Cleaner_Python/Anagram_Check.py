# Given two strings s and t , write a function to determine if t is an anagram of s.

# Example 1:

# Input: s = "anagram", t = "nagaram"
# Output: true
# Example 2:

# Input: s = "rat", t = "car"
# Output: false


class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        return sorted(s) == sorted(t)

    def isAnagram1(self, s: str, t: str) -> bool:
        dic_1, dic_2 = {}, {}

        for item in s:
            dic_1[item] = dic_1.get(item, 0) + 1

        for item in t:
            dic_2[item] = dic_2.get(item, 0) + 1

        return dic_1 == dic_2

    def isAnagram2(self, s: str, t: str) -> bool:
        dic_1, dic_2 = [0] * 26, [0] * 26

        for item in s:
            dic_1[ord(item) - ord('a')] += 1

        for item in t:
            dic_2[ord(item) - ord('a')] += 1

        return dic_1 == dic_2


sol = Solution()
print(sol.isAnagram1("rat", "tar"))

print(sol.isAnagram2("ngram","magrn"))
