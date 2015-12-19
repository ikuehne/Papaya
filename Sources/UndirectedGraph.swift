/**
 This file defines a protocol for an undirected graph object.
 */

/**
 An undirected graph is just a general graph, but with the requirement
 that adjacency is symmetric, so that if (v, v') is an edge, (v', v) is too.
 */
public protocol UndirectedGraph: Graph {

}
