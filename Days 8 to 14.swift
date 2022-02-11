//
//  AdventOfCodeAppTests.swift
//  AdventOfCodeAppTests
//
//  Created by Jeffrey Wong on 12/26/21.
//

import XCTest
import Foundation
@testable import AdventOfCodeApp

extension Collection where Element == Set<Character> {
  func intersection () -> Set<Character> {
    guard let first = self.first else { return Set() }
    
    return self.reduce(first) { partialResult, s in
      return partialResult.intersection(s)
    }
  }
  
  func union () -> Set<Character> {
    guard let first = self.first else { return Set() }
    return self.reduce(first) { partialResult, s in
      return partialResult.union(s)
    }
  }
}



struct Point: Hashable {
  let row: Int
  let column: Int
}


class AdventOfCodeAppTests: XCTestCase {


    func testDay8Part1() throws {
      
      let fileURL = Bundle.main.url(forResource: "Day 8 TestInput", withExtension: "txt")
      let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)

      let textInput = content.split(separator: "\n")
      let linesOfWords: [[String]] = textInput.map { line in
      //  print(line)
        let outputSegment = String(line.split(separator: "|")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        let words = outputSegment.split(separator: " ")
        return words.map {String($0)}
      }

      let words = linesOfWords.flatMap{$0}

      let count = words.map { word in
        switch word.count {
        case 2, 3,4,7:
          return 1
        default:
          return 0
        }
      }.reduce(0, +)
      
      print(">>> \(count)")
    }
  
  let digitDisplays: [String:String] = ["abcefg": "0",
                                     "cf":"1",
                                     "acdeg": "2",
                                     "acdfg":"3",
                                     "bcdf":"4",
                                     "abdfg":"5",
                                     "abdefg":"6",
                                     "acf":"7",
                                     "abcdefg":"8",
                                     "abcdfg":"9"]
  
  func produceMapping(codes:[String]) throws -> [Character:Character] {
    /*
     a: extra digit of 3 letter term when subtracting off 2 letter term
     b: element in only present in 1 5-letter term and the 4 letter term
        or, in all 6-letter terms, and in 4-term but not in the 2-term
     c: one of the 2 letter terms, 2/3 5-codes, 2/3 6-codes
     d: present in all 5-part items and in 4-part code
     e: not in 2, 3, or 4 part codes, 1/3 5-part codes, 2/3 six part codes
     f: one of the 2 letter terms, 2/3 5-codes, 3/3 6-codes
     g: in all codes except 2,3, or 4 part codes
     
     Number of segments per digit:
     0: 6
     1: 2
     2: 5
     3: 5
     4: 4
     5: 5
     6: 6
     7: 3
     8: 7
     9: 6
     */
    
    let codeSets = Set(codes.map { Set($0.sorted()) })
    
    let codeCounts = [2,3,4,5,6,7]
    let codesByCount = Dictionary(uniqueKeysWithValues: codeCounts.map({ length in
      (length, codeSets.filter({ $0.count == length }))
    }))
    
    var decoderDictionary: [Character:Character] = [:]
    
    guard let codeOf2 = codesByCount[2]?.first,
          let codeOf3 = codesByCount[3]?.first,
          let codeOf4 = codesByCount[4]?.first,
          let codesOf5 = codesByCount[5],
          let codesOf6 = codesByCount[6],
          let codeOf7 = codesByCount[7]?.first else {
            print("Missing a code in \(codesByCount)")
            XCTFail()
            return [:]
          }
    
    // Find A
    if let aMapping = codeOf3.symmetricDifference(codeOf2).first {
      decoderDictionary[aMapping] = "a"
    } else {
      XCTFail("Can't find 'a' mapping")
    }
        
    // Find B
    if codesOf6.count == 3 {
      let intersect6 = codesOf6.intersection()
      let intersect4 = intersect6.intersection(codeOf4)
      let cfRemoved = intersect4.subtracting(codeOf2)
      XCTAssertEqual(cfRemoved.count,1)
      let bMapping = cfRemoved.first!
      decoderDictionary[bMapping] = "b"
    } else if codesOf5.count == 3 {
      let allLetters = codesOf5.union()
      let bMapping = allLetters.filter { char in
        (codesOf5.filter({ $0.contains(char)}).count == 1 &&
         codeOf4.contains(char))
      }.first!
      decoderDictionary[bMapping] = "b"
    } else {
      XCTFail("Can't figure out \"b\" mapping!")
    }
    
    // Find C
    if codesOf6.count == 3 {
      let cOnly = codeOf2.filter { segment in
        codesOf6.filter { $0.contains(segment) }.count == 2
      }
      XCTAssertEqual(cOnly.count,1)
      let cMapping = cOnly.first!
      decoderDictionary[cMapping] = "c"
    } else {
      XCTFail("Can't figure out \"c\" mapping!")
    }
    
    // Find D
    if codesOf5.count == 3 {
      let dOnly = codeOf4.filter { segment in
        codesOf5.allSatisfy { $0.contains(segment) }
      }
      XCTAssertEqual(dOnly.count,1)
      decoderDictionary[dOnly.first!] = "d"
    } else {
      XCTFail("Can't figure out \"d\" mapping!")
    }
    
    // Find E
    if codesOf5.count == 3 {
      let notIt = [codeOf2, codeOf3, codeOf4].union()
      let remainingSegments = codesOf5.map { $0.subtracting(notIt) }.union()
      let eOnly = remainingSegments.filter { segment in
        codesOf5.filter { code in
          code.contains(segment)
        }.count == 1
      }
      XCTAssertEqual(eOnly.count,1)
      decoderDictionary[eOnly.first!] = "e"
    }
    
    // Find F
    if codesOf6.count == 3 {
      let fOnly = codeOf2.filter { segment in
        codesOf6.allSatisfy { $0.contains(segment) }
      }
      XCTAssertEqual(fOnly.count,1)
      decoderDictionary[fOnly.first!] = "f"
    }
    
    // Find G
    let notIt = [codeOf2, codeOf3, codeOf4].union()
    let gOnly = codeOf7.subtracting(notIt).filter { segment in
      (codesOf6.union(codesOf5)).allSatisfy { $0.contains(segment) }
    }
    XCTAssertEqual(gOnly.count,1)
    decoderDictionary[gOnly.first!] = "g"
    
    return decoderDictionary
  }
  
  func testProduceMapping() throws {
    let codeSequences = ["acedgfb", "cdfbe", "gcdfa", "fbcad", "dab", "cefabd", "cdfgeb",
                         "eafb", "cagedb", "ab", "cdfeb", "fcadb", "cdfeb", "cdbaf"]
    let decodeMapping = try! produceMapping(codes: codeSequences)
    XCTAssertEqual(decodeMapping["d"], "a")
    XCTAssertEqual(decodeMapping["e"],"b")
    XCTAssertEqual(decodeMapping["a"],"c")
    XCTAssertEqual(decodeMapping["f"], "d")
    XCTAssertEqual(decodeMapping["g"],"e")
    XCTAssertEqual(decodeMapping["b"],"f")
    XCTAssertEqual(decodeMapping["c"],"g")
  }
  
  
  func decodeStringOutput(code:String) -> (Int) {
    // break into input and output
    let halves = code.split(separator: "|").map { spacedString in
      spacedString.split(separator: " ").map { String($0) }
    }
    
    let input:[String] = halves[0]
    let output:[String] = halves[1]
    
    // Map each code-letter to the real segment name
    let mapping = try! produceMapping(codes: input+output)
    
    // Apply mapping to output digits
    let correctedCodes = output.map { code in
      String(code.map { char in mapping[char]! }.sorted())
    }
    
    // Apply standard mapping to corrected codes.
    let number: String = correctedCodes.map { code in
      digitDisplays[code]!
    }.reduce("", +)
    
    return Int(number)!
  }
  
  
  func testDay8Part2() throws {
    
    let fileURL = Bundle.main.url(forResource: "Day 8 Input", withExtension: "txt")
    let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)

    let textInput = content.split(separator: "\n").map{String($0)}
    let outputNumbers: [Int] = textInput.map { line in
      decodeStringOutput(code: line)
    }
    
    let sum = outputNumbers.reduce(0, +)
    
    print(">>> \(sum)")
  }
  
  func testDay9Part1() throws {
    
    let fileURL = Bundle.main.url(forResource: "Day 9 Input", withExtension: "txt")
    let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    
    let textInput = content.split(separator: "\n").map{String($0)}
    let caveMap: [[Int]] = textInput.map { line in
      line.map { digit in Int(String(digit))! }
    }
    
    let caveWidth = caveMap.first!.count
    let caveLength = caveMap.count
    
    var lowPoints:[Int] = []
    for i in 0..<caveLength {
      for j in 0..<caveWidth {
        let above = (i > 0
                     ? caveMap[i-1][j]
                     : Int.max)
        let below = (i < caveLength - 1
                     ? caveMap[i+1][j]
                     : Int.max)
        let left = (j > 0
                    ? caveMap[i][j-1]
                    : Int.max)
        let right = (j < caveWidth - 1
                     ? caveMap[i][j+1]
                     : Int.max)
        let height = caveMap[i][j]
        if height < above,
           height < below,
           height < left,
           height < right {
          lowPoints.append(height)
        }
      }
    }
    let riskSum = lowPoints.map { $0 + 1 }.reduce(0, +)
    
    print(">>> riskSum: \(riskSum)")
  }


  class CaveMap {
    let map: [[Int]]
    var basinMarkings: [[Int?]]
    
    init(map:[[Int]]) {
      self.map = map
      basinMarkings = []
      for row in map {
        basinMarkings.append(Array(repeating: nil, count: row.count))
      }
    }
    
    func basinNeighbors(of location:Point) -> [Point] {
      let caveWidth = self.map.first!.count
      let caveLength = self.map.count

      let i = location.row
      let j = location.column
      
      let above = (i > 0
                   ? Point(row: i-1,column: j)
                   : nil)
      let below = (i < caveLength - 1
                   ? Point(row: i+1,column: j)
                   : nil)
      let left = (j > 0
                  ? Point(row: i,column: j-1)
                  : nil)
      let right = (j < caveWidth - 1
                   ? Point(row: i,column: j+1)
                   : nil)
      
      return [above, below, left, right].compactMap{$0}.filter { self.map[$0.row][$0.column] < 9
      }
    }
    
    func height(at point:Point) -> Int {
      return map[point.row][point.column]
    }
    
    func basinNumber(for point:Point) -> Int? {
      return basinMarkings[point.row][point.column]
    }
    
    func markBasinNumber(for point:Point,
                         with basinNumber:Int) {
      precondition(basinMarkings[point.row][point.column] == nil)
      basinMarkings[point.row][point.column] = basinNumber
    }
    
    /// @return size of discovered basin
    func enumerateBasin(starting startingPoint:Point,
                        with basinNumber:Int) -> Int{
      var visitQueue = [startingPoint]
      var basinSize = 0
      while visitQueue.isEmpty == false {
        let currentPoint = visitQueue.remove(at: 0)
        if self.basinNumber(for: currentPoint) != nil {
          continue
        }
        basinSize += 1
        markBasinNumber(for:currentPoint,
                        with: basinNumber)
        let nextPoints = basinNeighbors(of: currentPoint).filter { self.basinNumber(for: $0) == nil }
        visitQueue.append(contentsOf: nextPoints)
      }
      return basinSize
    }
    
  }
  
  
  
  func testDay9Part2() throws {
    // Mistakes: forgot to avoid doubling back especially in the queue
    // - typo of accident using the starting point of a basin when enumerating over basins
    // - in basin enumeration did not account for
    //   locations that are placed in the queue more than once
    
    
    let fileURL = Bundle.main.url(forResource: "Day 9 Input", withExtension: "txt")
    let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    
    let textInput = content.split(separator: "\n").map{String($0)}
    let caveMap = CaveMap(map:textInput.map { line in
      line.map { digit in Int(String(digit))! }
    })
      
    var basinSizes: [Int] = []
    for i in 0..<caveMap.map.count {
      for j in 0..<caveMap.map[0].count {
        let possibleBasinStart = Point(row: i, column: j)
        if caveMap.basinNumber(for: possibleBasinStart) == nil &&
           caveMap.height(at: possibleBasinStart) < 9 {
          let basinSize = caveMap.enumerateBasin(starting: possibleBasinStart,
                                                 with: basinSizes.count)
          basinSizes.append(basinSize)
        }
      }
    }
    
    basinSizes.sort()
    let top3BasinSizes = basinSizes.suffix(3)
    let basinProduct = top3BasinSizes.reduce(1, *)
    
    print(">>> risk Product: \(basinProduct)")
  }

  func linesFrom(file fileName:String) throws -> [String] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    
    return content.split(separator: "\n").map{String($0)}
  }
  
  
  
  func firstIllegalCharacter(in line:String) -> Character? {
    let pairings: [Character:Character] = [")": "(","]":"[","}":"{",">": "<"]
    var stack:[Character] = []
    for char in line {
      switch char {
      case "(","[","{","<":
        stack.append(char)
      case ")","]","}",">":
        if let popped = stack.popLast(),
           popped != pairings[char] {
          return char
        }
      default:
        XCTFail()
      }
    }
    return nil
  }

  func lineIsIncomplete(_ line:String) -> Bool {
    let pairings: [Character:Character] = [")": "(","]":"[","}":"{",">": "<"]
    var stack:[Character] = []
    for char in line {
      switch char {
      case "(","[","{","<":
        stack.append(char)
      case ")","]","}",">":
        if let popped = stack.popLast(),
           popped != pairings[char] {
          return false
        }
      default:
        XCTFail()
      }
    }
    return stack.isEmpty == false
  }

  class InvalidInputError: Error {}
  
  func autoCompleteScore(for line:String) throws -> Int {
    let pairings: [Character:Character] = [")": "(","]":"[","}":"{",">": "<"]
    var stack:[Character] = []
    for char in line {
      switch char {
      case "(","[","{","<":
        stack.append(char)
      case ")","]","}",">":
        if let popped = stack.popLast(),
           popped != pairings[char] {
          throw InvalidInputError()
        }
      default:
        XCTFail()
      }
    }
    let scoring = ["(": 1, "[":2, "{":3, "<":4]
    return stack.reversed().map { scoring[String($0)]! }.reduce(0) { partialResult, next in
      partialResult * 5 + next
    }
  }
  
  
  
  func testDay10Part1() throws {
    let inputLines = try linesFrom(file: "Day 10 Input")
    
    let scoring: [Character:Int] = [")": 3,"]":57,"}":1197,">": 25137]
    
    let totalScore = inputLines.map{firstIllegalCharacter(in:$0)}.compactMap { $0 }.map { scoring[$0]! }.reduce(0, +)
    
    print(">>> \(totalScore)")
  }
  
  func testDay10Part2() throws {
    let inputLines = try linesFrom(file: "Day 10 Input")
  
    let incompleteLines = inputLines.filter { lineIsIncomplete($0) }
    var completionScores =  incompleteLines.map { try! autoCompleteScore(for: $0)
    }
    
    completionScores.sort()
    let middleIndex = floor(Double(completionScores.count) / Double(2))
    let middleScore = completionScores[Int(middleIndex)]
    print(">>> middle score is: \(middleScore)")
  }
  
  
  func testDay11Part1() throws {
    // Bugs: forgot to allow 0 as an index for finding neighbors
    
    let inputLines = try linesFrom(file: "Day 11 Input")
    let octoMap = OctopusMap(map:inputLines.map { $0.map { c in Int(String(c))! } })
    
    for _ in 0..<100 {
      _ = octoMap.step()
    }
    
    print(">>> flashCount is: \(octoMap.flashes)")
  }
  
  func testDay11Part2() throws {
    let inputLines = try linesFrom(file: "Day 11 Input")
    let octoMap = OctopusMap(map:inputLines.map { $0.map { c in Int(String(c))! } })
    var stepNumber = 1
    while true {
      if octoMap.step() {
        break
      }
      stepNumber += 1
    }
    
    print(">>> step is: \(stepNumber)")
  }
  
  
  
  func testDay12Part1() throws {
    // Basically worked on the first try!
    let inputLines = try linesFrom(file: "Day 12 Input")
    var graph: [String: Node] = [:]
    
    inputLines.forEach {
      let pair = $0.split(separator: "-")
      let startName = String(pair[0])
      let startNode = graph[startName,
                            default: Node(name: startName)]
      graph[startName] = startNode
      let endName = String(pair[1])
      let endNode = graph[endName,
                          default: Node(name: endName)]
      graph[endName] = endNode
      
      startNode.connections.append(endNode)
      endNode.connections.append(startNode)
    }
    
    var completedPaths = [[String]]()
    var pathQueue = [[String]]()
    
    pathQueue.append(["start"])
    while pathQueue.count > 0 {
      let currentPath = pathQueue.remove(at: 0)
      let endNode = graph[currentPath.last!]!
      
      for connection in endNode.connections {
        let unvisitedSmallRoom = (connection.isSmall &&
                                  currentPath.contains(connection.name) == false)
        let largeRoom = connection.isSmall == false
        
        if unvisitedSmallRoom || largeRoom {
          let continuePath = currentPath + [connection.name]
          if connection.name == "end" {
            completedPaths.append(continuePath)
          } else {
            pathQueue.append(continuePath)
          }
        }
      }
    }
    completedPaths.sort { a, b in
      return a.joined(separator: "") > b.joined(separator: "")
    }
    
    print (">>> completed paths: \(completedPaths.count)")
    print (">>> \(completedPaths)")
  }
  
  
  // Returns paths to
  func navigateGraph(from node:Node) -> [Route] {
    if node.name == "start" && node.visits > 0 { return []}
    
    guard ((node.isSmall == false)
           || (node.isSmall && (node.visits < 1
                                || (specialNode == node && node.visits < 2))))
      else { return [] }
    
    if node.name == "end" {
      return [[node.name]]
    }
    
    node.visits += 1
    
    var routesToEnd: [Route] = []
    for connection in node.connections {
      routesToEnd += navigateGraph(from: connection)
    }
    
    node.visits -= 1
    
    return routesToEnd.map { return [node.name] + $0 }
  }
  
  var specialNode: Node?
  
  
  func testDay12Part2() throws {
    // Forgot to ignore the start
    //
    let inputLines = try linesFrom(file: "Day 12 Input")
    var graph: [String: Node] = [:]
    
    inputLines.forEach {
      let pair = $0.split(separator: "-")
      let startName = String(pair[0])
      let startNode = graph[startName,
                            default: Node(name: startName)]
      graph[startName] = startNode
      let endName = String(pair[1])
      let endNode = graph[endName,
                          default: Node(name: endName)]
      graph[endName] = endNode
      
      startNode.connections.append(endNode)
      endNode.connections.append(startNode)
    }
    
    var completedPaths = [[String]]()
//    var pathStack = [Node]()
//    var deadEndCount = 0
    
    let smallRooms = graph.values.filter {
      $0.isSmall && !$0.isStart && !$0.isEnd
    }
    
    let startNode = graph["start"]!
    
    for smallRoom in smallRooms {
      specialNode = smallRoom
      completedPaths.append(contentsOf: navigateGraph(from: startNode))
    }
    completedPaths.sort { a, b in
      return a.joined(separator: "") > b.joined(separator: "")
    }
    
    let pathSet = Set(completedPaths)
    
    print (">>> completed paths: \(pathSet.count)")
    
//    completedPaths.forEach {
//      print($0.joined(separator: ","))
//    }
//    print (">>> deadEndCount: \(deadEndCount)")
  }
  
  func foldAboutX(x: Int, points:[Point]) -> [Point] {
    let flippingPoints = points.filter { $0.column > x }
    let nonFlippingPoints = points.filter { $0.column <= x }
    
    let flippedPoints = flippingPoints.map { (point:Point) -> Point in
      let newX = -(point.column - x) + x
      return Point(row: point.row, column: newX)
    }
    return Array(Set(flippedPoints + nonFlippingPoints))
  }
  
  func foldAboutY(y: Int, points:[Point]) -> [Point] {
    let flippingPoints = points.filter { $0.row > y }
    let nonFlippingPoints = points.filter { $0.row <= y }
    let flippedPoints = flippingPoints.map { (point:Point) -> Point in
      let newY = -(point.row - y) + y
      return Point(row: newY, column: point.column)
    }
    return Array(Set(flippedPoints + nonFlippingPoints))
  }
  
  func printPoints(_ points:[Point]) {
    let maxX = points.map { $0.column }.reduce(0, max)
    let maxY = points.map { $0.row }.reduce(0, max)
    
    let setPoints = Set(points)
    for y in 0...maxY {
      let lineString = Range(0...maxX).map {
        return (setPoints.contains(Point(row:y, column:$0))
                ?    "#" : ".")
      }
      print(lineString.joined(separator: ""))
    }
  }
  
  
  func testDay13Part1() throws {
    let inputLines = try linesFrom(file: "Day 13 Input")
    let coordinates = inputLines.filter { $0.range(of: #"^\d+"#,
                                                   options: .regularExpression) != nil // true
    }
    let instructions = inputLines.filter{ $0.starts(with: "fold")}
    
    var points: [Point] = coordinates.map {
      let parts = $0.split(separator: ",")
      let x = Int(parts[0])!
      let y = Int(parts[1])!
      return Point(row: y, column: x)
    }
    
    for instruction in instructions {
      let numberRange = instruction.range(of: #"\d+$"#,
                                          options: .regularExpression)!
      let number = Int(String(instruction[numberRange]))!
      
      if instruction.range(of: "x=") != nil {
        points = foldAboutX(x: number, points: points)
      } else {
        points = foldAboutY(y: number, points: points)
      }
    }
          print("-----")
          printPoints(points)
//          break


    print("-----")
    print ("Dots count = \(points.count)")
    print("-----")
  }
  
  struct TemplateStep {
    let condition: String
    let insertion: String
  }
  
  func apply(template: [String:Character], input:String) -> String {
    var insertions: [(Int, Character)] = []
    
    for insertionPoint in 1..<(input.count) {
      let start = input.index(input.startIndex,
                              offsetBy: insertionPoint-1)
      let end = input.index(input.startIndex,
                            offsetBy: insertionPoint)
      let key = String(input[start...end])
      if let insertChar = template[key] {
        insertions.append((insertionPoint, insertChar))
      }
    }
    
    var returnString = input
    for insertion in insertions.reversed() {
      let insertionPoint = insertion.0
      let character = insertion.1
      returnString.insert(character,
                          at:returnString.index(returnString.startIndex,
                            offsetBy: insertionPoint))
    }
    return returnString
  }
  
  func countCharacters(string: String) -> [Character: Int] {
    
    var count: [Character: Int] = [:]
    for c in string {
      count[c, default: 0] += 1
    }
    return count
  }
  
  func testDay14Part1() throws {
    let inputLines = try linesFrom(file: "Day 14 TestInput")
    let startString = inputLines[0]
    let templateLines = inputLines[1..<inputLines.count]
    
    let templateSteps = Dictionary(uniqueKeysWithValues: templateLines.map { lineText -> (String, Character) in
      let conditionRange = lineText[lineText.startIndex...].range(of: #"^\w+"#,
                                  options: .regularExpression)!
      let insertionRange = lineText[lineText.startIndex...].range(of: #"\w+$"#,
                                          options: .regularExpression)!
      let condition = String(lineText[conditionRange])
      let insertChar = lineText[insertionRange.lowerBound]
      
      return (condition, insertChar)
    })
    
    var afterStep:String = startString
    for step in Range(1...40) {
      let startTime = Date()
      afterStep = apply(template: templateSteps, input: afterStep)
      let timeElapsed = String(format: "%.2f", -startTime.timeIntervalSinceNow)
//      print("string is now: \(afterStep)")

      print("length after step \(step) is \(afterStep.count). Time was \(timeElapsed) sec")
    }
    
    let theCount = countCharacters(string: afterStep)
    let most = theCount.values.reduce(0) { max($0,$1) }
    let least = theCount.values.reduce(most)  { min($0,$1) }
    
    print(">>> product \(most-least)")
  }
  
  func testDay14Part2() throws {
    let inputLines = try linesFrom(file: "Day 14 Input")
    let startString = inputLines[0]
    let templateLines = inputLines[1..<inputLines.count]
    
    // Make Template
    let templateSteps = Dictionary(uniqueKeysWithValues: templateLines.map { lineText -> (String, Character) in
      let conditionRange = lineText[lineText.startIndex...].range(of: #"^\w+"#,
                                  options: .regularExpression)!
      let insertionRange = lineText[lineText.startIndex...].range(of: #"\w+$"#,
                                          options: .regularExpression)!
      let condition = String(lineText[conditionRange])
      let insertChar = lineText[insertionRange.lowerBound]
      
      return (condition, insertChar)
    })
    
    
    // Setup initial representation of string
    var monomerCounts: [String:Int] = [:]
    templateSteps.keys.forEach { monomerCounts[$0] = 0 }

    
    var startIndex = startString.startIndex
    var endIndex = startString.index(after: startIndex)
    while endIndex < startString.endIndex {
      let monomer = startString[startIndex...endIndex]
      monomerCounts[String(monomer)]! += 1
      startIndex = endIndex
      endIndex = startString.index(after: startIndex)
    }
    
    // Setup overcount array
    var overCounts: [Character:Int] = [:]
    templateSteps.values.forEach { overCounts[$0] = 0 }
    // Include overcounts in initial setup
    
    for char in startString[startString.index(after: startString.startIndex)..<startString.index(before:startString.endIndex)] {
      overCounts[char]! += 1
    }
    
    for step in Range(1...40) {
      var nextMonomerCounts: [String:Int] = [:]
      templateSteps.keys.forEach { nextMonomerCounts[$0] = 0 }
      
      monomerCounts.forEach { key,value in
        let new = templateSteps[key]!
        let monomer1 = "\(String(key[key.startIndex]))\(String(new))"
        let monomer2 = "\(String(new))\(String(key[key.index(after: key.startIndex)]))"
        
        overCounts[new]! += value
        nextMonomerCounts[monomer1]! += value
        nextMonomerCounts[monomer2]! += value
      }
      
      monomerCounts = nextMonomerCounts
      
      let monomerTotal = monomerCounts.values.reduce(0, +)
      let overCountTotal = overCounts.values.reduce(0, +)
      
      let characterLength = monomerTotal - overCountTotal
      print("length after step \(step) is \(characterLength)")
    }
    
    var finalCounts: [Character:Int] = [:]
    templateSteps.values.forEach { finalCounts[$0] = 0 }
    
    monomerCounts.forEach { monomer, count in
      let headElement = monomer[monomer.startIndex]
      let tailElement = monomer[monomer.index(after:monomer.startIndex)]
      finalCounts[headElement]! += count
      finalCounts[tailElement]! += count
    }
    
    finalCounts.keys.forEach { finalCounts[$0]! -= overCounts[$0]! }
    let most = Int(finalCounts.values.max()!)
    let least = Int(finalCounts.values.min()!)
    
    print(">>> product \(most-least)")
  }
  
  
  
}
