//
//  ContentView.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 16/06/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var currentDimension: Int?

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    _2DPlaneVisualiser(currentDimension: $currentDimension)
                } label: {
                    HStack {
                        Image(systemName: "square")
                        Text("2D Plane")
                    }
                }
                
                NavigationLink {
                    Text("Hello, world!")
                } label: {
                    HStack {
                        Image(systemName: "cube.transparent")
                        Text("3D Plane")
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 150, max: 150)
            .toolbar(removing: .sidebarToggle)
            .toolbar {
                ToolbarItem {
                    Button {
                        print(currentDimension ?? 0)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Please select a plane to visualise")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
