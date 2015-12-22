/**
 Executable tests for the Papaya graph package
 */
 
// How I imagine it will work:
// import XCTest
/*
let names = ["Kevin Bacon", "Nets Katz", "Paul Erdos", "Natalie Portman",
             "MC Bat Commander"]

var graph = UndirectedAList(vertices: names)

print(graph.vertices)

do {
    try graph.addEdge("Kevin Bacon", to: "Natalie Portman")
    try graph.addEdge("Paul Erdos", to: "Nets Katz")
    try graph.addEdge("MC Bat Commander", to: "Natalie Portman")
} catch {
    print("couldn't add an edge!")
}

print(graph.edges)

try! graph.addVertex("Ian Kuehne")

print(graph.vertices)

try! graph.addEdge("Ian Kuehne", to: "Natalie Portman")

do {
    try graph.addVertex("Ian Kuehne")
} catch {
    print("couldn't add ian for some reason.")
}

var graph2 = UndirectedAMatrix(graph: graph)

print(graph2.vertices)
print(graph2.edges)
print(graph.vertices)
print(graph.edges)

// A really basic BFS test
let path = breadthFirstPath(graph, start: "Ian Kuehne", end: "Kevin Bacon")
print(path)
*/
// Some things to test with BFS - multiple non-optimal paths, no path exists.
// Creating a more complicated test graph
let intVerts = 1...10
var intGraphList = UndirectedAList(vertices: intVerts)
var intGraphMatrix = UndirectedAMatrix(vertices: intVerts)

print(intGraphList.vertices)
print(intGraphMatrix.vertices)
print(intGraphList.edges)
print(intGraphMatrix.edges)

let edges = [(1, 2), (1, 9), (1, 7), (2, 3), (3, 4), (4, 7), (4, 8), (5, 6),
             (7, 8), (7, 9), (7, 10), (9, 10)]

for (from, to) in edges {
    do {
        try intGraphList.addEdge(from, to: to)
    } catch {
        print("couldn't add edge from \(from) to \(to) to list graph.")
    }
    do {
        try intGraphMatrix.addEdge(from, to: to)
    } catch {
        print("couldn't add edge from \(from) to \(to) to list graph.")
    }
}

print(intGraphList.edges)
print(intGraphMatrix.edges)

print(try! intGraphMatrix.neighbors(10))

print("breadth first paths in the adjacency matrix test graph")
var pathList = breadthFirstPath(intGraphMatrix, start: 1, end: 9)
print("the shortest path from 1 to 9 is \(pathList), should be one edge")
pathList = breadthFirstPath(intGraphMatrix, start: 1, end: 6)
print("the shortest path from 1 to 6 is \(pathList) - should be nil")
pathList = breadthFirstPath(intGraphMatrix, start: 10, end: 2)
print("shortest path from 10 to 2 is \(pathList) - should be 3 edges")
pathList = breadthFirstPath(intGraphMatrix, start: 10, end: 10)
print("shortest path from 10 to itself is \(pathList)")


