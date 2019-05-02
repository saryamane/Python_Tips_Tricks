class Assertions_Usecase():

    def __init__(self, product):
        self.product = product

    def apply_discount(self, discount):
        price = int(self.product['price'] * (1.0 - discount))
        prod_name = self.product['name']
        assert 0 <= price <= self.product['price']
        return 'Revised price of {} is now: ${}'.format(prod_name, price)


shoes = {'name': 'Fancy shoes', 'price': 14900}

asst = Assertions_Usecase(shoes)
print(asst.apply_discount(0.50))
