class Solution:
    def reverseString(self, s: List[str]) -> None:
        """
        Do not return anything, modify s in-place instead.
        """
        b = 0
        e = len(s)-1
        while b < e:
            tmp = s[b]
            s[b] = s[e]
            s[e] = tmp
            b += 1
            e -= 1


sol = Solution()
sol.reverseString(["h", "e", "l", "l", "o"])
