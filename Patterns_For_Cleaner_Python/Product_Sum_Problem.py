# Product Sum

# Input is an array which can contain another arrays inside it.
# Return the sum of the products within the passed array list.

# Example: [x, [y,z]], output should be x + 2*(y + z)


def product_sum(array, multiplier=1):
    sum = 0
    for element in array:
        if type(element) is list:
            sum += product_sum(element, multiplier+1)
        else:
            sum += element
    return sum * multiplier


# def product_sum(array, multiplier = 1):
#     sum = 0
#     for element in array:
#         if type(element) is list:
#             sum += product_sum(element, multiplier + 1)
#         else:
#             sum += element
#     return sum * multiplier


output = product_sum([5,2,[7,-1], 3,[6,[-13,8], 4]])
print(output)
