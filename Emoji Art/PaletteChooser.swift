//
//  PaletteChooser.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 13.10.2025.
//

import SwiftUI

struct PaletteChooser: View {
    var store: PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
    }
    
    var chooser: some View {
        Button{
            
        } label: {
            Image(systemName: "paintpalette")
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
    }
}

#Preview {
    PaletteChooser(store: PaletteStore(named: "Preview"))
}
