class MinMaxStack:

    def __init__(self):
        self.MinMaxList = []
        self.stack = []

    def peek(self):
        return self.stack[len(self.stack) - 1]

    def pop(self):
        self.MinMaxList.pop()
        return self.stack.pop()

    def push(self, number):
        newMinMax = {"min": number, "max": number}
        if len(self.MinMaxList):
            lastMinMax = self.MinMaxList[len(self.MinMaxList) - 1]
            newMinMax["min"] = min(lastMinMax["min"], number)
            newMinMax["max"] = max(lastMinMax["max"], number)
        self.MinMaxList.append(newMinMax)
        self.stack.append(number)

    def getMin(self):
        return self.MinMaxList[len(self.MinMaxList) - 1]["min"]

    def getMax(self):
        return self.MinMaxList[len(self.MinMaxList) - 1]["max"]
