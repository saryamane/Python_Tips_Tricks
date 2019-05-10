class Solution:
    def addBinary(self, a, b):
        self.a = a
        self.b = b

        return str(bin(int(self.a, 2) + int(self.b, 2)))[2:]


sol = Solution()
out = sol.addBinary("111", "011")
print(out)
