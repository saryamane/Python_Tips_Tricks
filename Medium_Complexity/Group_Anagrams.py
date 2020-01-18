# Here you are provided with the list of string words.
# Your job is to group the anagrams found in that list together,
# and return the list of list of grouped anagrams.

# example:
# i/p array: [cat, flop, oy, lopf, tac, act, yo, olfp]
# o/p array: [[cat, tac, act], [flop, lopf, olfp], [oy, yo]]

def groupAnagram(my_list):
    new_list = []
    my_dict = {}
    for i in my_list:
        new_i = ''.join(sorted(i))
        if new_i in my_dict:
            my_dict[new_i].append(i)
        else:
            my_dict[new_i] = [i]
    
    for k, v in my_dict.items():
        new_list.append(v)
    return new_list

print_list = groupAnagram(['cat', 'flop', 'oy', 'lopf', 'tac', 'act', 'yo', 'olfp'])
print(print_list)
