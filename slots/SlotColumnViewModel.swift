//
//  SlotColumnViewModel.swift
//  slots
//
//  Created by mnats on 26.12.2023.
//

import SwiftUI

class SlotColumnViewModel: ObservableObject {
    let id = UUID()
    @Published var offset: CGFloat = 0
    @Published var slots = [1, 2, 3, 4, 5, 6, 7].shuffled()
    
    
    var size: CGFloat = 100
    
    init(size: CGFloat = 100) {
        self.size = size
    }
    
    @MainActor func spin(count: Int, initialTimeInterval: TimeInterval = 0.1) async {
        let slowDownStartIndex = Int(Double(count) * 0.7)
        var currentTimeInterval = initialTimeInterval
        for i in 0..<count {
            withAnimation(.easeIn(duration: currentTimeInterval * 2)) {
                offset = size
            }
            offset = 0
            slots.insert(slots.removeLast(), at: 0)
            try? await Task.sleep(nanoseconds: UInt64(currentTimeInterval * 1000000000))
            
            if i >= slowDownStartIndex {
                let progress = Double(i - slowDownStartIndex) / Double(count - slowDownStartIndex)
                currentTimeInterval = currentTimeInterval + (progress * initialTimeInterval)
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(currentTimeInterval * 1000000000))
    }
}
