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

/**
 A structure describing a weighted edge. Prim's algorithm priority queue
 holds these.
 */
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
        // can cause unwrapping of nil?

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

/**
 A structure used for storing shortest-path estimates for vertices in a graph.
 */
private struct WeightedVertex<V: Hashable>: Hashable {
    let vertex: V

    // The path weight bound and parent may be updated, or 'relaxed'
    var bound: Double
    var parent: V?

    var hashValue : Int {
        return vertex.hashValue
    }

    /*func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.vertex == rhs.vertex
    }*/
}

private func ==<V: Hashable>(lhs: WeightedVertex<V>,
                             rhs: WeightedVertex<V>) -> Bool {
    return lhs.vertex == rhs.vertex
}

/**
 A class for running Dijkstra's algorithm on weighted graphs.

 It stores the .d and .pi attributes for the graph's vertices, as described in
 CLRS, and handles procedures such as initialize single source and relax.

 Note that Dijkstra assumes a positive-weight graph.
 */
private class DijkstraController<G: WeightedGraph,
        V: Hashable where G.Vertex == V> {

    var distances = [V: Double]()
    var parents = [V: V]()
    var graph: G
    var start: V
    
    /**
     Initialize single source (see CLRS) - gives each vertex a distance
     estimate of infinity (greater than the total weight of all edges in the
     graph), and a parent value of nil (not in the dictionary).

     - parameter g: A weighted graph on which we will be searching for shortest
       paths.
     - parameter start: the vertex to start from - this will get a distance
       estimate of 0.
     */
    init(g: G, s: V) {
        graph = g
        start = s
        let totalweights = g.totalWeight + 1.0
        for vertex in g.vertices {
            distances[vertex] = totalweights
        }
        distances[start] = 0
    }

    /**
     Relaxes the distance estimate of the second given vertex by way of the
     first given vertex.

     - parameter from: The vertex from which we relax the distance estimate.
     - parameter to: the vertex for which we relax the distance estimate.

     Note, this assumes that the edge and both vertices exist in the graph.
     */
    func relax(from: V, to: V) {
        let weight = try! graph.weight(from, to: to)!
        if distances[to]! > distances[from]! + weight {
            distances[to] = distances[from]! + weight
            parents[to] = from
        }
    }

    /**
     Runs dijkstra's algorithm on the graph, as described in CLRS.

     Just sets up the parent and distance bound dictionaries, does not return
     any paths - that method is different.
     */
    func dijkstra() {
        var finished = Set<V>()
        var queue = PriorityHeap<V>(items: graph.vertices) {
            self.distances[$0]! < self.distances[$1]!
        }
        while queue.peek() != nil {
            let vertex = queue.extract()!
            finished.insert(vertex)
            for neighbor in try! graph.neighbors(vertex) {
                relax(vertex, to: neighbor)
            }
            // Maybe need to heapify the queue
        }
    }

    /**
     Gives the shortest path to the given vertex.

     - parameter to: The destination vertex of the path to find.

     - returns: an array of vertices representing the shortest path, or nil if
       no path exists in the graph.
     */
    func dijkstraPath(to: V) -> [V]? {
        if parents[to] == nil {
            return nil
        }
        var result = [V]()

        var current: V? = to
        repeat {
            result.insert(current!, atIndex: 0)
            current = parents[current!]
        } while current != nil && current != start

        result.insert(start, atIndex: 0)
        return result
    }

}


func dijkstraShortestPath<G: WeightedGraph, V: Hashable where G.Vertex == V>(
        graph: G, start: V, end: V) -> [V]? {

    let controller = DijkstraController<G, V>(g: graph, s: start)
    
    controller.dijkstra()

    return controller.dijkstraPath(end)
}
/*
/**
 Initializes a dictionary of vertices with their weight bounds, from a given
 source. The source will get a value of 0, while everything else will get a
 bound of infinite ( > the sum of all edge weights).
 
 - parameter graph: The graph whose vertices to use.
 - parameter start: The source vertex to use.

 - returns: A dictionary with a shortest path weight bound for each vertex.
 */
private func initializeSingleSource<G: WeightedGraph,
        V: Hashable where G.Vertex == V>(graph: G,
                                         start: V) -> Set<WeightedVertex<V>> {
    var result = Set<WeightedVertex<V>>()
    let maxWeight = graph.totalWeight + 1.0
    for vertex in graph.vertices {
        result.insert(WeightedVertex<V>(vertex: vertex,
                                        bound: maxWeight, parent: nil))
    }
    result.insert(WeightedVertex<V>(vertex: start, bound: 0, parent: nil))
    return result
}

private func relax<G: WeightedGraph, V: Hashable where G.Vertex == V>(
        inout through: WeightedVertex<V>, inout to: WeightedVertex<V>,
        inGraph graph: G) {
    if let weight = try! graph.weight(through.vertex, to: to.vertex) {
        if to.bound > through.bound + weight {
            to.bound = through.bound + weight
            to.parent = through.vertex
        }
    } else {
        print("somehow that edge doesn't exist.")
    }
}


private func buildDijkstraParents<G: WeightedGraph,
                    V: Hashable where G.Vertex == V>(graph: G,
                    start: V) -> Set<WeightedVertex<V>> {

    var result = initializeSingleSource(graph, start: start)
    var finished = Set<V>()
    var queue = PriorityHeap<WeightedVertex<V>>(items: Array(result))
    { $0.bound < $1.bound }
    // weighted edges here do not exactly correspond to edge weights in the
    // graph, the weights are actually a bound on total weight to the 'to'
    // vertex from start.

    var currentVertex: WeightedVertex<V>
    while queue.peek() != nil {
        // Take the edge with the lowest weight with a non-added vertex, add it
        currentVertex = queue.extract()!
        finished.insert(currentVertex.vertex)

        for neighbor in try! graph.neighbors(currentVertex.vertex) {
            if var adjacent = queue.getElement({ $0.vertex == neighbor }) {
                relax(&currentVertex, to: &adjacent, inGraph: graph)
            } else {
                print("couldn't find one \(neighbor)")
            }
        }
        print("loop peeking queue")
    }

    return result
}

public func dijkstraPath<G: WeightedGraph,
        V: Hashable where G.Vertex == V>(graph: G, start: V, end: V) -> [V] {
    let dijkstraParents = buildDijkstraParents(graph, start: start)
    for element in dijkstraParents {
        print("\(element.vertex) has weight \(element.bound) and parent \(element.parent)")
    }

    var result = [V]()
    var current = end
    while current != start {
        result.insert(current, atIndex: 0)
        current = dijkstraParents[dijkstraParents.indexOf(WeightedVertex<V>(
            vertex: current, bound: 0.0, parent: nil))!].vertex
    //    print("loop building path")
    }
    return result
}
*/
