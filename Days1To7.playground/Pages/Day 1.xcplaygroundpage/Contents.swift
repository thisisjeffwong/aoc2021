//: [Previous](@previous)

import Foundation

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let lines = content.split(separator: "\n")

let numbers = lines.map { Int($0) }.compactMap { $0 }



func increases(numberList:[Int]) -> Int {
  var last: Int?
  var count = 0
  
  numberList.forEach {
    if let last = last {
      if $0 > last {
        count += 1
      }
    }
    last = $0
  }
  return count
}

increases(numberList: numbers)

var sums: [Int] = []
for i in 0..<(numbers.count-2) {
  let sum = numbers[i] + numbers[i+1] + numbers[i+2]
  sums.append(sum)
}

increases(numberList: sums)



//: [Next](@next)
