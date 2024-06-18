//
//  2DPlaneVisualiser.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 16/06/2024.
//

import SwiftUI

struct _2DPlaneVisualiser: View {
    @State private var selectedVectorID: UUID? = nil
    @State private var secondarySelectedVectorID: UUID? = nil
    @Binding var currentDimension: Int?
    
    var body: some View {
        VStack {
            _2DCoordinateGrid(selectedVectorID: $selectedVectorID, secondarySelectedVectorID: $secondarySelectedVectorID)
                .border(Color.black)
        }
        .onAppear() {
            currentDimension = 2
        }
    }
}

struct _2DCoordinateGrid: View {
    @Binding var selectedVectorID: UUID?
    @Binding var secondarySelectedVectorID: UUID?
    
    var body: some View {
        GeometryReader { metrics in
            let width = metrics.size.width
            let height = metrics.size.height
            let unitWidth = width / 16
            let unitHeight = height / 16
            
            // Draw horizontal grid lines
            ForEach(-7..<8) { y in
                Path { path in
                    let yPos = height / 2 - CGFloat(y) * unitHeight
                    path.move(to: CGPoint(x: 0, y: yPos))
                    path.addLine(to: CGPoint(x: width, y: yPos))
                }
                .stroke(y == 0 ? Color.black : Color.gray, lineWidth: y == 0 ? 2 : 1)
            }
            
            // Draw vertical grid lines
            ForEach(-7..<8) { x in
                Path { path in
                    let xPos = width / 2 - CGFloat(x) * unitWidth
                    path.move(to: CGPoint(x: xPos, y: 0))
                    path.addLine(to: CGPoint(x: xPos, y: height))
                }
                .stroke(x == 0 ? Color.black : Color.gray, lineWidth: x == 0 ? 2 : 1)
            }
            
            _2DVectorArrow(i: 2, j: 3, selectedVectorID: $selectedVectorID, secondarySelectedVectorID: $secondarySelectedVectorID)
            _2DVectorArrow(i: 1, j: -4, selectedVectorID: $selectedVectorID, secondarySelectedVectorID: $secondarySelectedVectorID)
        }
        .frame(width: 450, height: 450) // Set frame size
    }
}

struct _2DVectorArrow: View {
    var i: CGFloat
    var j: CGFloat
    var id: UUID? = UUID()
    
    @State private var isCommandKeyPressed: Bool = false
    
    @Binding var selectedVectorID: UUID?
    @Binding var secondarySelectedVectorID: UUID?
    
    var body: some View {
        GeometryReader { metrics in
            let width = metrics.size.width
            let height = metrics.size.height
            let unitWidth = width / 16
            let unitHeight = height / 16
            
            let startX = width / 2
            let startY = height / 2
            let endX = startX + i * unitWidth
            let endY = startY - j * unitHeight
            
            let arrowLength: CGFloat = 10.0
            let arrowAngle: CGFloat = .pi / 6 // 30 degrees
            
            // Calculate the angle of the vector
            let angle = atan2(endY - startY, endX - startX)
            
            // Calculate the points for the arrowhead
            let arrowPoint1 = CGPoint(
                x: endX - arrowLength * cos(angle + arrowAngle),
                y: endY - arrowLength * sin(angle + arrowAngle)
            )
            let arrowPoint2 = CGPoint(
                x: endX - arrowLength * cos(angle - arrowAngle),
                y: endY - arrowLength * sin(angle - arrowAngle)
            )
            
            Path { path in
                // Draw the vector line
                path.move(to: CGPoint(x: startX, y: startY))
                path.addLine(to: CGPoint(x: endX, y: endY))
                
                // Draw the arrowhead
                path.move(to: CGPoint(x: endX, y: endY))
                path.addLine(to: arrowPoint1)
                path.move(to: CGPoint(x: endX, y: endY))
                path.addLine(to: arrowPoint2)
            }
            .stroke(selectedVectorID == id ? Color.blue : (secondarySelectedVectorID == id ? Color.red : Color.black), lineWidth: 2)
            .onTapGesture {
                if (isCommandKeyPressed) {
                    if let x = selectedVectorID { // ensure a primary vector is selected
                        if x != id {
                            secondarySelectedVectorID = id // ensures a vector cannot be selected twice
                        }
                    }
                } else {
                    secondarySelectedVectorID = nil
                    selectedVectorID = id
                }
            }
        }
        .frame(width: 450, height: 450) // Set frame size
        .trackKeyPress(isCommandKeyPressed: $isCommandKeyPressed)
    }
}

struct KeyPressModifier: ViewModifier {
    @Binding var isCommandKeyPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                    isCommandKeyPressed = event.modifierFlags.contains(.command)
                    return event
                }
            }
    }
}

extension View {
    func trackKeyPress(isCommandKeyPressed: Binding<Bool>) -> some View {
        self.modifier(KeyPressModifier(isCommandKeyPressed: isCommandKeyPressed))
    }
}
