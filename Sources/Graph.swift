/**
 A protocol including basic Graph operations.

 */

protocol Graph {

    typealias NodeType

    mutating func addNode(node: NodeType) throws

    mutating func addEdge(from node1: NodeType, to node2: NodeType) throws

    func adjacentTo(node: NodeType) -> [NodeType] throws

}
