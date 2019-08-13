def smallestDifference(arrayOne, arrayTwo):
    arrayOne.sort()
    arrayTwo.sort()
    smallest = float("inf")
    currentSum = float("inf")
    smallest_array = []
    firstIdx = 0
    secondIdx = 0

    while firstIdx < len(arrayOne) and secondIdx < len(arrayTwo):
        firstNum = arrayOne[firstIdx]
        secondNum = arrayTwo[secondIdx]
        if firstNum < secondNum:
            currentSum = secondNum - firstNum
            firstIdx += 1
        elif secondNum < firstNum:
            currentSum = firstNum - secondNum
            secondIdx += 1
        else:
            return [firstNum, secondNum]

        if smallest > currentSum:
            smallest = currentSum
            smallest_array = [firstNum, secondNum]
    return smallest_array
