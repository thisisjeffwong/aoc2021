//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let lines = content.split(separator: "\n")

let forwards = lines.filter { $0.starts(with: "forward")}
let depth = lines.filter { !$0.starts(with: "forward")}

func part1Distance ( forwards:[String], depth:[String]) -> Int {
  let horizontal = forwards.map {
    Int($0.split(separator: " ")[1])!
  }.reduce(0, +)

  let vertical = depth.map {
    let pair = $0.split(separator: " ")
    let direction: String = String(pair[0])
    let magnitude: Int = Int(String(pair[1]))!

    return (direction == "up"
            ? (0 - magnitude)
            : magnitude)
  }.reduce(0, +)

  return vertical * horizontal
}

//: Part 2

func part2Distance (lines: [String]) -> Int {
  var aim = 0
  var horizontal = 0
  var vertical = 0
  
  lines.forEach {
    let pieces = $0.split(separator: " ")
    let type = String(pieces[0])
    let distance = Int(String(pieces[1]))!
    
    if type == "forward" {
      horizontal += distance
      vertical += aim * distance
    } else if type == "up" {
      aim -= distance
    } else if type == "down" {
      aim += distance
    }
  }
  
  return horizontal * vertical
}
 
part2Distance(lines: lines.map({
  String($0) }))

//: [Next](@next)
