/*
 This file defines graph types as protocols, as well as related errors.
*/

/**
 Errors related to the `Graph` protocol.

 - `.VertexAlreadyPresent`: Error due to a vertex already being in the graph.
 - `.VertexNotPresent`: Error due to a vertex not being in the graph.
 - `.EdgeNotPresent`: Error due to an edge not being in the graph.
*/
public enum GraphError: ErrorType {
    case VertexAlreadyPresent
    case VertexNotPresent
    case EdgeNotPresent
}

/**
 Description of abstract graph type.

 Provides a generic set of graph operations, without assuming a weighting on
 the graph.
*/
public protocol Graph {
    /**
     Type representing vertices.

     All instances of this type in the graph should be unique, so that 
     ∀ v ∈ `vertices`, (v, v') ∈ `edges` & v'' = v ⟹  (v'', v') ∈ `edges`.  That
     is, all edges and vertices should be unique.
    */
    typealias Vertex

    /**
     Initializes an empty graph.
    */
    init()

    /**
     Initializes a graph with the given vertices and no edges.

     A *default implementation* using the empty initializer and `addVertex` is
     provided.

     - parameter vertices: A collection of vertices to include initially.
    */
    //init<V: CollectionType where V.Generator.Element == Vertex> (vertices: V)
    // Maybe shouldn't be required?
    // Default implementation may be good enough without requiring adopters
    // of the protocol to provide their own?

    /**
     Initializes a graph with the same vertices and edges as the given graph.

     A *default implementation* using the empty initializer, `addVertex`, and
     `addEdge` is provided.

     - parameter graph: The graph to copy.
    */
    //init<G: Graph where G.Vertex == Vertex>(graph: G)

    /**
     An array of all the vertices in the graph.
    */
    var vertices: [Vertex] { get }

    /**
     An array of all the edges in the graph, represented as tuples of vertices.
    */
    var edges: [(Vertex, Vertex)] { get }

    /**
     Returns whether there is an edge from one vertex to another in the graph.

     - parameter from: The vertex to check from.
     - parameter to: The destination vertex.

     - returns: `true` if the edge exists; `false` otherwise.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.
    */
    func edgeExists(from: Vertex, to: Vertex) throws -> Bool

    /**
     Creates an array of all vertices reachable from a vertex.

     A *default implementation* using `vertices` and `edgeExists` is provided.
     It works in O(V) time.

     - parameter vertex: The vertex whose neighbors to retrieve.

     - returns: An array of all vertices with edges from `vertex` to them, in no
       particular order, and not including `vertex` unless there is a loop.

     - throws: `GraphError.VertexNotPresent` if `vertex` is not in the graph.
    */
    func neighbors(vertex: Vertex) throws -> [Vertex]

    /**
     Adds a new vertex to the graph with no edges connected to it.

     Changes the graph in-place to add the vertex.

     - parameter vertex: The vertex to add.

     - throws: `GraphError.VertexAlreadyPresent` if `vertex` is already in the
       graph.
    */
    mutating func addVertex(vertex: Vertex) throws

    /**
     Adds a new edge to the graph from one vertex to another.
   
     Changes the graph in-place to add the edge.

     - parameter from: The vertex to start the edge from.
     - parameter to: The vertex the edge ends on.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.
    */
    mutating func addEdge(from: Vertex, to: Vertex) throws

    /**
     Removes a vertex and all edges connected to it.

     - parameter vertex: The vertex to remove.

     - throws: `GraphError.VertexNotPresent` if the vertex to be deleted is not
       in the graph.
    */
    mutating func removeVertex(vertex: Vertex) throws

    /**
     Removes an edge from one vertex to another.

     - parameter from: The 'source' of the edge.
     - parameter to: The 'destination' of the edge.

     - throws: `GraphError.EdgeNotPresent` if the edge to be removed is not in
       the graph.
    */
    mutating func removeEdge(from: Vertex, to: Vertex) throws
}

/**
 Description of an undirected graph.

 This protocol is identical to Graph and DirectedGraph, but new types should
 implement this protocol if the `edgeExists` function is reflexive, i.e. if the
 edges have no associated direction.
*/
public protocol UndirectedGraph: Graph { }

/**
 Description of a directed graph.

 This protocol is identical to Graph and UndirectedGraph, but new types should
 implement this protocol with the `edgeExists` function not reflexive, i.e. if
 the edges have an associated direction.
*/
public protocol DirectedGraph: Graph { }

/**
 Description of a weighted graph.

 Weighted graphs have a weight associated with each edge.
*/
public protocol WeightedGraph: Graph {

    /**
     Computes the weight associated with the given edge.

     - parameter to: The 'source' of the edge to use.
     - parameter from: The 'destination' of the edge to use.

     - returns: The weight associated with the given edge, or `nil` if the edge
       is not in the graph.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.
    */
    func weight(from: Vertex, to: Vertex) throws -> Double?

    /**
     Adds a new weighted edge to the graph from one vertex to another.

     Changes the graph in-place to add the edge.

     - parameter from: The 'source' of the edge to use.
     - parameter to: The 'destination' of the edge to use.
     - parameter weight: The 'weight' of the new edge to add.

     - throws: `GraphError.VertexNotPresent` if either vertex in the edge
       does not exist in the graph.
     */
    mutating func addEdge(from: Vertex, to: Vertex, weight: Double) throws
}

/**
 A weighted undirected graph protocol.

 This protocol is identical to a weighted graph, but it requires that the
 implementation of `edgeExists` be symmetric, i.e. edges go both ways.
 */
public protocol WeightedUndirectedGraph : WeightedGraph {}

/**
 A weighted directed graph protocol.

 This protocol is idential to a weighted graph, but it requires that the
 implementation of `edgeExists` not be symmetric, i.e. edges go in only one
 direction
 */
public protocol WeightedDirectedGraph : WeightedGraph {}

// Provides a default implementation for the `neighbors` function.
public extension Graph {
    public init<V: CollectionType
                where V.Generator.Element == Vertex> (vertices: V) {
        self = Self()
        for vertex in vertices {
            let _ = try? addVertex(vertex)
            // I believe this is a no-op if it throws.
        }
    }

    public init<G: Graph where G.Vertex == Vertex>(graph: G) {
        self = Self(vertices: graph.vertices)
        for (from, to) in graph.edges {
            // For a properly implemented graph, the edges are all unique and
            // this will never throw.
            try! addEdge(from, to: to)
        }
    }

    public func neighbors(vertex: Vertex) throws -> [Vertex] {
        var neighbors: [Vertex] = []

        for vertex2 in vertices {
            if try edgeExists(vertex, to: vertex2) {
                neighbors.append(vertex)
            }
        }

        return neighbors
    }
}

/**
 Gives the total weight of all edges in the graph. Useful for minimum
 spanning trees and setting an effectively infinite weight value in some
 graph algorithms.

 A default implementaion using the edges property and weight method is
 provided here.

 - returns: the sum of all of the edge weights in the graph, a Double.
 */
public extension WeightedGraph {
    public var totalWeight: Double {
        var result = 0.0
        for (from, to) in edges {
            result += try! weight(from, to: to)!
        }
        return result
    }
}


