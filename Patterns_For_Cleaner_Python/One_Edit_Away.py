# Given two strings s and t, determine if they are both one edit distance apart.

# Note:

# There are 3 possiblities to satisify one edit distance apart:

# Insert a character into s to get t
# Delete a character from s to get t
# Replace a character of s to get t


# Input: s = "ab", t = "acb"
# Output: true
# Explanation: We can insert 'c' into s to get t.

# Input: s = "cab", t = "ad"
# Output: false
# Explanation: We cannot get t from s by only one step.

# Input: s = "1203", t = "1213"
# Output: true
# Explanation: We can replace '0' with '1' to get t.

# Solution:

class Solution:
    def isOneEditDistance(self, s: str, t: str) -> bool:
        if len(s) < len(t) and (len(t) - len(s)) == 1:
            diff_count = 0
            for i, val in enumerate(s):
                if val not in t:
                    diff_count += 1
            return diff_count == 0
        elif (len(t) < len(s) and (len(s) - len(t)) == 1) or (len(t) == len(s)):
            diff_count = 0
            for val in s:
                if val not in t:
                    diff_count += 1
            return diff_count == 1
        else:
            return False

# Failed test case of "teacher" and "attacher"

# >>> sorted(t)
# ['a', 'c', 'e', 'e', 'h', 'r', 't']
# >>> t = "attacher"
# >>> sorted(t)
# ['a', 'a', 'c', 'e', 'h', 'r', 't', 't']

# Another pass at the solution:


class Solution_New:
    def isOneEditDistance(self, s: str, t: str) -> bool:
        if abs(len(s) - len(t)) > 1 or s == t:
            return False

        for i in range(max(len(s), len(t))):
            mod_s = s[:i] + s[i+1:]
            mod_t = t[:i] + t[i+1:]

            if mod_s == t or mod_t == s or mod_s == mod_t:
                return True

        return False



# Running the python codebase.

sol = Solution()
print(sol.isOneEditDistance("ab","acb"))

print(sol.isOneEditDistance("cab","ad"))

print(sol.isOneEditDistance("1203","1213"))


print("New solution")

sol = Solution_New()

print(sol.isOneEditDistance("ab","acb"))

print(sol.isOneEditDistance("cab","ad"))

print(sol.isOneEditDistance("1203","1213"))

print(sol.isOneEditDistance("teacher","attacher"))

# New Solution is the correct solution.
