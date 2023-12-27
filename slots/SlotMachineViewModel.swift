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
    
    var winFlags: [[Bool]] {
        let result = resultSlots
        
        let rowCount = result.count
        let colCount = result[0].count
        var winFlags = Array(repeating: Array(repeating: false, count: colCount), count: rowCount)
        
        // Helper function to generate all lines of length 5 starting from each position
        func generateLines(startingAt row: Int, col: Int) -> [[(Int, Int)]] {
            var lines = [[(row, col)]]
            var extendedLines = [[(row, col)]]
            
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
                for (row, col) in line {
                    winFlags[row][col] = true
                }
            }
        }
        
        return winFlags
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
        for _ in 0..<columns {
            self.slotColumnsVM.append(SlotColumnViewModel(size: columnSize))
        }
        self.rows = rows
        self.slotColumnSize = columnSize
    }
    
    @MainActor func spin() {
        Task {
            isResultPresented = false
            for slotColumn in slotColumnsVM {
                for i in 0..<slotColumn.slots.count {
                    slotColumn.slots[i] = Int.random(in: 1...3)
                }
                slotColumn.spin(count: 70, initialTimeInterval: 0.02)
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            print(resultSlots)
            isResultPresented = true
        }
    }
}
