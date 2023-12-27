//
//  ContentView.swift
//  slots
//
//  Created by mnats on 25.12.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SlotMachineViewModel(columns: 4, rows: 3, columnSize: 70)
    
    var width: CGFloat {
        CGFloat(viewModel.slotColumnsVM.count) * viewModel.slotColumnSize
    }
    
    var height: CGFloat {
        CGFloat(viewModel.rows) * viewModel.slotColumnSize
    }
    
    var body: some View {
        VStack {
            if viewModel.isResultPresented {
                VStack(spacing: 0) {
                    ForEach(0..<viewModel.resultSlots.count, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<viewModel.resultSlots[row].count, id: \.self) { column in
                                Image("slot\(viewModel.resultSlots[row][column])")
                                    .resizable()
                                    .frame(width: viewModel.slotColumnSize, height: viewModel.slotColumnSize)
                                    .overlay(.green.opacity(viewModel.winFlags[row][column] ? 0.5 : 0))
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: 0) {
                    ForEach(viewModel.slotColumnsVM, id: \.id) { slotColumn in
                        SlotColumnView(viewModel: slotColumn)
                    }
                }
            }
            
        }
        .frame(width: width, height: height, alignment: .top)
        .clipShape(.rect)
        
        Button("SPIN") {
            viewModel.spin()
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    ContentView()
}
