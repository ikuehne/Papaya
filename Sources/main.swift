/**
 Executable tests for the Papaya graph package
 */
 
// How I image it will work:
// import XCTest

let names = ["Kevin Bacon", "Nets Katz", "Paul Erdos", "Natalie Portman",
             "MC Bat Commander"]

var graph = UndirectedAMatrix(vertices: names)

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

do {
    try graph.addVertex("Ian Kuehne")
} catch {
    print("couldn't add ian for some reason.")
}
