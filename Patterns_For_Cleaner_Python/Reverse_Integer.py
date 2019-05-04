class Solution():
    def reverse(self, x: int) -> int:
        def is_signed(x_val):
            if x_val < 0:
                return -1
            else:
                return 1
        neg_sign = is_signed(x)

        x_str = str(abs(x))
        arr = []
        for i in x_str:
            arr.append(i)

        rev_str = arr[::-1]
        output = int(''.join(rev_str)) * neg_sign

        if abs(output) > (2**31 - 1):
            return 0
        else:
            return output


sol = Solution()
print(sol.reverse(-123232))
