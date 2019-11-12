# Rotate the string, by shifting it number of times provided in the
# argument.

# str = "xyz", 2
# returns: "zab"

# def caesarCipherEncryptor(string, key):
#     my_string = list(string)
#     newKey = key % 26
#     result = []
#     for s in my_string:
#         if (ord(s) + newKey) > 122:
#             result.append(chr((96 + ((ord(s) + newKey) % 122))))
#         else:
#             result.append(chr(ord(s) + newKey))
#     return "".join(result)


def ceaserCipherEncrypter(string, key):
    my_string = list(string)
    new_key = key % 26
    result = []

    for s in my_string:
        if ord(s) + new_key > 122:
            result.append(chr(96 + ((ord(s) + new_key) % 122)))
        else:
            result.append(chr(ord(s) + new_key))
    return "".join(result)


print(ceaserCipherEncrypter("xyz", 2))
