//: [Previous](@previous)

/// Bugs experienced in this problem:
/// Incorrect syntax caused too large an exponent calculation


import Foundation

enum Orientation {
  case vertical, horizontal,diagonal
}

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let textlines = content.split(separator: "\n")

struct Point {
  let x: Int
  let y: Int
}

var scaleFactor = 1


var map: [Int:Int] = [:]

func markPoint(_ x:Int,_ y:Int) {
  //print ("markPoint \(x) \(y)")
  let address:Int = Int(pow(10, Double(scaleFactor)) * Double(x) + Double(y))
  
  let count = map[address, default: 0]
  map[address] = count + 1
  //print ("marked!")
}

func coordinatesFromCode(code:Int) {
  
}



struct Line {
  let start: Point
  let end: Point
  let orientation: Orientation
  
  func draw()  {
    
    switch orientation {
    case .vertical:
//      print("Drawing vertical \(start) to \(end)")
      let start = Int(min(self.start.y, self.end.y))
      let end = Int(max(self.start.y, self.end.y))
      Range(start...end).forEach { markPoint(self.start.x, $0) }
    case .horizontal:
//      print("Drawing horizontal \(start) to \(end)")
      let start = Int(min(self.start.x, self.end.x))
      let end = Int(max(self.start.x, self.end.x))
      Range(start...end).forEach { markPoint( $0,
                                             self.start.y)}
    case .diagonal:
//      print("Drawing diagonal \(start) to \(end)")
      
      let verticalChange = (self.start.y > self.end.y
                            ? -1
                            : 1)
      
      let horizontalChange = (self.start.x > self.end.x
                              ? -1
                              : 1)
      var x = self.start.x
      var y = self.start.y
      while (x != self.end.x && y != self.end.y) {
        markPoint(x, y)
        x += horizontalChange
        y += verticalChange
      }
      markPoint(self.end.x, self.end.y)
    }
  }
  
  func maxX() -> Int {
    return max(self.start.x, self.end.x)
  }
  
  func maxY() -> Int {
    return max(self.start.y, self.end.y)
  }
}

let lines: [Line] = textlines.map {
  let numbers = String($0).split(separator: ",").map { Int(String($0))!}
  let x1 = numbers[0]
  let y1 = numbers[1]
  let x2 = numbers[2]
  let y2 = numbers[3]
  
  let orientation: Orientation
  if (x1 == x2) {
    orientation = .vertical
  } else if (y1 == y2) {
    orientation = .horizontal
  } else {
    orientation = .diagonal
  }

  return Line(start: Point(x: x1, y: y1),
              end: Point(x: x2, y: y2),
              orientation: orientation)
}

var allMaxX = 0
for x in lines.map( { $0.maxX() }) {
  allMaxX = max(x, allMaxX)
}

allMaxX

var allMaxY = 0
for y in lines.map( { $0.maxY() }) {
  allMaxY = max(y, allMaxY)
}
allMaxY

scaleFactor = Int(ceil(log10(Double(max(allMaxX,allMaxY)))))
scaleFactor


lines.forEach { $0.draw() }


let hits = map.values.reduce(0) { partialResult, count in
  partialResult + ((count >= 2) ? 1 : 0)
}

hits



//: [Next](@next)
