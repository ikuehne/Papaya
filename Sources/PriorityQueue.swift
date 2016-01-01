/**
 This file defines a protocol for a min-priority queue, and a binary heap
 implementation of one for use in graph algorithms.

 Priority Queues are described by Chapter 6.5 of CLRS Introduction to
 Algorithms, 3rd edition.
 */

/**
 A protocol for Priority Queues. Note that they could be either max or min,
 so long as an ordering function is properly defined on them.
 */
public protocol PriorityQueue {

    typealias Element
    
    /**
     A comparison function.
     
     Should return true if the lhs is higher priority than the rhs,
     so that true means lhs will be extracted before rhs.

     Should return true if the two arguments have the same priority.
     */
    var compare: (Element, Element) -> Bool { get }

    /**
     Initialize an empty queue over the given comparison function.

     - parameter compare: A function that compares two elements of the queue.
     */
    init(compare: (Element, Element) -> Bool)

    /**
     Insert a new element into the priority queue.

     - parameter item: the item to insert.
     */
    mutating func insert(item: Element)

    /**
     Get the element of highest priority, without changing the queue.

     - returns: The element of highest priority, or nil if queue is empty.
     */
    func peek() -> Element?

    /**
     Get and remove the element of highest priority. Changes the queue.

     - returns: The element of highest priority, or nil if queue is empty.
       This element is removed if it exists.
     */
    mutating func extract() -> Element?

}

/**
 Errors for binary heaps.

 Currently only the case where increasePriority is a priority decrease.
 */
public enum HeapError: ErrorType {
    case LowerPriority
}

/**
 An implementation of Priority Queues as a simple heap structure.
 */
public struct PriorityHeap<T>: PriorityQueue {

    /**
     An array representing the heap.
     */
    private var heap = [T]()

    /**
     The comparision function.

     Should return true if lhs has higher priority than rhs.
     */
    public let compare: (T, T) -> Bool

    /**
     Initialize an empty heap with a given comparison function.

     - parameter compare: A comparison function over pairs of elements.
     */
    public init(compare: (T, T) -> Bool) {
        self.compare = compare
    }

    /**
     Initialize a heap with a given array of items and a comparison function.

     - parameter items: An array of elements to create the queue from.
     - parameter compare: A comparison function over pairs of elements.
     */
    public init(items: [T], compare: (T, T) -> Bool) {
        self.compare = compare
        heap = items
        for i in (0...(items.count / 2)).reverse() {
            heapify(i)
        }
    }

    /**
     View the highest-priority element in the queue, without extracting.

     - returns: The highest-priority element, or nil if queue is empty.
     */
    public func peek() -> T? {
        if heap.count == 0 {
            return nil
        } else {
            return heap[0]
        }
    }

    /**
     Get the location of a heap element's parent.

     - parameter i: the index for which to retrieve the parent.

     - returns: An integer index of the parent of the argument.
     */
    private let parent = { $0 / 2 }

    /**
     Get the location of a heap element's left child.

     - parameter: the index for which to get a left child.

     - returns: An integer index of the left child of the argument.
     */
    private let leftChild = { 2 * $0 }

    /**
     Get the location of a heap element's right child.

     - parameter: the index for which to get a right child.

     - returns: An index of the right child of the argument.
     */
    private let rightChild = { 2 * $0 + 1 }


    /**
     Increase the priority of an element of the queue. Requires an index into
     the internal heap, so currently this is private.

     - parameter atIndex: the index into the heap of which to increase the key.
     - parameter toKey: the new key to put here.

     - throws: `HeapError.LowerPriority` if the new priority is smaller.
     */
    private mutating func increasePriority(atIndex: Int, toKey: T) throws {
        var i = atIndex
        guard compare(toKey, heap[i]) else {
            throw HeapError.LowerPriority
        }

        heap[i] = toKey
        while i > 0 && compare(heap[i], heap[parent(i)]) {
            let temp = heap[i]
            heap[i] = heap[parent(i)]
            heap[parent(i)] = temp
            i = parent(i)
        }
    }

    /**
     Gets the index in the internal heap of the element matching a given
     predicate, or nil if no element matches it.

     Will return the first index matching this predicate if multiple elements
     in the queue match it, so please don't use this if there's a change of
     that happening.

     - parameter matchingPredicate: The predicate to match elements against.

     - returns: And integer index of the first element matching the predicate,
       or nil if no element does.
     */
    private func getIndex(matchingPredicate: T -> Bool) -> Int? {
        for (i, element) in heap.enumerate() {
            if matchingPredicate(element) { return i }
        }
        return nil
    }

    func getElement(matchingPredicate: T -> Bool) -> T? {
        if let index = getIndex(matchingPredicate) {
            return heap[index]
        } else {
            print("couldn't find matching predicate \(matchingPredicate)")
            return nil
        }
    }

    /**
     Increase the priority to a given value of an element matching the given
     predicate.
     TODO Document
     */
    mutating func increasePriorityMatching(toKey: T,
                          matchingPredicate: T -> Bool) throws -> Bool {
        if let index = getIndex(matchingPredicate) {
            try increasePriority(index, toKey: toKey)
            return true
        }
        return false
    }


    /**
     Insert a new element into the queue.

     - parameter item: the element to insert.
     */
    public mutating func insert(item: T) {
        heap.append(item)
        var i = heap.count - 1

        // repeated code - CLRS first makes the priority of the new element
        // -infinity, then increases its priority, but infinity priority
        // is not well-defined for this general case.

        while i > 0 && compare(heap[i], heap[parent(i)]) {
            let temp = heap[i]
            heap[i] = heap[parent(i)]
            heap[parent(i)] = temp
            i = parent(i)
        }
    }

    /**
     Extract the highest-priority element from the queue.

     This removes the element from the queue.

     - returns: The highest-priority element, or nil if the queue is empty.
     */
    public mutating func extract() -> T? {
        guard heap.count > 0 else {
            return nil
        }
        let top = heap[0]
        heap[0] = heap[heap.count-1]
        heap.removeAtIndex(heap.count-1)
        heapify(0)
        return top
    }

    private mutating func heapify(i: Int) {
        let l = leftChild(i)
        let r = rightChild(i)
        var largest = i
        if l < heap.count && compare(heap[l], heap[i]) {
            largest = l
        }
        if r < heap.count && compare(heap[r], heap[largest]) {
            largest = r
        }
        if largest != i {
            let temp = heap[i]
            heap[i] = heap[largest]
            heap[largest] = temp
            heapify(largest)
        }
    }
}
