# Find the closest number to the target in BST

# Node has value, left and right as the property in the BST

# Assume that there will be only one closest value in BST

def findClosestinBST(tree, target):
    return findClosestinBSTHelper(tree, target, float("inf"))

def findClosestinBSTHelper(tree, target, closest):
    if tree is None:
        return closest

    if abs(target - closest) > abs(target - tree.value):
        closest = tree.value

    if target < tree.value:
        return findClosestinBSTHelper(tree.left, target, closest)
    elif target > tree.value:
        return findClosestinBSTHelper(tree.right, target, closest)
    else:
        closest = tree.value
        return closest

# Let's do an iterative approach now.

def findClosestinBST(tree, target):
    return findClosestinBSTHelper(tree, target, float("inf"))

def findClosestinBSTHelper(tree, target, closest):
    currentNode = tree

    while currentNode is not None:

        if abs(target - closest) > abs(target - currentNode.value):
            closest = currentNode.value

        if target < currentNode.value:
            currentNode = currentNode.left
        elif target > currentNode.value:
            currentNode = currentNode.right
        else:
            break
    return closest
