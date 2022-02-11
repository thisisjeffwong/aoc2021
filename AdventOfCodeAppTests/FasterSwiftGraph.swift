//
//  FasterSwiftGraph.swift
//  AdventOfCodeAppTests
//
//  Created by Jeffrey Wong on 2/10/22.
//

import Foundation
import SwiftGraph


class FasterWeightedGraph: WeightedGraph<String, Int> {
  
  var fastIndexLookup: [String: Int] = [:]
  
  /// Add an edge to the graph.
  ///
  /// - parameter e: The edge to add.
  /// - parameter directed: If false, undirected edges are created.
  ///                       If true, a reversed edge is also created.
  ///                       Default is false.
  public func addEdge(_ e: WeightedEdge<W>) {
    edges[e.u].append(e)
  }
  
  public func addEdge2(from: String, to: String, weight: W, directed: Bool = false) {
    if let u = fastIndexLookup[from],
       let v = fastIndexLookup[to] {
        addEdge(fromIndex: u,
                toIndex: v,
                weight: weight,
                directed: directed)
    }
  }
  
  public func addVertices(_ vertices:[String]) {
    vertices.forEach {
      let index = addVertex($0)
      fastIndexLookup[$0] = index
    }
  }
  
  
}

