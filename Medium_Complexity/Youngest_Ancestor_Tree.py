# Traverse through the tree and return the youngest common ancestor
# for the given 2 child nodes.


class AncestralTree:
    def __init__(self, name):
        self.name = name
        self.ancestor = None


def getYoungestCommonAncestor(topAncestor, descendantOne, descendantTwo):
    oneDepth = getDepth(descendantOne, topAncestor)
    twoDepth = getDepth(descendantTwo, topAncestor)

    if oneDepth > twoDepth:
        return backTrackAncestralTree(
            descendantOne, descendantTwo, oneDepth - twoDepth
            )
    else:
        return backTrackAncestralTree(
            descendantTwo, descendantOne, twoDepth - oneDepth
            )


def getDepth(descendant, ancestor):
    depth = 0
    while descendant != ancestor:
        depth += 1
        descendant = descendant.ancestor
    return depth


def backTrackAncestralTree(lowerDescendant, upperDescendant, diff):
    while diff > 0:
        lowerDescendant = lowerDescendant.ancestor
        diff -= 1

    while lowerDescendant != upperDescendant:
        lowerDescendant = lowerDescendant.ancestor
        upperDescendant = upperDescendant.ancestor
    return lowerDescendant
