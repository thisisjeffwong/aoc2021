//: [Previous](@previous)

import Foundation

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let lines = content.split(separator: "\n")

let lineCount = lines.count

let length = lines[0].count
var oneCounts: [Int] = Array.init(repeating: 0, count: length)

let testString = "TestString"



func charToInt (_ char:Substring.Element) -> Int {
  return (char == "1")
    ? 1
    : 0
}

lines.forEach {
  let bits = $0.map(charToInt)
  
  for i in 0..<length {
    oneCounts[i] += bits[i]
  }
}

let gamma = oneCounts.map { Int(round(Float($0)/Float(lines.count))) }
gamma

let epsilon = gamma.map { ($0 == 1) ? 0 : 1 }
epsilon

let gammaValue = Int(gamma.map{String($0)}.reduce("", +), radix: 2)!
gammaValue
let epsilonValue = Int(epsilon.map{String($0)}.reduce("", +), radix: 2)!
epsilonValue

gammaValue * epsilonValue

func mostCommonBit(at position:Int, numbers:[Substring]) -> Int {
  let onesValue = numbers.map { Array(String($0))[position] }.map(charToInt).reduce(0, +)
  let onesRatio = Float(onesValue)/Float(numbers.count)
  return Int(round(onesRatio))
}


var remainingLines = lines
for i in 0..<length {
  let mostCommonBit = mostCommonBit(at: i,
                                    numbers: remainingLines)
  remainingLines = remainingLines.filter {
    charToInt(Array(String($0))[i]) == mostCommonBit
  }
}

var oxygenRating: Int?
if remainingLines.count == 1 {
  oxygenRating = Int(remainingLines[0], radix: 2)!
}
oxygenRating!




remainingLines = lines
for i in 0..<length {
  print (remainingLines)
  let mostCommonBit = mostCommonBit(at: i, numbers: remainingLines)
  
  
  remainingLines = remainingLines.filter {
    charToInt(Array(String($0))[i]) != mostCommonBit
  }
  if (remainingLines.count == 1) {
    break
  }
}

var co2Rating: Int?
if remainingLines.count == 1 {
  co2Rating = Int(remainingLines[0], radix: 2)!
}
co2Rating!

oxygenRating! * co2Rating!

//: [Next](@next)
