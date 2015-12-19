/*
 This file describes adjacency matrices as an implementation of the
 UndirectedGraph class.
*/

/**
 Two-dimensional matrices laid out contiguously in memory.

 Regular two-dimensional Swift arrays consist of an outer array of references to
 inner arrays, which has poor cache performance and thus inefficient access.
 The contiguous arrays implemented in this class have a more efficient memory
 layout at the expense of forcing all rows to be of the same length.
 */
final private class Matrix<T> {
    /**
     An array containing the contents of the matrix.  Laid out such that row 0,
     column 0 is adjacent to row 0, column 1 in memory, while row 0, column 0 is
     `self.nCols` spaces away from row 1, column 0.
     */
    private var contents: [T]!
    /** The number of rows in the array. */
    private var nRows: Int
    /** The number of columns in the array. */
    private var nCols: Int!
    
    /**
     Computes the index into `self.contents` corresponding to the given row and
     column.
     
     `self.contents` is laid out such that row 0, column 0 is adjacent to row 0,
     column 1 in memory, while row 0, column 0 is `self.nCols` spaces away from
     row 1, column 0.
     
     - parameter row: The row to index into.
     - parameter col: The column to index into.
     
     - returns: The corresponding index into `self.contents`.
     */
    private func index(row row: Int, col: Int) -> Int {
        return col % self.nCols &+ row &* self.nCols
    }
    
    /**
     Creates a new Matrix with a given number of rows and columns, filled
     with a single value.
     
     - parameter rows: The number of rows in the new matrix.
     - parameter cols: The number of columns in the new matrix.
     - parameter repeatedValue: The value with which to fill the new matrix.
     */
    private init(rows nRows: Int, cols nCols: Int, repeatedValue: T) {
        self.nRows = nRows
        self.nCols = nCols
        self.contents = [T](count: nRows * nCols, repeatedValue: repeatedValue)
    }
    
    /**
     Creates a new Matrix from the given array of arrays.  Fails if array size
     is uneven.
     
     - parameter array: An array listing the rows of the new matrix; that is,
       `array[row][col]` gives the `row`th row, `col`th column of the new array.
    */
    private init?(array: [[T]]) {
        self.nRows = array.count

        for row in array {
            if row.count != array[0].count {
                return nil
            }
        }
        
        if self.nRows >= 1 {
            self.nCols = array[0].count
        } else {
            self.nCols = 0
        }
        
        var optContents = [T?](count: self.nRows * self.nCols,
            repeatedValue: nil)
        for (i, row) in array.enumerate() {
            for (j, item) in row.enumerate() {
                optContents[j % self.nCols &+ i &* self.nCols] = item
            }
        }
        
        self.contents = optContents.map({$0!})
    }

    /**
     Adds a new row to the matrix.

     The row will be added at the end of the matrix, filled with the given
     value.

     - parameter repeatedValue: The value with which to fill the new row.

     - complexity: O(`nCols` * `nRows`)
    */
    private func addRow(repeatedValue: T) {
        nRows += 1
        let newRow: [T] = Array<T>(count: nCols, repeatedValue: repeatedValue)
        contents.appendContentsOf(newRow)
    }

    /**
     Adds a new column to the matrix.

     The column will be added at the "right" of the matrix, filled with the
     given value.  Note that this is a very slow operation due to the memory
     layout of the matrices.

     - parameter repeatedValue: The value with which to fill the new row.

     - complexity: O(`nCols` * `nRows`)
    */
    private func addColumn(repeatedValue: T) {
        nCols = nCols + 1
        var newContents: [T] = Array<T>(count: nRows * (nCols + 1),
                                        repeatedValue: repeatedValue)

        // Put the old items in their new positions.
        for (index, item) in contents.enumerate() {
            newContents[index + index / (nCols - 1)] = item
        }

        // Fill in the new items.
        for row in 0..<nRows {
            newContents[index(row: row, col: nCols - 1)] = repeatedValue
        }

        contents = newContents
    }

    /**
     Removes a given row from the matrix.

     - parameter row: The row to be removed.

     - returns: `Bit.One` if the row was in the matrix, or `.Zero` otherwise.

     - complexity: O(`nRows` * `nCols`)
    */
    private func removeRow(row: Int) -> Bit {
        if row >= nRows {
            return Bit.Zero
        }
        var newContents = [T]()
        let beforeRow = contents[0..<(row * nCols)]
        let afterRow = contents[((row + 1) * nCols)..<(nRows * nCols)]
        newContents.appendContentsOf(beforeRow)
        newContents.appendContentsOf(afterRow)
        contents = newContents
        nRows = nRows - 1
        return Bit.One
    }

    /**
     Removes a given column from the matrix.  Returns `Bit.One` if the
     column was in the matrix, or `.Zero` otherwise.

     - parameter col: The column to be removed.

     - returns: `Bit.One` if the column was in the matrix, or `.Zero` otherwise.

     - complexity: O(`nRows` * `nCols`)
    */
    private func removeColumn(col: Int) -> Bit {
        if col >= nCols {
            return Bit.Zero
        }
        var newContents = [T]()
        for (index, item) in contents.enumerate() {
            if (index % nCols) != 0 {
                newContents.append(item)
            }
        }
        contents = newContents
        nCols = nCols - 1
        return Bit.One
    }
    
    /**
     Retrieves or sets the element at a given row and column of the matrix.
     
     - parameter row: The row to use.
     - parameter col: The column to use.
     
     - returns: If `get`, then the element at the given row and column.  If
       `set`, then nothing.
     */
    private subscript(row: Int, col: Int) -> T {
        get {
            return self.contents[self.index(row: row, col: col)]
        }
        set(newValue) {
            self.contents[self.index(row: row, col: col)] = newValue
        }
    }
}

// Convenient testing for key membership in a dictionary.
private extension Dictionary {
    /** Test if a dictionary contains a key. */
    func contains(key: Key) -> Bool {
        return self[key] != nil
    }
}

/**
 Adjacency matrices for general graphs.

 The `AdjacencyMatrix` class is only capable of keeping track of the size and
 shape of the matrix.  To use adjacency matrices as graphs, use its subclasses,
 UndirectedAdjacencyMatrix and DirectedAdjacencyMatrix.
*/
public class AdjacencyMatrix<Vertex: Hashable> {
    /** The adjacency matrix itself.  */
    final private var matrix: Matrix<Int8>

    /**
     Initializer that takes a collection of vertices, and starts with no edges.

     - parameter vertices: A collection of vertices to include initially.

     - complexity: O(`vertices.count`²)
    */
    required public init<V: CollectionType
                where V.Generator.Element == Vertex> (vertices: V) {
        vertexMap = [Vertex: Int]()
        indexMap = [Int: Vertex]()
        var i = 0
        for vertex in vertices {
            vertexMap[vertex] = i
            indexMap[i] = vertex
            i++
        }
        matrix = Matrix(rows: i, cols: i, repeatedValue: 0)
    }

    required public init() {
        matrix = Matrix<Int8>(rows: 0, cols: 0, repeatedValue: 0)
        vertexMap = Dictionary<Vertex, Int>()
        indexMap = Dictionary<Int, Vertex>()
    }

    /**
     A dictionary mapping vertices to their indices in the matrix.

     This dictionary adds an extra level of indirection and overhead; however,
     it allows arbitrary hashable values to be used to name vertices while still
     using efficient integer indexing under the hood.
    */
    final private var vertexMap: [Vertex: Int]

    /**
     The corresponding dictionary mapping indices back to vertices.
    */
    final private var indexMap: [Int: Vertex]

    /**
     The number of vertices in the graph.

     - complexity: O(1)
    */
    final private var size: Int {
        get {
            return matrix.nRows
        }
    }
    
    /**
     A computed array of all the vertices in the graph.

     - complexity: O(V)
    */
    final public var vertices: [Vertex] {
        get {
            var result = [Vertex]()
            for vertex in vertexMap.keys {
                result.append(vertex)
            }
            return result
        }
    }

    /**
     Adds a new vertex to the graph with no edges connected to it.

     Changes the graph in-place to add the vertex.  Note that this is a very
     slow operation on adjacency matrices; it is better to create the matrix
     with all needed vertices.

     - parameter vertex: The vertex to add.

     - throws: `GraphError.VertexAlreadyPresent` if `vertex` is already in the
       graph.

     - complexity: O(V²)
    */
    final public func addVertex(vertex: Vertex) throws {
        if vertexMap.contains(vertex) {
            throw GraphError.VertexAlreadyPresent
        }
        let index = size
        indexMap[index] = vertex
        vertexMap[vertex] = index
        matrix.addColumn(0)
        matrix.addRow(0)
    }

    /**
     Removes a vertex and all edges connected to it.

     Note that this is a very slow operation on adjacency matrices.

     - parameter vertex: The vertex to remove.

     - throws: `GraphError.VertexNotPresent` if the vertex to be deleted is not
       in the graph.

     - complexity: O(V²)
    */
    final public func removeVertex(vertex: Vertex) throws {

        guard let index = vertexMap[vertex] else {
            throw GraphError.VertexNotPresent
        }

        vertexMap.removeValueForKey(vertex)
        indexMap.removeValueForKey(index)
        
        matrix.removeRow(index)
        matrix.removeColumn(index)
    }

}

/**
 Adjacency matrices for undirected graphs.
*/
final public class UndirectedAMatrix<Vertex: Hashable>: AdjacencyMatrix<Vertex>,
                                                        UndirectedGraph {

    required public init() {
        super.init()
    }
/*    required public init<V: CollectionType where V.Generator.Element == Vertex,
                                                 V.Index == Int> (vertices: V)
    required public init<G: Graph where G.Vertex == Vertex>(graph: G)*/
    /**
     An array of all the edges in the graph, represented as tuples of vertices.

     - complexity: O(V²)
    */
    public var edges: [(Vertex, Vertex)] {
        get {
            var result = [(Vertex, Vertex)]()
            for row in 0..<size {
                for col in row..<size {
                    if matrix[row, col] == 1{
                        result.append((indexMap[row]!, indexMap[col]!))
                    }
                }
            }
            return result
        }
    }

    /**
     Returns whether there is an edge between two vertices in the graph.

     - parameter from: The vertex to check from.
     - parameter to: The destination vertex.

     - returns: `true` if the edge exists; `false` otherwise.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.

     - complexity: O(1)
    */
    public func edgeExists(from: Vertex, to: Vertex) throws -> Bool {

        guard let row = vertexMap[from] else {
            throw GraphError.VertexNotPresent
        }

        guard let col = vertexMap[to] else {
            throw GraphError.VertexNotPresent
        }

        if row <= col {
            return matrix[row, col] == 1
        } else {
            return matrix[col, row] == 1
        }
    }

    /**
     Creates an array of all vertices adjacent to a vertex.

     - parameter vertex: The vertex whose neighbors to retrieve.

     - returns: An array of all vertices with edges from `vertex` to them, in no
       particular order, and not including `vertex` unless there is a loop.

     - throws: `GraphError.VertexNotPresent` if `vertex` is not in the graph.

     - complexity: O(V)
    */
    public func neighbors(vertex: Vertex) throws -> [Vertex] {
        guard let index = vertexMap[vertex] else {
            throw GraphError.VertexNotPresent
        }

        var result = [Vertex]()

        for row in 0..<index {
            if matrix[row, index] == 1 {
                result.append(indexMap[row]!)
            }
        }

        for col in index..<size {
            if matrix[index, col] == 1 {
                result.append(indexMap[col]!)
            }
        }

        return result
    }

    /**
     Adds a new edge between two vertices.
   
     Changes the graph in-place to add the edge.  This operation is symmetric;
     flipping the arguments makes no difference in the result.

     - parameter from: One vertex on the edge.
     - parameter to: The other vertex on the edge.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.

     - complexity: O(1)
    */
    public func addEdge(from: Vertex, to: Vertex) throws {
        guard let fromIndex = vertexMap[from] else {
            throw GraphError.VertexNotPresent
        }

        guard let toIndex = vertexMap[to] else {
            throw GraphError.VertexNotPresent
        }

        if fromIndex <= toIndex {
            matrix[fromIndex, toIndex] = 1
        } else {
            matrix[toIndex, fromIndex] = 1
        }
    }

    /**
     Removes an edge between two vertices.

     - parameter from: One vertex on the edge.
     - parameter to: The other vertex on the edge.

     - throws: `GraphError.EdgeNotPresent` if the edge to be removed is not in
       the graph.

     - complexity: O(1)
    */
    public func removeEdge(from: Vertex, to: Vertex) throws {
        guard let fromIndex = vertexMap[from] else {
            throw GraphError.VertexNotPresent
        }

        guard let toIndex = vertexMap[to] else {
            throw GraphError.VertexNotPresent
        }

        if fromIndex <= toIndex {
            if matrix[fromIndex, toIndex] == 1 {
                matrix[fromIndex, toIndex] = 0
            } else {
                throw GraphError.EdgeNotPresent
            }
        } else {
            if matrix[toIndex, fromIndex] == 1 {
                matrix[toIndex, fromIndex] = 0
            } else {
                throw GraphError.EdgeNotPresent
            }
        }
    }
}

/**
 Adjacency matrices for directed graphs.
*/
final public class DirectedAMatrix<Vertex: Hashable>: AdjacencyMatrix<Vertex>,
                                                      DirectedGraph {

    required public init() {
        super.init()
    }

    /**
     An array of all the edges in the graph, represented as tuples of vertices.
    
     The first vertex in each tuple is the source of the edge, and the second is
     the destination.

     - complexity: O(V²)
    */
    public var edges: [(Vertex, Vertex)] {
        get {
            var result = [(Vertex, Vertex)]()
            for row in 0..<size {
                for col in 0..<size {
                    if matrix[row, col] == 1{
                        result.append((indexMap[row]!, indexMap[col]!))
                    }
                }
            }
            return result
        }
    }

    /**
     Returns whether there is an edge from one vertex to another in the graph.

     - parameter from: The vertex to check from.
     - parameter to: The destination vertex.

     - returns: `true` if the edge exists; `false` otherwise.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.

     - complexity: O(1)
    */
    public func edgeExists(from: Vertex, to: Vertex) throws -> Bool {

        guard let row = vertexMap[from] else {
            throw GraphError.VertexNotPresent
        }

        guard let col = vertexMap[to] else {
            throw GraphError.VertexNotPresent
        }

        return matrix[row, col] == 1
    }

    /**
     Creates an array of all vertices reachable from a vertex.

     - parameter vertex: The vertex whose neighbors to retrieve.

     - returns: An array of all vertices with edges from `vertex` to them, in no
       particular order, and not including `vertex` unless there is a loop.

     - throws: `GraphError.VertexNotPresent` if `vertex` is not in the graph.

     - complexity: O(V)
    */
    public func neighbors(vertex: Vertex) throws -> [Vertex] {
        guard let index = vertexMap[vertex] else {
            throw GraphError.VertexNotPresent
        }

        var result = [Vertex]()

        for row in 0..<size {
            if matrix[row, index] == 1 {
                result.append(indexMap[row]!)
            }
        }

        return result
    }

    /**
     Adds a new edge from one edge to another.
   
     Changes the graph in-place to add the edge.  The new edge will go from
     `from` to `to`.

     - parameter from: The 'source' of the edge.
     - parameter to: The 'destination' of the edge.

     - throws: `GraphError.VertexNotPresent` if either vertex is not in the
       graph.

     - complexity: O(1)
    */
    public func addEdge(from: Vertex, to: Vertex) throws {
        guard let fromIndex = vertexMap[from] else {
            throw GraphError.VertexNotPresent
        }

        guard let toIndex = vertexMap[to] else {
            throw GraphError.VertexNotPresent
        }

        matrix[fromIndex, toIndex] = 1
    }

    /**
     Removes an edge from one vertex to another.

     - parameter from: The 'source' of the edge.
     - parameter to: The 'destination' of the edge.

     - throws: `GraphError.EdgeNotPresent` if the edge to be removed is not in
       the graph.

     - complexity: O(1)
    */
    public func removeEdge(from: Vertex, to: Vertex) throws {
        guard let fromIndex = vertexMap[from] else {
            throw GraphError.VertexNotPresent
        }

        guard let toIndex = vertexMap[to] else {
            throw GraphError.VertexNotPresent
        }

        if matrix[fromIndex, toIndex] == 1 {
            matrix[fromIndex, toIndex] = 0
        } else {
            throw GraphError.EdgeNotPresent
        }
    }
}
