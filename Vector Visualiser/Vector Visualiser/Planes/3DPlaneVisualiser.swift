//
//  3DPlaneVisualiser.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 30/07/2024.
//

import SwiftUI
import simd

struct _3DPlaneVisualiser: View {
    @State private var selectedVectorID: UUID? = nil
    @State private var secondarySelectedVectorID: UUID? = nil
    @Binding var currentDimension: Int?
    @Binding var vectors: [Vector3D]
    
    var body: some View {
        if let _ = selectedVectorID {
            let selectedVectorComponents = getComponentsOfVector(id: selectedVectorID!)
            if let x = selectedVectorComponents {
                Text("Currently selected vector: (\(x[0].formattedString()!), \(x[1].formattedString()!)), \(x[2].formattedString()!)")
            } else {
                Text("No vector is selected")
            }
        } else {
            Text("No vector is selected")
        }
        
        VStack {
            _3DCoordinateGrid(selectedVectorID: $selectedVectorID, secondarySelectedVectorID: $secondarySelectedVectorID, vectors: $vectors)
                .border(Color.black)
            HStack {
                Spacer()
                Button("Delete selected vector") {
                    deleteSelectedVector()
                }
            }
        }.frame(width: 450)
        .onAppear() {
            currentDimension = 3
        }
    }
    
    private func getComponentsOfVector(id: UUID) -> [CGFloat]? {
        for vector in vectors {
            if vector.id == id {
                return [vector.i, vector.j, vector.k]
            }
        }
        return nil
    }
    
    private func deleteSelectedVector() -> Void {
        if let id = selectedVectorID {
            for i in 0..<vectors.count {
                if vectors[i].id == id {
                    vectors.remove(at: i)
                    break
                }
            }
        }
    }
}

struct _3DCoordinateGrid: View {
    @Binding var selectedVectorID: UUID?
    @Binding var secondarySelectedVectorID: UUID?
    @Binding var vectors: [Vector3D]
    
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
            
            ForEach(vectors, id: \.id) { vector_3d in
                _3DVectorArrow(vector_3d: vector_3d, id: vector_3d.id, name: vector_3d.name, isUnitVector: vector_3d.isUnitVector, selectedVectorID: $selectedVectorID, secondarySelectedVectorID: $secondarySelectedVectorID)
            }
            
        }
        .frame(width: 450, height: 450) // Set frame size
    }
}

struct _3DVectorArrow: View {
    var vector_3d: Vector3D
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
            let vector = transform3Dto2D(vector: vector_3d)
            
            // **** Calculate transformed i and j scalars **** //
            
            let startX = width / 2
            let startY = height / 2
            let endX = startX + vector.i * unitWidth
            let endY = startY - vector.j * unitHeight
            
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
                    
                    /* Draw the arrowhead
                    path.move(to: CGPoint(x: endX, y: endY))
                    path.addLine(to: arrowPoint1)
                    path.move(to: CGPoint(x: endX, y: endY))
                    path.addLine(to: arrowPoint2)*/
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

func transform3Dto2D(vector: Vector3D) -> Vector2D {
    // This function transforms a provided 3D vector into 2 dimensions
    
    // Convert vector to simd vector
    let vector_new = simd_float3(x: Float(vector.i), y: Float(vector.j), z: Float(vector.k))
    
    // Initialise transformation matrix
    let trans = simd_float3x2([
        simd_float2(1, 0),
        simd_float2(0, 1),
        simd_float2(0, 0)
    ])
    
    // Calculate translated vector
    let vector_translated = trans * vector_new
    
    // Convert vector to our own vector type
    let new2DVector = Vector2D(id: UUID(), i: CGFloat(vector_translated.x), j: CGFloat(vector_translated.y), isUnitVector: false)
    
    return new2DVector
}
