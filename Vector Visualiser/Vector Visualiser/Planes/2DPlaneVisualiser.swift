//
//  2DPlaneVisualiser.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 16/06/2024.
//

import SwiftUI

struct Vector {
    var id: UUID
    var i: CGFloat
    var j: CGFloat
    var name: String?
    var isUnitVector: Bool
}

struct _2DPlaneVisualiser: View {
    @State private var selectedVectorID: UUID? = nil
    @State private var secondarySelectedVectorID: UUID? = nil
    @Binding var currentDimension: Int?
    
    @State private var vectors: [Vector] = [
        Vector(id: UUID(), i: 2, j: 3, isUnitVector: false),
        Vector(id: UUID(), i: 1, j: -4, isUnitVector: false),
        Vector(id: UUID(), i: 1, j: 0, name: "i", isUnitVector: true),
        Vector(id: UUID(), i: 0, j: 1, name: "j", isUnitVector: true)
    ]
    
    var body: some View {
        if let _ = selectedVectorID {
            let selectedVectorComponents = getComponentsOfVector(id: selectedVectorID!)
            if let x = selectedVectorComponents {
                Text("Currently selected vector: (\(x[0].formattedString()!), \(x[1].formattedString()!))")
            } else {
                Text("No vector is selected")
            }
        } else {
            Text("No vector is selected")
        }
        
        VStack {
            _2DCoordinateGrid(selectedVectorID: $selectedVectorID, secondarySelectedVectorID: $secondarySelectedVectorID, vectors: $vectors)
                .border(Color.black)
        }
        .onAppear() {
            currentDimension = 2
        }
    }
    
    private func getComponentsOfVector(id: UUID) -> [CGFloat]? {
        for vector in vectors {
            if vector.id == id {
                return [vector.i, vector.j]
            }
        }
        return nil
    }
}

struct _2DCoordinateGrid: View {
    @Binding var selectedVectorID: UUID?
    @Binding var secondarySelectedVectorID: UUID?
    @Binding var vectors: [Vector]
    
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
                .stroke(y == 0 ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color.gray, lineWidth: y == 0 ? 1.5 : 1)
            }
            
            // Draw vertical grid lines
            ForEach(-7..<8) { x in
                Path { path in
                    let xPos = width / 2 - CGFloat(x) * unitWidth
                    path.move(to: CGPoint(x: xPos, y: 0))
                    path.addLine(to: CGPoint(x: xPos, y: height))
                }
                .stroke(x == 0 ? Color(red: 0.3, green: 0.3, blue: 0.3): Color.gray, lineWidth: x == 0 ? 1.5 : 1)
            }
            
            ForEach(vectors, id: \.id) { vector in
                _2DVectorArrow(i: vector.i, j: vector.j, id: vector.id, name: vector.name, isUnitVector: vector.isUnitVector, selectedVectorID: $selectedVectorID, secondarySelectedVectorID: $secondarySelectedVectorID)
            }
            
        }
        .frame(width: 450, height: 450) // Set frame size
    }
}

struct _2DVectorArrow: View {
    var i: CGFloat
    var j: CGFloat
    var id: UUID
    var name: String?
    var isUnitVector: Bool
    
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
            
            ZStack {
                
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
                .stroke(selectedVectorID == id ? Color.blue : (secondarySelectedVectorID == id ? Color.red : Color.black), lineWidth: 2.3)
                .onTapGesture {
                    if !(isUnitVector) {
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
                
                if isUnitVector, let name = name {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                        .fontWeight(.heavy)
                        .position(x: endX + 7, y: endY - 7)
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

extension CGFloat {
    func formattedString() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.locale = Locale.current
        
        return numberFormatter.string(from: NSNumber(value: Double(self)))
    }
}
