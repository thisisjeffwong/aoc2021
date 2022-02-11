//
//  Day15.swift
//  AdventOfCodeAppTests
//
//  Created by Jeffrey Wong on 1/10/22.
//

import XCTest
import SwiftGraph
import PriorityQueueModule

class Node15: Hashable,Comparable, CustomStringConvertible {
  var description: String { get {
      return "(\(x),\(y)) \(distanceToOrigin)"
    }
  }
  
  
  static func < (lhs: Node15, rhs: Node15) -> Bool {
    if lhs.distanceToOrigin != rhs.distanceToOrigin {
      return lhs.distanceToOrigin < rhs.distanceToOrigin
    } else {
      return (lhs.x != rhs.x && lhs.x < rhs.x) || (lhs.y != rhs.y && lhs.y < rhs.y)
    }
  }
  
  static func == (lhs: Node15, rhs: Node15) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
  
  var hashValue: Int { get {
    return x * y
  }}
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }
  
  let x: Int  // Column
  let y: Int  // Row
  let value: Int
  
  var distanceToOrigin = Int.max
  var pathToOrigin: Node15? = nil
  
  var neighboring: [Node15] = []
  
  init(location:(Int, Int), value: Int) {
    self.x = location.0
    self.y = location.1
    self.value = value
  }
}


//class PreallocatedWeightedGraph: WeightedGraph<String,Int> {
//  override public func addVertex2(_ v: V) -> Int {
//      vertices.append(v)
//      var edgelist = [WeightedEdge<Int>]()
//      edgelist.reserveCapacity(8)
//      edges.append(edgelist)
//      return vertices.count - 1
//  }
//}


let neighbors = [(-1,0), (1,0), (0, -1), (0,1)]

class Map15: CustomStringConvertible {
  var description: String { get {
    var output = "Graph\n======\n"
    return output + graph.map { (row:[Node15]) -> String in
      return row.map { String($0.value) }.reduce("", +)
    }.reduce("") { partialResult, s in
      return "\(partialResult)\n\(s)"
    }
  }
  }
  
  let graph: [[Node15]]
  
  var goodGraph: FasterWeightedGraph!
  
  init(nodeArray:[[Int]]) {
    let maxX = nodeArray[0].count
    let maxY = nodeArray.count

    
    graph = (0..<maxY).map({ y in
      (0..<maxX).map { x in
        Node15(location: (x,y),
               value: nodeArray[y][x])
      }
    })
    
    
    // Connect the nodes
    graph.forEach { row in
      row.forEach { node in
        node.neighboring = neighbors.compactMap { (xDelta,yDelta) -> Node15? in
          let nextX = node.x + xDelta
          let nextY = node.y + yDelta
          guard nextX >= 0 && nextY >= 0 && nextX < maxX && nextY < maxY else { return nil }
          
          return graph[nextY][nextX]
        }
      }
    }
    
    
    var startTime = Date()
    
    goodGraph = FasterWeightedGraph(vertices:[])
    
    goodGraph.addVertices( graph.map({ row in
      row.map { String(describing: $0) } }).flatMap({$0}))
    
    var nextTime = Date()
    print(String(format: ">>> Node setup took %.4f seconds.", nextTime.timeIntervalSince(startTime)))
    startTime = nextTime

//    for i in 0..<goodGraph.edges.count {
//      goodGraph.edges[i].reserveCapacity(16)
//    }
//    nextTime = Date()
//    print(String(format: ">>> Edge storage reservation took %.4f seconds.", nextTime.timeIntervalSince(startTime)))
//    startTime = nextTime
//
    var rowNum = 0
    graph.forEach { row in
      row.forEach { node in
        node.neighboring.forEach { neighbor in
          goodGraph.addEdge2(from: String(describing: node),
                            to: String(describing: neighbor),
                            weight: neighbor.value,
                            directed: true)
        }
      }
      var nextTime = Date()
      print(String(format: ">>> row setup \(rowNum) took %.4f seconds.", nextTime.timeIntervalSince(startTime)))
      startTime = nextTime
      rowNum += 1
    }
//    print(">>> Edge setup took \(Date().timeIntervalSince(startTime) as Double) seconds.")
    
    nextTime = Date()
    print(String(format: ">>> Edge setup took %.4f seconds.", nextTime.timeIntervalSince(startTime)))
    startTime = nextTime
  }
  
  func nodeAt(x: Int, y:Int) -> Node15 {
    return graph[y][x]
  }
  
  func dijkstra(from: Node15, to: Node15) -> Int {
    let fromNode = String(describing: from)
    let toNode = String(describing: to)
    
    let startTime = Date()
    
    let (distances, pathDict) = goodGraph.dijkstra(root: fromNode, startDistance: 0)
    var _: [String: Int?] = distanceArrayToVertexDict(distances: distances,
                                                                 graph: goodGraph)
    // shortest distance from New York to San Francisco
    // path between New York and San Francisco
    let path: [WeightedEdge<Int>] = pathDictToPath(from: goodGraph.indexOfVertex(fromNode)!,
                                                   to: goodGraph.indexOfVertex(toNode)!,
                                                   pathDict: pathDict)
    
//    print("Dijkstra took \(Date().timeIntervalSince(startTime) as Double) seconds.")
    var nextTime = Date()
    print(String(format: ">>> Dijkstra took %.4f seconds.", nextTime.timeIntervalSince(startTime)))

    print("Path =====")
    print(path)
    return path.reduce(0) { partialResult, next in
      return partialResult + next.weight
    }
    
  }
}



class Day15: XCTestCase {
  
    // Bugs :
    //  failed to set upper bounds limits on neighbors
    //  selected endNode incorrectly
    //  did Djikstra's algorithm incorrectly by not tracking visited nodes
    func testExample() throws {
      let fileURL = Bundle.main.url(forResource: "Day 15 Input",
                                    withExtension: "txt")
      let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)
      let lines = content.split(separator: "\n")
      
      var caveMap: [[Int]] = []
      
      lines.forEach { line in
        let newLine: [Int] = line.map { Int(String($0))! }
        caveMap.append(newLine)
      }
      
      let theMap = Map15(nodeArray: caveMap)
      
      let origin = theMap.graph[0][0]
      let maxX = caveMap[0].count
      let maxY = caveMap.count
      let end = theMap.graph[maxY-1][maxX-1]
      
      let lowestRisk = theMap.dijkstra(from: origin, to: end)
      print(">>> lowest risk \(lowestRisk)")

      
//
//      origin.distanceToOrigin = 0
//
//      var visitQueue: SortedSet<Node15> = SortedSet()
//      theMap.graph.flatMap { $0 }.forEach { visitQueue.insert($0) }
//
//
//      while visitQueue.isEmpty == false {
//        let currentNode = visitQueue.removeFirst()
//        print ("visiting \(currentNode.x), \(currentNode.y)")
//
//
//        let neighborsToVisit = currentNode.neighboring.filter({ node in
//          let doesContain = visitQueue.contains(node)
//          return doesContain
//        })
//
//        for n in neighborsToVisit {
//          let currentDistance = currentNode.distanceToOrigin + n.value
//          if currentDistance < n.distanceToOrigin {
//            n.pathToOrigin = currentNode
//            n.distanceToOrigin = currentDistance
//            visitQueue.remove(n)
//            visitQueue.insert(n)
//          }
//        }
//      }
//
//      // Traverse nodes back from end
//      var path: [Node15] = []
//      var next: Node15? = end
//      while next != nil {
//        path.append(next!)
//        next = next!.pathToOrigin
//      }
//
//      path = path.reversed()
//      for p in path {
//        print("\(p.x), \(p.y)")
//      }
//
//      path = Array(path.suffix(from: 1))
//
//      print(String(describing: theMap))
//
//      print("Total Risk: \(path.map({ $0.value }).reduce(0, +))")
    }
  
  

}
