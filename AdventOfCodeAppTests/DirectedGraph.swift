//
//  DirectedGraph.swift
//  AdventOfCodeAppTests
//
//  Created by Jeffrey Wong on 12/31/21.
//

import Foundation

// A route is a sequence of node names
typealias Route = [String]

class Node: Hashable {

  let name: String
  var connections: [Node] = []
  
  var visits = 0
  
  init(name:String) {
    self.name = name
  }
  
  var isSmall: Bool { return name != name.uppercased()}
  
  var isStart: Bool { return name == "start"}
  var isEnd: Bool { return name == "end"}
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.name)
  }
  
  static func == (lhs: Node, rhs: Node) -> Bool {
    return lhs.name == rhs.name
  }

  
  
}
