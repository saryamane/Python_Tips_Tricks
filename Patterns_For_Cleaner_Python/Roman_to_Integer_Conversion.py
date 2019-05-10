class Solution:
    def romanToInt(self, s):
        self.s = s
        val = 0
        roman_dict_1 = {'IV': 4, 'IX': 9, 'XL': 40, 'XC': 90, 'CD': 400, 'CM': 900}
        roman_dict_2 = {'I': 1, 'V': 5, 'X':10 , 'L': 50, 'C': 100, 'D': 500, 'M': 1000}
        for k in roman_dict_1.keys():
            if k in self.s:
                val += roman_dict_1[k]
                self.s = self.s.replace(k, "", 1)

                if self.s == "":
                    return val

        for b in self.s:
            val += roman_dict_2[b]

        return val


sol = Solution()
out = sol.romanToInt('IV')
print(out)
