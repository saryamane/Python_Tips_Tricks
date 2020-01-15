# Write an algorithm that traverses through a given tree in a 
# Breadth first search fashion

# Here for BFS, we make use of the queue data structure.
# Time complexity: O(v + e), Space complexity: O(v)

class Node:
    def __init__(self, name):
        self.children = []
        self.name = name


    def addChild(self, name):
        self.children.append(Node(name))
        return self

    def breadthFirstSearch(self, array):
        queue = [self]
        while len(queue):
            current = queue.pop(0)
            array.append(current.name)
            for child in current.children:
                queue.append(child)
        return array
