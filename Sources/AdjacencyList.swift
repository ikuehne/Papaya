/**
 This file uses Adjacency Lists to implement Graph protocols.
 */

/**
 Function for removing a value from an array.

 Cannot be an array extension because it requires the element type to be
 hashable, which we can't guarantee.

 Caution: removing a value that does not exist in the array is a no-op.
 */
private func removeFromArray<T: Hashable>(object: T, inout fromArr: [T]) {
    if let index = fromArr.indexOf(object) {
        fromArr.removeAtIndex(index)
    }
}
    

/**
 Unweighted Adjacency list.

 Includes basic functionality, but cannot be used as a graph because it does
 not know whether or not it's directed.
 */
public class AdjacencyList<Vertex: Hashable> {

    /**
     A dictionary of vertices with their neighbor lists.
     */
    private var adjacencyList = [Vertex: [Vertex]]()

    private init() {

    }

    /**
     Number of vertices in the graph.
     */
    private var size: Int {
        get {
            return adjacencyList.count
        }
    }

    /**
     Initializer that takes a collection of vertices with no edges.

     - parameter vertices: A collection of vertice to include.

     - complexity: O(`vertices.count`)
     */
    public init<V: CollectionType
                where V.Generator.Element == Vertex>(vertices: V) {
        // Should this throw if a vertex appears twice?
        for vertex in vertices {
            adjacencyList[vertex as Vertex] = []
        }
    }

    /**
     A computed array of all the vertices in the graph.

     - complexity: O(V)
     */
    public var vertices: [Vertex] {
        get {
            return Array(adjacencyList.keys)
        }
    }

    /**
     Adds a new disconnected vertex to the graph.

     - parameter vertex: The vertex to add.
    
     - throws: `GraphError.VertexAlreadyPresent` if `vertex` is already in
       the graph.

     - complexity: O(1)
     */
    public func addVertex(vertex: Vertex) throws {
        if let _ = adjacencyList[vertex] {
            // The Swift Programming Language book seems to prefer the pattern
            // `if <something> != nil` to this optional binding to the empty
            // pattern.
            throw GraphError.VertexAlreadyPresent
        }
        else {
            adjacencyList[vertex] = []
        }
    }

    /**
     Removes a vertex and all edges connected to it.

     - parameter vertex: The vertex to remove.

     - throws: `GraphError.VertexNotPresent` if the vertex to be deleted is
       not in the graph.

     - complexity: Unsure, but high. removeFromArray calls take O(E) time, and
       there are O(V) such calls, so at least O(EV).
     */
    public func removeVertex(vertex: Vertex) throws {
        guard let neighbors = adjacencyList[vertex] else {
            throw GraphError.VertexNotPresent
        }

        adjacencyList.removeValueForKey(vertex)
        
        for neighbor in neighbors {
            guard let _ = adjacencyList[neighbor] else {
                throw GraphError.VertexNotPresent
                // If this happens, the vertex to remove has a neighbor
                // which is not in the graph. Very bad.
            }
            removeFromArray(vertex, fromArr: &adjacencyList[neighbor]!)
        }
    }

    /**
     Returns whether there is an edge between two vertices in the graph.

     - parameter from: The source vertex to check.
     - parameter to: The destination vertex to check.

     - returns: `true` if the edge exists in the graph.

     - throws: `GraphError.VertexNotPresent` if either vertex doesn't exist.

     - complexity: O(V), or O(D) where D is the maximum degree of the graph.
     */
    public func edgeExists(from: Vertex, to: Vertex) throws -> Bool {

        guard let _ = adjacencyList[to] else {
            throw GraphError.VertexNotPresent
        }
        guard let neighbors = adjacencyList[from] else {
            throw GraphError.VertexNotPresent
        }

        return neighbors.contains(to)
    }

    /**
     Returns an array of all vertices adjacent to a vertex.

     - parameter vertex: The vertex whose neighbors to retrieve.

     - returns: An array of all vertices adjacent to the given one.

     - throws: `GraphError.VertexNotPresent` if vertex is not in the graph.

     - complexity: O(1)
     */
    public func neighbors(vertex: Vertex) throws -> [Vertex] {
        guard let neighbors = adjacencyList[vertex] else {
            throw GraphError.VertexNotPresent
        }

        return neighbors
    }
}

/**
 An undirected adjacency list. Edges are symmetric - v is adjacent to u iff
 u is adjacent to v.
 */
public class UndirectedAList<Vertex: Hashable>: AdjacencyList<Vertex>,
                                                      UndirectedGraph {

    required public override init() {
        super.init()
    }


    /**
     A computed array of all the edges in the graph, as tuples of vertices.

     - Complexity: O(E)
     */
    public var edges: [(Vertex, Vertex)] {
        get {
            var result = [(Vertex, Vertex)]()
            var visited = Set<Vertex>()
            for (vertex, neighbors) in adjacencyList {
                for neighbor in neighbors {
                    if !visited.contains(neighbor) {
                        result.append((vertex, neighbor))
                    }
                }
                visited.insert(vertex)
            }
            return result
        }
    }

    /**
     Adds a new edge between two vertices in the graph.

     This is a symmetric operation in undirected graphs.

     - parameter from: One vertex of the desired edge.
     - parameter to: The other vertex of the edge.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.

     - complexity: O(1)
     */
    public func addEdge(from: Vertex, to: Vertex) throws {
        guard let _ = adjacencyList[from] else {
            throw GraphError.VertexNotPresent
        }
        guard let _ = adjacencyList[to] else {
            throw GraphError.VertexNotPresent
        }
        // What should this do if the edge already exists? Throw? no-op?
        // multiple edges?
        adjacencyList[from]!.append(to)
        adjacencyList[to]!.append(from)
        // This is another thing: cannot use the guard let bindings of these
        // optionals, since append mutates. My next thought would be to use
        // guard var =, but apparently that is getting deprecated.
    }

    /**
     Removes an edge from one vertex to another.

     In undirected graphs, this is also symmetric. Order of the parameters
     does not matter.

     - parameter from: The source of the edge to remove.
     - parameter to: The destination of the edge to remove.

     - throws: `GraphError.EdgeNotPresent` if the edge is not in the graph,
       `GraphError.VertexNotPresent` if either vertex isn't in the graph.

     - complexity: O(V), or O(D)
     */
    public func removeEdge(from: Vertex, to: Vertex) throws {
        guard let neighborsFrom = adjacencyList[from] else {
            throw GraphError.VertexNotPresent
        }
        guard let _ = adjacencyList[to] else {
            throw GraphError.VertexNotPresent
        }
        guard neighborsFrom.contains(to) else {
            throw GraphError.EdgeNotPresent
        }
        removeFromArray(to, fromArr: &adjacencyList[from]!)
        removeFromArray(from, fromArr: &adjacencyList[to]!)
        // same as above, would like to use guard var, need to look for
        // alternatives.
    }
}


/**
 Directed adjacency list. When using this class, source is different from
 destination vertex in an edge.
 */
public class DirectedAList<Vertex: Hashable>: AdjacencyList<Vertex>,
                                                    DirectedGraph {
    
    required public override init() {
        super.init()
    }

    /**
     A computed array of all the edges in the graph, as tuples of vertices.

     - complexity: O(E)
     */
    public var edges: [(Vertex, Vertex)] {
        get {
            var result = [(Vertex, Vertex)]()
            for (vertex, neighbors) in adjacencyList {
                for neighbor in neighbors {
                    result.append((vertex, neighbor))
                }
            }
            return result
        }
    }

    /**
     Adds a new edge from one vertex to another in the graph.

     This is an asymmetric operation: order of arguments matters!

     - parameter from: the source vertex of the desired edge
     - parameter to: the destination vertex of the desired edge

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.

     - complexity: O(1)
     */
    public func addEdge(from: Vertex, to: Vertex) throws {
        guard let _ = adjacencyList[from] else {
            throw GraphError.VertexNotPresent
        }
        guard let _ = adjacencyList[to] else {
            throw GraphError.VertexNotPresent
        }
        adjacencyList[from]!.append(to)
    }

    /**
     Remove an edge from the graph.

     - parameter from: the source vertex of the edge to remove.
     - parameter to: the destination vertex of the edge to remove.

     - throws: `GraphError.EdgeNotPresent` if the edge doesn't exist in the
       graph, `GraphError.VertexNotPresent` if either vertex doesn't exist.

     - complexity: O(V), or O(D)
     */
    public func removeEdge(from: Vertex, to: Vertex) throws {
        guard let neighborsFrom = adjacencyList[from] else {
            throw GraphError.VertexNotPresent
        }
        guard let _ = adjacencyList[to] else {
            throw GraphError.VertexNotPresent
        }
        guard neighborsFrom.contains(to) else {
            throw GraphError.EdgeNotPresent
        }
        removeFromArray(to, fromArr: &adjacencyList[from]!)
    }
}


/**
 Implementation of a weighted undirected graph using an adjacency list.
 */
final public class WeightedUndirectedAList<Vertex: Hashable> :
                AdjacencyList<Vertex>, WeightedUndirectedGraph {

    private var weightTable = [Vertex: [Vertex: Double]]()

    required public override init() {
        super.init()
    }

    /**
     Computed property which is an array of edges in the graph, represented as
     (Vertex, Vertex) tuples. Read-only.
     */
    public var edges: [(Vertex, Vertex)] {
        var result = [(Vertex, Vertex)]()
        var visited = Set<Vertex>()
        for (vertex, neighbors) in adjacencyList {
            for neighbor in neighbors {
                if !visited.contains(neighbor) {
                    result.append((vertex, neighbor))
                }
            }
            visited.insert(vertex)
        }
        return result
    }


    /**
     Computes the weight associated with the given edge.

     - parameter to: The `source` of the desired edge.
     - parameter from: The `destination` of the desired edge.

     - returns: The weight associated with the given edge, a Double.

     - throws: `GraphError.VertexNotPresent` if either vertex not in the graph
       or, `GraphError.EdgeNotPresent` if the edge does not exist in the graph.
     */
    public func weight(from: Vertex, to: Vertex) throws -> Double? {
        guard adjacencyList[from] != nil else {
            throw GraphError.VertexNotPresent
        }
        guard adjacencyList[to] != nil else {
            throw GraphError.VertexNotPresent
        }
        let result1 = weightTable[from]?[to]
        let result2 = weightTable[to]?[from]
        
        if result1 == nil {
            return result2
        }
        return result1
    }

    /**
     Adds a new edge of unspecified weight to the graph.

     Required to satisfy graph protocol - this is bad.
     Currently, this will add a zero-weight edge.

     Probably don't use it when using a weighted adjacency list.
     */
    public func addEdge(from: Vertex, to: Vertex) throws {
        try addEdge(from, to: to, weight: 0.0)
    }

    /**
     Adds a new weighted edge to the graph from one vertex to another.

     Changes the graph in-place to add the weighted edge.

     - parameter from: The `source` of the edge to add
     - parameter to: The  `destination` of the edge to add
     - parameter weight: The `weight` of the edge to add

     - throws: `GraphError.VertexNotPresent` if either vertex does not exist
       in the graph.
     */
    public func addEdge(from: Vertex, to: Vertex, weight: Double) throws {
        guard adjacencyList[from] != nil else {
            throw GraphError.VertexNotPresent
        }
        guard adjacencyList[to] != nil else {
            throw GraphError.VertexNotPresent
        }
        adjacencyList[from]!.append(to)
        adjacencyList[to]!.append(from)
        if weightTable[from] == nil {
            weightTable[from] = [to: weight]
        } else {
            weightTable[from]![to] = weight
        }
    }

    /**
     Remove an edge between two given vertices in the graph.

     - parameter from: the `source` of the edge.
     - parameter to: the `destination` of the edge to remove.
     These are interchangable in the undirected graph here.

     - throws: `GraphError.VertexNotPresent` if those vertices don't exist,
       and `GraphError.EdgeNotPresent` if the edge doesn't exist.
     */
    public func removeEdge(from: Vertex, to: Vertex) throws {
        guard adjacencyList[from] != nil else {
            throw GraphError.VertexNotPresent
        }
        guard let neighborsTo = adjacencyList[to] else {
            throw GraphError.VertexNotPresent
        }
        guard neighborsTo.contains(from) else {
            throw GraphError.EdgeNotPresent
        }

        removeFromArray(to, fromArr: &adjacencyList[from]!)
        removeFromArray(from, fromArr: &adjacencyList[to]!)

        if weightTable[from]![to] != nil {
            weightTable[from]!.removeValueForKey(to)
        } else {
            weightTable[to]!.removeValueForKey(from)
        }
    }
}
