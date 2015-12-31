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
    visited.insert(start)
    result[start] = start
    while !queue.isEmpty {
        current = queue.dequeue()
        let neighbors = try! graph.neighbors(current)
        for neighbor in neighbors {
            if !visited.contains(neighbor) {
                queue.enqueue(neighbor)
                result[neighbor] = current
                visited.insert(neighbor)
            }
        }
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
public func breadthFirstPath<G: Graph, V: Hashable where V == G.Vertex>(
                                        graph: G, start: V, end: V) -> [V]? {
    let parentsDictionary = buildBFSParentDict(graph, start: start)
    var result: [V] = [end]

    if end == start {
        return result
    }

    if let first = parentsDictionary[end] {
        var current = first
        while current != start {
            result.insert(current, atIndex: 0)
            current = parentsDictionary[current]!
        }
    } else {
        return nil
    }
    result.insert(start, atIndex: 0)

    return result
}
// Idea- When lots of shortest paths queries are expected, there should be a
// way to store the parentsDictionary so it's only computed once.

private struct WeightedEdge<Vertex> {
    let from: Vertex
    let to: Vertex
    let weight: Double
}

/**
 Runs Prim's algorithm on a weighted undirected graph.
 
 - parameter graph: A weighted undirected graph for which to create a minimum
   spanning tree.

 - returns: A minimum spanning tree of the input graph.
 */
public func primsSpanningTree<G: WeightedGraph where G.Vertex: Hashable>(
                                                        graph: G) -> G {

    var tree = G()
    var addedVerts = Set<G.Vertex>()
    
    var queue = PriorityHeap<WeightedEdge<G.Vertex>>()
    { $0.weight < $1.weight }

    let firstVertex = graph.vertices[0]
    try! tree.addVertex(firstVertex)
    addedVerts.insert(firstVertex)

    for neighbor in try! graph.neighbors(firstVertex) {
        let weight = try! graph.weight(firstVertex, to: neighbor)!
        queue.insert(WeightedEdge<G.Vertex>(from: firstVertex, to: neighbor,
                            weight: weight))
    }

    var currentEdge: WeightedEdge<G.Vertex>
    let target = graph.vertices.count

    // currently, vertices is computed many times for each graph.
    // trade some space for time and store sets of vertices?
    while addedVerts.count < target {
        repeat {
            currentEdge = queue.extract()!
        } while addedVerts.contains(currentEdge.to)
        // can cause infinite loop?

        try! tree.addVertex(currentEdge.to)
        try! tree.addEdge(currentEdge.from, to: currentEdge.to,
                          weight: currentEdge.weight)
        addedVerts.insert(currentEdge.to)
        for neighbor in try! graph.neighbors(currentEdge.to) {
            let weight = try! graph.weight(currentEdge.to, to: neighbor)
            queue.insert(WeightedEdge<G.Vertex>(from: currentEdge.to,
                                    to: neighbor, weight: weight!))
        }
    }

    return tree

}

private func dijkstraParentDict<G: WeightedGraph,
            V: Hashable where G.Vertex == V>(graph: G, start: V) -> [V: V] {
    var queue = PriorityHeap<WeightedEdge<G.Vertex>>()
    { $0.weight < $1.weight }

    for neighbor in graph.neighbors(start) {
        let weight = try! graph.weight(start, to: neighbor)!
        queue.insert(WeightedEdge<V>(from: start, to: neighbor,
                                     weight: weight))
    }

    while !queue.isEmpty {
        // Take the 
