class Solution:
    def subdomainVisits(self, cpdomains: List[str]) -> List[str]:
        out_dict = {}
        out_list = []

        def find_subdomains(lst):
            output = []
            if len(lst) == 3:
                new_domains_1 = '.'.join(lst)
                new_domains_2 = '.'.join(lst[1:])
                new_domains_3 = lst[2]
                output.append(new_domains_1)
                output.append(new_domains_2)
                output.append(new_domains_3)
            elif len(lst) == 2:
                new_domains_1 = '.'.join(lst)
                new_domains_2 = lst[1]
                output.append(new_domains_1)
                output.append(new_domains_2)
            else:
                output.append(lst[0])
            return output
        for val in cpdomains:
            count, domain = val.split(' ')
            count = int(count)
            lsting = domain.split('.')
            lst = find_subdomains(lsting)
            for i in lst:
                if i in out_dict:
                    out_dict[i] += count
                else:
                    out_dict[i] = count

        for i in out_dict:
            elem = str(out_dict[i]) + " " + i
            out_list.append(elem)
        return out_list
