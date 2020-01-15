# Given a binary tree, invert the tree so that at every level
# the left branch becomes the right branch.

# You can use the BST property to traverse the tree, and at every
# level, you will swap the left branch to the right branch and move
# forward in a recurrsive fashion.

# Recursive approach

def invertBinaryTree(tree):
    if tree is None:
        return

    swapLeftRightNodes(tree)
    invertBinaryTree(tree.left)
    invertBinaryTree(tree.right)

def swapLeftRightNodes(tree):
    tree.left, tree.right = tree.right, tree.left


# Time complexity: O(n), Space complexity: O(log(n)) # using the recursive stack.


# Iterative approach:
# O(n) - Space and Time complexity.

def invertBinaryTree(tree):
    queue = [tree]

    while len(queue):
        current = queue.pop(0)
        if current is None:
            continue

        swapLeftRightNodes(current)
        queue.append(current.left)
        queue.append(current.right)

def swapLeftRightNodes(tree):
    tree.left, tree.right = tree.right, tree.left
       


