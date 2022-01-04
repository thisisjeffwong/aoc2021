//: [Previous](@previous)

import Foundation

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let lines = content.split(separator: "\n")

let numberSequence = lines[0].split(separator: ",").map {Int($0)!}

let pattern = #"""
(?xsim)
(?:^\s*(?:\d+\s*){5}$\n*){5}
"""#

let regex = try NSRegularExpression(pattern: pattern, options: [])
let nsrange = NSRange(content.startIndex..<content.endIndex,
                      in: content)

let matches = regex.matches(in: content, options: [], range: nsrange)
let boardTexts = matches.map {
  content[Range($0.range,in: content)!]
}

boardTexts.count
boardTexts

let numbersRegex = try! NSRegularExpression(pattern: #"\d+"#, options: [])

let rowNumbers = Array(0..<5)  // multiply base by 5 and add 5
let columnOffsets = rowNumbers.map { $0 * 5 }
let columnIndexesList = Array(0..<5).map { columnNumber in
  Array(0..<5).map { rowNumber in
    rowNumber*5 + columnNumber
  }
}

class Board {
  let boardString: String
  let rows: [Set<Int>]
  let columns: [Set<Int>]
  let boardId: String
  
  init(boardNumbers:String) {
    boardString = boardNumbers
    let matches = numbersRegex.matches(in: boardNumbers,
                                       options: [],
                                       range: NSRange(location: 0,
                                                      length: boardNumbers.count))
    let numbers = matches.map {
      Int(String(boardNumbers[Range($0.range, in:boardNumbers)!]))!
    }
    
    boardId = numbers[..<5].map{ String($0) }.joined(separator: " ")
    
    rows = Array(0..<5).map {
      let base = $0*5
      let end = base + 5
      return Set(numbers[base..<end])
    }
    columns = columnIndexesList.map({ indexList in
      Set(indexList.map {numbers[$0]})
    })
  }
  
  func debugDescription() -> String {
    return boardId
  }
  
  func winningPlay(playSequence:[Int]) -> (Int, Int)? {
    var numbersByRowLeft = rows
    var numbersByColumnLeft = columns
    
    for i in 0..<playSequence.count {
      let playedNumber = playSequence[i]
      numbersByRowLeft = numbersByRowLeft.map { $0.filter { $0 != playedNumber }
      }
      numbersByColumnLeft = numbersByColumnLeft.map { $0.filter { $0 != playedNumber } }
      
      if (numbersByRowLeft.contains { $0.isEmpty } ||
          numbersByColumnLeft.contains { $0.isEmpty }) {
        let rowResult = (numbersByRowLeft.reduce(0) { partialResult, row in
          partialResult + row.reduce(0, +)
        })
        let columnResult = (numbersByColumnLeft.reduce(0) { partialResult, column in
          partialResult + column.reduce(0, +)
        })
        
        if columnResult != rowResult {
          print("Board \(self.boardId) has different row and column results: \(rowResult), \(columnResult)")
        }
        
        return (i, playedNumber * columnResult )
      }
    }
    return nil
  }
}

columnIndexesList

let boards:[Board] = boardTexts.map {
  Board(boardNumbers: String($0))
}

let boardWins = boards.map { board in
  return (board, board.boardId, board.winningPlay(playSequence: numberSequence))
}

var winningBoards = boardWins.filter { (_, _, winningPlay) in
  winningPlay != nil
}

winningBoards.sort {
  let board1FinishTurn = $0.2!.0
  let board2FinishTurn = $1.2!.0
  
  if board1FinishTurn != board2FinishTurn {
    return board1FinishTurn < board2FinishTurn
  } else {
    let board1Score = $0.2!.1
    let board2Score = $1.2!.1
    return board1Score > board2Score
  }
}

winningBoards

winningBoards.forEach { (board:Board, boardId:String, outcome:(Int, Int)?) in
  print("board: \(boardId), outcome: \(outcome!)")
}

//: [Next](@next)
