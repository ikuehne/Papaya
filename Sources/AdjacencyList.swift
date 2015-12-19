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
    
}
