//
//  PaletteChooser.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 13.10.2025.
//

import SwiftUI


struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore
    
    @State private var showPaletteEditor = false
    @State private var showPaletteList = false
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
        .clipped()
        //changed due to Observation
        .sheet(isPresented: $showPaletteEditor) {
            PaletteEditor(palette: Binding(
                get: { store.palettes[store.cursorIndex] },
                set: { store.palettes[store.cursorIndex] = $0 }
            ))
            .font(nil)
        }
        .sheet(isPresented: $showPaletteList) {
            NavigationStack {
                EditablePaletteList(store: store)
                    .font(nil)
            }
        }
    }
    
    var chooser: some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.cursorIndex += 1
        }
        .contextMenu {
            gotoMenu
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(name: "", emojis: "")
                showPaletteEditor = true 
            }
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                store.palettes.remove(at: store.cursorIndex)
            }
            AnimatedActionButton("Edit", systemImage: "pencil") {
                showPaletteEditor = true
            }
            AnimatedActionButton("List", systemImage: "list.bullet.rectangle.portrait") {
                showPaletteList = true
            }
        }
    }
    
    private var gotoMenu: some View {
        Menu {
            ForEach(store.palettes) { palette in
                AnimatedActionButton(palette.name) {
                    if let index = store.palettes.firstIndex(where: { $0.id == palette.id }) {
                            store.cursorIndex = index
                    }
                }
            }
        } label: {
            Label("Go to", systemImage: "text.insert")
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
        .id(palette.id)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map(String.init)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) {emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}

#Preview {
    PaletteChooser()
        .environmentObject(PaletteStore(named: "Preview"))
}
