class Solution:
    def numUniqueEmails(self, emails):
        res_lst = set()
        for email in emails:
            local_name = email.split('@')[0].replace(".", "").split('+')[0]
            domain_name = email.split('@')[1]
            # Join it back together.
            final_email = local_name + "@" + domain_name
            res_lst.add(final_email)
        return len(res_lst)


sol = Solution()
print(sol.numUniqueEmails(["test.email+alex@leetcode.com","test.e.mail+bob.cathy@leetcode.com", "testemail+david@lee.tcode.com"]))
