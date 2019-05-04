from collections import namedtuple


class Assertions_Usecase():
    """Assertions are meant to flag out things which are meant
    to be impossible to happen within the codebase, these are unrecoverable
    errors to flag internal test cases. Assertions are debugging aid.
    Never use Assert statements for data validations. Make sure the
    assertion statements fail, before you use them in the field.
    These are not a mechanism for handling runtime errors.
    Asserts can be globally disabled with the interpreter setting.
    """

    def __init__(self, product):
        self.product = product

    def apply_discount(self, discount):
        price = int(self.product['price'] * (1.0 - discount))
        prod_name = self.product['name']
        assert 0 <= price <= self.product['price']
        return 'Revised price of {} is now: ${}'.format(prod_name, price)

    def never_failing_asserts(self, discount):
        price = int(self.product['price'] * (1.0 - discount))
        prod_name = self.product['name']
        assert(0 <= price <= self.product['price'], 'AssertionError') # noqa
        return 'Revised price of {} is now: ${}'.format(prod_name, price)


shoes = {'name': 'Fancy shoes', 'price': 14900}

asst = Assertions_Usecase(shoes)
print(asst.apply_discount(0.50))
print(asst.never_failing_asserts(2.0))

lst = namedtuple(int)
