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
        heap = items
        self.compare = compare
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
        while i > 0 && compare(heap[parent(i)], heap[i]) {
            var temp = heap[i]
            heap[i] = heap[parent(i)]
            heap[parent(i)] = temp
            i = parent(i)
        }
    }


    /**
     Insert a new element into the queue.

     - parameter item: the element to insert.
     */
    public mutating func insert(item: T) {
        heap.append(item)
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

    private mutating func heapify(index: Int) {
    }
}
