# Compute the branch sums for a Binary tree.
# O/P is returned from left most to the right most branch

class BinaryTree:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None

def branchSums(root):
    sum = []
    calculateBranchSum(root, 0, sum)
    return sum


def calculateBranchSum(node, recurringSum, sum):
    if node is None:
        return

    newRecurringSum = recurringSum + node.value

    if node.left is None and node.right is None:
        sum.append(newRecurringSum)
        return

    calculateBranchSum(node.left, recurringSum, sum)
    calculateBranchSum(node.right, recurringSum, sum)

