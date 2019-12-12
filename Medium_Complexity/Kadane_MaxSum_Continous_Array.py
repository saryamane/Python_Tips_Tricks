def kadanealgo(array):
    maxEndingHere = array[0]
    maxSum = array[0]

    for num in array[1:]:
        maxEndingHere = max(maxEndingHere + num, num)
        maxSum = max(maxSum, maxEndingHere)
    return maxSum

