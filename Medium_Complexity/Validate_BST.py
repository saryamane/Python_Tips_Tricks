# Given a BST tree, return True, if it is satifisfies the BST 
# property else return False if otherwise. 
# The BST property is that the node to the left should be strictly
# less than the current node, whereas the node to the right should
# be greater than equal to the current node.


class BST:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None


def validateBst(tree):
    return validateBSTHelper(tree, float("-inf"), float("inf"))


def validateBSTHelper(tree, minValue, maxValue):
    if tree is None:
        return True
    if tree.value < minValue or tree.value >= maxValue:
        return False

    leftIsValid = validateBSTHelper(tree.left, minValue, tree.value)
    return leftIsValid and validateBSTHelper(tree.right, tree.value, maxValue)


