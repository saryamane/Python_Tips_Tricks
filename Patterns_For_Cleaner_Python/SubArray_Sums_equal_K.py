# Given an array of integers and an integer k, you need to find the total number of continuous subarrays whose sum equals to k.

# Example 1:
# Input:nums = [1,1,1], k = 2
# Output: 2
# Note:
# The length of the array is in range [1, 20,000].
# The range of numbers in the array is [-1000, 1000] and the range of the integer k is [-1e7, 1e7].

import collections


class Solution():
    def subArray(self, nums, k):
        counter = collections.Counter()
        counter[0] = 1
        ans = su = 0

        for x in nums:
            su += x
            ans += counter[su - k]
            counter[su] = 1
        return ans


sol = Solution()
print(sol.subArray([1, 1, 1, 1], 2))
