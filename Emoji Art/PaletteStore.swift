//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 13.10.2025.
//

import Foundation
import SwiftUI
import Observation

extension UserDefaults {
    func palettes(forKey key: String) -> [Palette] {
        if let jsonData = data(forKey: key),
           let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            return decodedPalettes
        } else {
            return []
        }
    }
    
    func set(_ palettes: [Palette], forKey key: String) {
        let data = try? JSONEncoder().encode(palettes)
        set(data, forKey: key)
    }
}

@Observable
class PaletteStore {
    let name: String
    
    private var userDefaultsKey: String { "PaletteStore:" + name }
    
    var palettes: [Palette] {
        get {
            access(keyPath: \.palettes)
            return UserDefaults.standard.palettes(forKey: userDefaultsKey)
        }
        set {
            withMutation(keyPath: \.palettes) {
                if !newValue.isEmpty {
                    UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
                }
            }
        }
    }
    
    private var _cursorIndex = 0
    
    var cursorIndex: Int {
        get {
            boundsCheckedPaletteIndex(_cursorIndex)
        }
        set {
            _cursorIndex = boundsCheckedPaletteIndex(newValue)
        }
    }
    
    init(named name: String) {
        self.name = name
        if palettes.isEmpty {
            palettes = Palette.builtins
            if palettes.isEmpty {
                palettes = [Palette(name: "Warning", emojis: "⚠️")]
            }
        }
    }
    
    private func boundsCheckedPaletteIndex(_ index: Int) -> Int {
        var index = index % palettes.count
        if index < 0 {
            index += palettes.count
        }
        return index
    }
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) {
        let insertionIndex = boundsCheckedPaletteIndex(insertionIndex ?? cursorIndex)
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes.move(fromOffsets: IndexSet([index]), toOffset: insertionIndex)
            palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
        } else {
            palettes.insert(palette, at: insertionIndex)
        }
    }
    
    func insert(name: String, emojis: String, at index: Int? = nil) {
        insert(Palette(name: name, emojis: emojis), at: index)
    }
    
    func append(_ palette: Palette) {
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            if palettes.count == 1 {
                palettes = [palette]
            } else {
                palettes.remove(at: index)
                palettes.append(palette)
            }
        } else {
            palettes.append(palette)
        }
    }
    
    func append(name: String, emojis: String) {
        append(Palette(name: name, emojis: emojis))
    }
}

