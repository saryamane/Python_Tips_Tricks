def removeKNode(head, k):
    counter = 1
    firstPtr = head
    secondPtr = head

    while counter <= k:
        secondPtr = secondPtr.next
        counter += 1

    if secondPtr is None:
        head.value = head.next.value
        head.next = head.next.next

    while secondPtr.next is not None:
        firstPtr = firstPtr.next
        secondPtr = secondPtr.next
    firstPtr.next = firstPtr.next.next
