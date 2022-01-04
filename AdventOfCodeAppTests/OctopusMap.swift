//
//  OctopusMap.swift
//  AdventOfCodeAppTests
//
//  Created by Jeffrey Wong on 12/30/21.
//

import Foundation



class OctopusMap {
  var map: [[Int]]
  var flashes = 0

  init(map:[[Int]]){
    self.map = map
  }
  
  var width: Int { get { return map[0].count } }
  var height: Int { get { return map.count } }
  
  func stepIllumination () {
    for i in 0..<map.count {
      for j in 0..<map[i].count {
        map[i][j] += 1
      }
    }
  }
  
  func neighborsOfPoint(i:Int, j:Int) -> [Point] {
    let above = Point(row: i-1,column: j)
    let aboveLeft = Point(row: i-1,column: j-1)
    let aboveRight = Point(row: i-1,column: j+1)
    
    let left = Point(row: i,column: j-1)
    let right = Point(row: i,column: j+1)
    
    let below = Point(row: i+1,column: j)
    let belowLeft = Point(row: i+1,column: j-1)
    let belowRight = Point(row: i+1,column: j+1)

    let neighbors = [aboveLeft,above,aboveRight,
                     left, right,
                     belowLeft, below, belowRight]
    return neighbors.filter {
      ($0.row >= 0 && $0.row < height &&
       $0.column >= 0 && $0.column < width )}
  }
  
  func printMap() {
    for row in map {
      let lineText = row.map { String($0) }.joined(separator: "")
      print(lineText)
    }
  }
  
  
  
  func step() -> Bool{
    stepIllumination()
    
    var illuminationQueue: [Point] = []
    var resetQueue:[Point] = []
    // for each element at 10
    // illuminate neighbors recursively
    for i in 0..<height{
      for j in 0..<width{
        if map[i][j] == 10 {
          illuminationQueue.append(Point(row: i, column: j))
        }
      }
    }
    
    while illuminationQueue.count > 0 {
      let current = illuminationQueue.remove(at: 0)
      let neighbors = neighborsOfPoint(i: current.row,
                                       j: current.column)
      for n in neighbors {
        map[n.row][n.column] += 1
        if map[n.row][n.column] == 10 {
          illuminationQueue.append(n)
        }
      }
      flashes += 1
      resetQueue.append(current)
    }
    
    // zero all illuminated points
    for o in resetQueue {
      map[o.row][o.column] = 0
    }
    
    return resetQueue.count == width * height
  }
}
