/**
 Executable tests for the Papaya graph package
 */

/**
 Tests for undirected adjacency list implementation of graphs
 */

let names = ["Kevin Bacon", "Nets Katz", "Paul Erdos", "Natalie Portman",
             "MC Bat Commander"]
let relationships = [("Kevin Bacon", "Natalie Portman"),
        ("Paul Erdos", "Nets Katz"), ("Paul Erdos", "Natalie Portman")]

func testInits() {
    // Test the empty initializer
    var graph = UndirectedAList<String>()
    assert(graph.vertices.isEmpty)
    assert(graph.edges.isEmpty)

    // Test initializing with an array of vertices
    graph = UndirectedAList<String>(vertices: [])
    assert(graph.vertices.isEmpty)
    assert(graph.edges.isEmpty)

    let setnames: Set<String> = Set(names)
    graph = UndirectedAList<String>(vertices: names)
    var setverts: Set<String> = Set(graph.vertices)
    assert(setnames == setverts)
    assert(graph.edges.isEmpty)

    // Test initializing with another graph
    // note: where to test this when one graph has edges?
    var graph2 = UndirectedAList<String>(graph: graph)
    setverts = Set(graph2.vertices)
    assert(setnames == setverts)
    assert(graph2.edges.isEmpty)

    graph = UndirectedAList<String>()
    graph2 = UndirectedAList<String>(graph: graph)
    assert(graph2.vertices.isEmpty)
    assert(graph2.edges.isEmpty)
}

private func ==<T: Equatable>(lhs: (T, T), rhs: (T, T)) -> Bool {
    let (a, b) = lhs
    let (c, d) = rhs
    return (a == c && b == d) || (a == d && b == c)
}
 
private func ==<T: Equatable>(lhs: [(T, T)], rhs: [(T, T)]) -> Bool {
    for item1 in lhs {
        var found = false
        for item2 in rhs {
            found = found || (item1 == item2)
        }
        if !found { return false }
    }
    for item1 in rhs {
        var found = false
        for item2 in lhs {
            found = found || (item1 == item2)
        }
        if !found { return false }
    }
    return true
}

func testEdgesEqual() {
    let edges1 = [("a", "b"), ("c", "d"), ("a", "c")]
    let edges2 = [("b", "a"), ("a", "c"), ("d", "c")]
    let edges3 = [("a", "b"), ("a", "c"), ("e", "f"), ("e", "a")]

    assert(!(edges1 == edges3))
    assert(edges1 == edges2)
    assert(!(edges2 == edges3))
}


func testAddRemoveVertex() {
    // Adding vertices
    var graph = UndirectedAList<String>()
    try! graph.addVertex("James")
    assert(graph.vertices == ["James"])
    try! graph.addVertex("Mitchard")
    assert(Set(graph.vertices) == Set(["James", "Mitchard"]))

    graph = UndirectedAList<String>(vertices: names)
    try! graph.addVertex("Earl")
    var setnames = Set(names)
    setnames.insert("Earl")
    assert(Set(graph.vertices) == setnames)
    setnames.remove("MC Bat Commander")
    try! graph.removeVertex("MC Bat Commander")
    assert(Set(graph.vertices) == setnames)

    for name in names {
        try? graph.removeVertex(name)
        // using try? allows this to pass over nonexistant edges
    }
    try! graph.removeVertex("Earl")
    assert(graph.vertices.isEmpty)

    // Test removing a vertex with edges
    graph = UndirectedAList<String>(vertices: names)
    for (from, to) in relationships {
        try! graph.addEdge(from, to: to)
    }
    assert(graph.edges == relationships)
    try! graph.removeVertex("Natalie Portman")
    assert(graph.edges == [("Paul Erdos", "Nets Katz")])
}
/*
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
This stuff all works
*/
// Some things to test with BFS - multiple non-optimal paths, no path exists.
/*
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
// this stuff all works
*/
/*
var items = [18, 5, 2, 4, 9, 16, 35, 34]
// remember to test on repeated values
var heap = PriorityHeap<Int>(compare: <=)
for item in items {
    heap.insert(item)
}
var current = heap.peek()
print("printing first queue")
while current != nil {
    current = heap.extract()
    print(current)
}

print("printing second queue")
var nextHeap = PriorityHeap<Int>(items: items, compare: <)
current = nextHeap.peek()
while current != nil {
    current = nextHeap.extract()
    print(current)
}
*/
/*
// create the example graph in the caltech math 6 spanning trees lecture
let vertices = ["r", "a", "b", "c", "d", "e"]
var graph = WeightedUndirectedAList<String>(vertices: vertices)
try! graph.addEdge("r", to: "a", weight: 3.0)
try! graph.addEdge("r", to: "b", weight: 2.0)
try! graph.addEdge("a", to: "b", weight: 2.0)
try! graph.addEdge("a", to: "c", weight: 4.0)
try! graph.addEdge("b", to: "c", weight: 3.0)
try! graph.addEdge("b", to: "e", weight: 5.0)
try! graph.addEdge("c", to: "d", weight: 8.0)
try! graph.addEdge("e", to: "d", weight: 5.0)

print(try! graph.weight("c", to: "d"))
print(try! graph.weight("b", to: "c"))
print(try! graph.weight("b", to: "d"))

let mst = primsSpanningTree(graph)
print("minimum spanning tree:")
print(mst.vertices)
print(mst.edges)
print(mst.totalWeight)
*/

// example dijkstra run from CLRS
let vertices = ["s", "t", "y", "x", "z"]
var graph = WeightedDirectedAList<String>(vertices: vertices)
let edges = [("s", "t", 10.0), ("s", "y", 5.0), ("t", "x", 1.0),
             ("t", "y", 2.0), ("y", "t", 3.0), ("y", "x", 9.0),
             ("y", "z", 2.0), ("z", "x", 6.0), ("z", "s", 7.0)]
for edge in edges {
    let (a, b, w) = edge
    try! graph.addEdge(a, to: b, weight: w)
}

var thing = dijkstraShortestPath(graph, start: "s", end: "x")
print(thing)

thing = dijkstraShortestPath(graph, start: "s", end: "z")
print(thing)

// example dijkstra run from youtube
let verts = [1, 2, 3, 4, 5, 6, 7]
let es = [(1, 2, 3.0), (1, 3, 5.0), (1, 4, 6.0), (2, 4, 2.0),
             (3, 4, 2.0), (3, 6, 3.0), (3, 7, 7.0), (3, 5, 6.0),
             (4, 6, 9.0), (5, 6, 5.0), (5, 7, 2.0), (6, 7, 1.0)]
var graph2 = WeightedUndirectedAList<Int>(vertices: verts)
for edge in es {
    let (a, b, w) = edge
    try! graph2.addEdge(a, to: b, weight: w)
}

var thing2 = dijkstraShortestPath(graph2, start: 1, end: 4)
print(thing2)
thing2 = dijkstraShortestPath(graph2, start: 1, end: 7)
print(thing2)

testInits()
testEdgesEqual()
testAddRemoveVertex()
