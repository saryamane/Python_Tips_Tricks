# Define a Stack datastructure


class Stack():
    def __init__(self):
        self.stack = []

    def push(self, val):
        self.stack.append(val)

    def pop(self):
        return self.stack.pop()

    def is_empty(self):
        return self.stack == []

# Initialize the stack object


class Solution():
    def isValid(self, s):
        pdic = {"(": ")", "[": "]", "{": "}"}
        # initialize the stack constructor
        curstack = Stack()
        for c in s:
            if c in pdic:
                curstack.push(c)
            elif curstack.is_empty() or pdic[curstack.pop()] != c:
                return False
        return curstack.is_empty()


sol = Solution()
# Success condition
print(sol.isValid("({[]})"))
# Failure condition
print(sol.isValid("{([})"))
