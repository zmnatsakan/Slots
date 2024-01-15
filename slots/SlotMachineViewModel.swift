//
//  SlotMachineViewModel.swift
//  slots
//
//  Created by mnats on 27.12.2023.
//

import SwiftUI


final class SlotMachineViewModel: ObservableObject {
    @Published var slotColumnsVM: [SlotColumnViewModel] = []
    @Published var slotColumnSize: CGFloat = 100
    @Published var rows = 3
    
    @Published var isResultPresented = false
    @Published var guaranteedWin = false
    @Published var guaranteedLose = false
    
    var winFlags = [[Bool]]()
    var winLines = [[(Int, Int)]]()
    
    func generateLines(startingAt row: Int, col: Int) -> [[(Int, Int)]] {
        var lines = [[(row, col)]]
        var extendedLines = [[(row, col)]]
        let rowCount = resultSlots.count
        let colCount = resultSlots[0].count
        
        // Extend each line until it has 5 elements, moving right and diagonally
        while let line = extendedLines.popLast() {
            if line.count == colCount {
                lines.append(line)
                continue
            }
            
            let (lastRow, lastCol) = line.last!
            
            // Move right if possible
            if lastCol + 1 < colCount {
                extendedLines.append(line + [(lastRow, lastCol + 1)])
            }
            
            // Move diagonally up if possible
            if lastRow - 1 >= 0 && lastCol + 1 < colCount {
                extendedLines.append(line + [(lastRow - 1, lastCol + 1)])
            }
            
            // Move diagonally down if possible
            if lastRow + 1 < rowCount && lastCol + 1 < colCount {
                extendedLines.append(line + [(lastRow + 1, lastCol + 1)])
            }
        }
        
        return lines.filter { $0.count == colCount }
    }
    
    func setWinFlags() {
        let result = resultSlots
        
        let rowCount = result.count
        let colCount = result[0].count
        var winFlags = Array(repeating: Array(repeating: false, count: colCount), count: rowCount)
        
        // Helper function to generate all lines of length 5 starting from each position

        
        // Generate all possible lines
        var allLines = [[(Int, Int)]]()
        for row in 0..<rowCount {
            allLines += generateLines(startingAt: row, col: 0)
        }
        
        // Check each line for a win
        for line in allLines {
            let lineValues = line.map { result[$0.0][$0.1] }
            if Set(lineValues).count == 1 {
                // Mark winning symbols
                winLines.append(line)
                for (row, col) in line {
                    winFlags[row][col] = true
                }
            }
        }
        
        self.winFlags = winFlags
    }
    
    var resultSlots: [[Int]] {
        var result = [[Int]]()
        for row in 0..<rows {
            result.append([])
            for column in 0..<slotColumnsVM.count {
                result[row].append(slotColumnsVM[column].slots[row])
            }
        }
        return result
    }
    
    init(columns: Int = 3, rows: Int = 3, columnSize: CGFloat = 100) {
        setupSlots(columns: columns, rows: rows, columnSize: columnSize)
    }
    
    func setupSlots(columns: Int = 3, rows: Int = 3, columnSize: CGFloat = 100) {
        isResultPresented = false
        slotColumnsVM = []
        self.rows = rows
        self.slotColumnSize = columnSize
        for _ in 0..<columns {
            slotColumnsVM.append(SlotColumnViewModel(size: columnSize))
        }
    }
    
    @MainActor func spin() async {
        var allLines = [[(Int, Int)]]()
        for row in 0..<rows {
            allLines += generateLines(startingAt: row, col: 0)
        }
        
        let winningLine = allLines.randomElement()!
        
        winFlags = [[Bool]]()
        winLines = [[(Int, Int)]]()
        isResultPresented = false
        
        await withTaskGroup(of: Void.self) { group in
            if guaranteedWin {
                let winningTile = Int.random(in: 1...7)
                var array = Array(1...7)
                array.removeAll(where: { $0 == winningTile })
                
                for column in 0..<slotColumnsVM.count {
                    for row in 0..<slotColumnsVM[column].slots.count {
                        if winningLine.contains(where: { $0.0 == row && $0.1 == column }) {
                            slotColumnsVM[column].slots[row] = winningTile
                        } else {
                            slotColumnsVM[column].slots[row] = array.randomElement()!
                        }
                    }
                    group.addTask {
                        await self.slotColumnsVM[column].spin(count: 70, initialTimeInterval: 0.02)
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
                
            } else {
                for slotColumn in slotColumnsVM {
                    for i in 0..<slotColumn.slots.count {
                        slotColumn.slots[i] = Int.random(in: 1...7)
                    }
                    group.addTask {
                        await slotColumn.spin(count: 70, initialTimeInterval: 0.02)
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
            }
        }
        try? await Task.sleep(nanoseconds: 500_000_000)
        print(resultSlots)
        setWinFlags()
        print(winLines)
        isResultPresented = true
    }
}

#Preview {
    ContentView()
}
