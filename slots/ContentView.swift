//
//  ContentView.swift
//  slots
//
//  Created by mnats on 25.12.2023.
//

import SwiftUI

struct ContentView: View {
    @Namespace var animation1
    @Namespace var animation2
    @Namespace var animation3
    
    @State var slots = [
    [1, 2, 3, 4, 5, 6, 7].shuffled(),
    [1, 2, 3, 4, 5, 6, 7].shuffled(),
    [1, 2, 3, 4, 5, 6, 7].shuffled()
    ]
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(slots[0], id: \.self) { slot in
                        Image("slot\(slot)")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .matchedGeometryEffect(id: slot, in: animation1)
                    }
                }
                .frame(width: 100)
                VStack(spacing: 0) {
                    ForEach(slots[1], id: \.self) { slot in
                        Image("slot\(slot)")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .matchedGeometryEffect(id: slot, in: animation2)
                    }
                }
                .frame(width: 100)
                VStack(spacing: 0) {
                    ForEach(slots[2], id: \.self) { slot in
                        Image("slot\(slot)")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .matchedGeometryEffect(id: slot, in: animation3)
                    }
                }
                .frame(width: 100)
                
            }
            .frame(width: 300, height: 300)
            .clipShape(.rect)
            
            Button("shuffle") {
                let timeInterval1 = 0.1
                Timer.scheduledTimer(withTimeInterval: timeInterval1, repeats: true) { timer in
                    withAnimation(.linear(duration: 0.3)) {
                        slots[0].insert(slots[0].last!, at: 0)
                        slots[0].remove(at: slots[0].count - 1)
                        slots[1].insert(slots[1].last!, at: 0)
                        slots[1].remove(at: slots[1].count - 1)
                        slots[2].insert(slots[2].last!, at: 0)
                        slots[2].remove(at: slots[2].count - 1)
                    }
                }
            }
            
            
        }
    }
}

#Preview {
    ContentView()
}
