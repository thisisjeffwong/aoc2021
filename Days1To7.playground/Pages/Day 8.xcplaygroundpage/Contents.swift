//: [Previous](@previous)

import Foundation

let fileURL = Bundle.main.url(forResource: "TestInput", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)

let textInput = content.split(separator: "\n")
let linesOfWords: [[String]] = textInput.map { line in
//  print(line)
  let outputSegment = String(line.split(separator: "|")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
  let words = outputSegment.split(separator: " ")
  return words.map {String($0)}
}

let words = linesOfWords.flatMap{$0}

words.map { word in
  switch word.count {
  case 2, 3,4,7:
    return 1
  default:
    return 0
  }
}.reduce(0, +)


//: [Next](@next)
