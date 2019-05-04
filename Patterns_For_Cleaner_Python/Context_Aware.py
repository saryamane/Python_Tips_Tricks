# Using with statements to gracefully close the open resource.
# Much better for resource management.

with open('text.txt', 'w') as f:
    f.write('Hello, this is line1\n')
    f.write('Now, this comes line2')