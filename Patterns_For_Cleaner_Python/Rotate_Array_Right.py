# Given an array, rotate the array to the right by k steps, where k is non-negative.

# Example 1:

# Input: [1,2,3,4,5,6,7] and k = 3
# Output: [5,6,7,1,2,3,4]
# Explanation:
# rotate 1 steps to the right: [7,1,2,3,4,5,6]
# rotate 2 steps to the right: [6,7,1,2,3,4,5]
# rotate 3 steps to the right: [5,6,7,1,2,3,4]


class Solution:
    def rotate(self, nums, k):
        """
        Do not return anything, modify nums in-place instead.
        """
        n = len(nums)
        k = k % n

        nums[:] = nums[-k:] + nums[:-k]
        print(nums)


sol = Solution()
sol.rotate([1, 2, 3, 4, 5], 3)
