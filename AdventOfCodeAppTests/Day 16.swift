//
//  Day 16.swift
//  AdventOfCodeAppTests
//
//  Created by Jeffrey Wong on 1/22/22.
//

import XCTest

class Day_16: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testPart1() throws {
      let fileURL = Bundle.main.url(forResource: "Day 16 Input",
                                    withExtension: "txt")
      let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
