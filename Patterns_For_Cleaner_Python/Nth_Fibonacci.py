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

# Do one with Memoization


# Do one with iterative approach, which O(1) complexity.
