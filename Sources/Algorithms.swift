/**
 A file for basic graph algorithms, such as BFS, DFS, matchings, etc.
 */

/**
 An array extension to pop the last element from an array.
 */
private extension Array {
    mutating func pop() -> Element {
        let element = self[self.count-1]
        self.removeAtIndex(self.count-1)
        return element
    }
}

/**
 A basic queue structure used by BFS algorithm.
 */
private struct Queue<Element> {
    var items = [Element]()

    mutating func enqueue(item: Element) {
        items.insert(item, atIndex: 0)
    }

    mutating func dequeue() -> Element {
        /*
        let element = items[items.count-1]
        items.removeAtIndex(items.count-1)
        return element
        */
        return items.pop()
    }

    var isEmpty : Bool {
        return items.count == 0
    }
}

/**
 Creates a dictionary of successors in a graph, using the BFS algorithm and
 starting at a given vertex.

 - parameter graph: The graph to search in.
 - parameter start: The vertex from which to begin the BFS.

 - returns: A dictionary of each vertex's parent, or the vertex visited just
   before the vertex.
 */
private func buildBFSParentDict<G: Graph, V: Hashable where V == G.Vertex>(
                                        graph: G, start: V) -> [V: V] {
    var queue = Queue<V>()
    var visited = Set<V>()
    var current: V
    var result = [V: V]()
    queue.enqueue(start)
    while !queue.isEmpty {
        current = queue.dequeue()
        let neighbors = try! graph.neighbors(current)
        for neighbor in neighbors {
            if !visited.contains(neighbor) {
                queue.enqueue(neighbor)
                result[neighbor] = current
            }
        }
        visited.insert(current)
    }

    return result
}

/**
 Gives the shortest path from one vertex to another in an unweighted graph.

 - parameter graph: The graph in which to search.
 - parameter start: The vertex from which to start the BFS.
 - parameter end: The destination vertex.

 - returns: An optional array that gives the shortest path from start to end.
   returns nil if no such path exists.
 */
func breadthFirstPath<G: Graph, V: Hashable where V == G.Vertex>(
                                        graph: G, start: V, end: V) -> [V]? {
    let parentsDictionary = buildBFSParentDict(graph, start: start)
    var result: [V] = [end]
    if let first = parentsDictionary[end] {
        var current = first
        while current != start {
            result.insert(current, atIndex: 0)
            current = parentsDictionary[current]!
        }
    }
    result.insert(start, atIndex: 0)

    return result
}
