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

# def fiboNacci(N):
#     if N <= 1:
#         return N
#     else:
#         return fiboNacci(N-1) + fiboNacci(N-2)
#
# print(fiboNacci(2))

# Do one with Memoization, O(n) in both time and space complexity

def getNthFibo(n, memoize = {1:0, 2:1}):
    if n in memoize:
        return memoize[n]
    else:
        memoize[n] = getNthFibo(n-1, memoize) + getNthFibo(n-2, memoize)
        return memoize[n]

# def fiboNacciMemoiazation(N, memoiaze={0:0, 1:1}):
#     if N in memoiaze.keys():
#         return memoiaze[N]
#     else:
#         memoiaze[N] = fiboNacciMemoiazation(N-1, memoiaze) + fiboNacciMemoiazation(N-2, memoiaze)
#         return memoiaze[N]
#
# print(fiboNacciMemoiazation(6))

# Do one with iterative approach, which O(1) complexity.

# Time: O(n), space = O(1)
#
def getNthFibo(n):
    lastTwo = [0,1]
    counter = 1
    while counter < n:
        nextFib = lastTwo[0] + lastTwo[1]
        lastTwo[0] = lastTwo[1]
        lastTwo[1] = nextFib
        counter += 1
    return lastTwo[1] if n > 0 else lastTwo[0]


# def getFiboNumIterate(N):
#     fixArray = [0,1]
#     counter = 1
#     while counter < N:
#         nextFibo = fixArray[0] + fixArray[1]
#         fixArray[0] = fixArray[1]
#         fixArray[1] = nextFibo
#         counter += 1
#         # print(counter)
#         # print(fixArray)
#     return fixArray[1] if N > 0 else fixArray[0]
#
#
# print(getFiboNumIterate(5))
