def hasSingleCycle(array):
    numElementVisited = 0
    currentIdx = 0

    while numElementVisited < len(array):
        if numElementVisited > 0 and currentIdx == 0:
            return False

        numElementVisited += 1
        currentIdx = getNextIdx(currentIdx, array)
    return currentIdx == 0


def getNextIdx(currIdx, array):
    jump = array[currIdx]
    nextIdx = (currIdx + jump) % len(array) # Handles the wrapping array
    return nextIdx if nextIdx >= 0 else nextIdx + len(array)
