# The Fibonacci numbers, commonly denoted F(n) form a sequence,
# called the Fibonacci sequence, such that each number
# is the sum of the two preceding ones, starting from 0 and 1. That is,

# F(0) = 0,   F(1) = 1
# F(N) = F(N - 1) + F(N - 2), for N > 1.


class Solution:
    def fib(self, N: int) -> int:
        # For the recursion problem, define the base case where the
        # program will exit.
        if N <= 1:
            return N

        else:
            return self.fib(N - 1) + self.fib(N - 2)


sol = Solution()
print(sol.fib(6))

# Do one with Memoization, O(n) in both time and space complexity

def getNthFibo(n, memoize = {1:0, 2:1}):
    if n in memoize:
        return memoize[n]
    else:
        memoize[n] = getNthFibo(n-1, memoize) + getNthFibo(n-2, memoize)
        return memoize[n]


# Do one with iterative approach, which O(1) complexity.

# Time: O(n), space = O(1)

def getNthFibo(n):
    lastTwo = [0,1]
    counter = 3
    while counter < n:
        nextFib = lastTwo[0] + lastTwo[1]
        lastTwo[0] = lastTwo[1]
        lastTwo[1] = nextFib
        counter += 1
    return lastTwo[1] if n > 1 else lastTwo[0]
