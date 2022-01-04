//: [Previous](@previous)

// bugs found
// off by one error in computing the cost mapping

import Foundation


let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let crabPositions = content.split(separator: ",").compactMap { String($0).trimmingCharacters(in:.whitespacesAndNewlines) }.map{Int($0)!}


//let crabPositions = [16,1,2,0,4,2,7,1,2,14]

let maxValue = crabPositions.reduce(Int.min, max)
let minValue = crabPositions.reduce(Int.max, min)

round(Double(crabPositions.reduce(0, +))/Double(crabPositions.count))

var cost = Array(repeating: 0, count: maxValue+1)
var runningCost = 0
for i in 0...maxValue {
  runningCost += i
  cost[i] = runningCost
}

var positions:[Int] = Array(repeating: 0, count: maxValue+1)

for i in 0...maxValue {
  positions[i] = crabPositions.map { cost[abs(i - $0)] }.reduce(0, +)
}

var bestPosition = 0
for i in 0...maxValue {
  let cumDistance = positions[i]
  if cumDistance < positions[bestPosition] {
    bestPosition = i
  }
}
bestPosition
positions[bestPosition]

//: [Next](@next)
