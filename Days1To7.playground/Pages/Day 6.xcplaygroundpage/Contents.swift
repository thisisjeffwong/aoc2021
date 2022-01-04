//: [Previous](@previous)

/// Bugs encountered while solving:
/// * Did not check for carriage return on input when parsing last number into an Int

import Foundation

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let textInput = content.split(separator: ",").compactMap { String($0).trimmingCharacters(in:.whitespacesAndNewlines) }.map{Int($0)!}

var lanternFish = [3,4,3,1,2]

var lanternFishWithTimerX = Array(repeating: 0, count: 9)

textInput.forEach {
  lanternFishWithTimerX[$0] += 1
}


func passTime() {
  for i in 0..<lanternFish.count {
    let timer = lanternFish[i]
    if timer == 0 {
      lanternFish.append(8)
      lanternFish[i] = 6
    } else {
      lanternFish[i] -= 1
    }
  }
}

func passTimeCompact (timerArray:[Int]) -> [Int] {
  var fishAtTime = Array(repeating: 0, count: 9)
  
  for i in 0...7 {
    fishAtTime[i] = timerArray[i+1]
  }
  
  let fishSpawning = timerArray[0]
  fishAtTime[6] += fishSpawning
  fishAtTime[8] += fishSpawning
  
  return fishAtTime
}

var currentPopulation = lanternFishWithTimerX

for i in 1...256 {
  currentPopulation = passTimeCompact(timerArray: currentPopulation)
  let fishCount = currentPopulation.reduce(0, +)
  print("After \(i) days: \(fishCount) fish")
}

//: [Next](@next)
