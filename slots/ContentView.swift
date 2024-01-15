//
//  ContentView.swift
//  slots
//
//  Created by mnats on 25.12.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = SlotMachineViewModel(columns: 5, rows: 3, columnSize: 40)
    
    @State var columns: Int = 5
    @State var rows: Int = 3
    @State var isSpinning = false
    
    var width: CGFloat {
        CGFloat(viewModel.slotColumnsVM.count) * viewModel.slotColumnSize
    }
    
    var height: CGFloat {
        CGFloat(viewModel.rows) * viewModel.slotColumnSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack {
                    Text("Columns")
                    Picker("Columns", selection: $columns) {
                        ForEach(0..<8) { columns in
                            if columns > 2 && columns >= rows {
                                Text("\(columns)")
                            }
                        }
                    }
                }
                
                VStack {
                    Text("Rows")
                    Picker("Rows", selection: $rows) {
                        ForEach(0..<6) { rows in
                            if rows > 2 && columns >= rows {
                                Text("\(rows)")
                            }
                        }
                    }
                }
                Spacer()
            }
            .onChange(of: columns + rows) { _, _ in
                viewModel.setupSlots(columns: columns,
                                     rows: rows,
                                     columnSize: max(geometry.size.width / CGFloat(columns),
                                                     geometry.size.height / CGFloat(rows)))
            }
            .onAppear {
                viewModel.setupSlots(columns: columns,
                                     rows: rows,
                                     columnSize: max(geometry.size.width / CGFloat(columns),
                                                     geometry.size.height / CGFloat(rows)))
            }
        }
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .padding()
        
        Toggle("Guaranteed win", isOn: $viewModel.guaranteedWin)
            .padding()
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
                .overlay {
                    GeometryReader { geometry in
                        Path { path in
                            for line in viewModel.winLines {
                                if let firstSlot = line.first {
                                    let startX = CGFloat(firstSlot.1) * viewModel.slotColumnSize + viewModel.slotColumnSize / 2
                                    let startY = CGFloat(firstSlot.0) * viewModel.slotColumnSize + viewModel.slotColumnSize / 2
                                    path.move(to: CGPoint(x: startX, y: startY))
                                    
                                    for slot in line.dropFirst() {
                                        let x = CGFloat(slot.1) * viewModel.slotColumnSize + viewModel.slotColumnSize / 2
                                        let y = CGFloat(slot.0) * viewModel.slotColumnSize + viewModel.slotColumnSize / 2
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                        }
                        .strokedPath(StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(.white)
                    }
                    .frame(width: width, height: height)
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
            Task {
                isSpinning = true
                await viewModel.spin()
                isSpinning = false
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
        .disabled(isSpinning)
    }
}

#Preview {
    ContentView()
}
