from collections import defaultdict
res_dict = defaultdict(set)

f = open('text.txt', 'r')
for line in f:
    my_list = line.split(',')
    res_dict[my_list[0]].add(my_list[1])


for k, v in res_dict.items():
    print(k, end=",")
    for i in v:
        print(i.rstrip("\n"), end=",")
    print("\n",)
