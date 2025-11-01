//
//  PaletteList.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 30.10.2025.
//

import SwiftUI

struct EditablePaletteList: View {
    @Bindable var store: PaletteStore
    @State private var showCursorPalette = false
    
    var body: some View {
        
        List {
            ForEach(store.palettes) { palette in
                NavigationLink(value: palette.id) {
                    VStack(alignment: .leading) {
                        Text(palette.name)
                        Text(palette.emojis).lineLimit(1)
                    }
                }
                
            }
            .onDelete { indexSet in
                withAnimation {
                    store.palettes.remove(atOffsets: indexSet)
                }
            }
            .onMove { indexSet, newOffset in
                store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
            }
        }
        .navigationDestination(isPresented: $showCursorPalette) {
            PaletteEditor(palette: $store.palettes[store.cursorIndex])
        }
        .navigationDestination(for: Palette.ID.self) { paletteid in
            if let index = store.palettes.firstIndex(where: { $0.id == paletteid }) {
                PaletteEditor(palette: $store.palettes[index])
            }
        }
        .navigationTitle("\(store.name) Palettes")
        .toolbar {
            Button {
                store.insert(name: "", emojis: "")
                showCursorPalette = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct PaletteList: View {
    @Environment(PaletteStore.self) private var store
    
    var body: some View {
        NavigationStack {
            List(store.palettes) { palette in
                NavigationLink(value: palette) {
                    Text(palette.name)
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                PaletteView(palette: palette)
            }
            .navigationTitle("\(store.name) Palettes")
        }
    }
}

struct PaletteView: View {
    let palette: Palette
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            .navigationDestination(for: String.self) { emoji in
                Text(emoji).font(.system(size: 300))
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .navigationTitle(palette.name)
    }
}

#Preview {
    PaletteList()
}
