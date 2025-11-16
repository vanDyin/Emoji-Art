//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 07.10.2025.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @Environment(\.undoManager) var undoManager
    
    @StateObject var paletteStore = PaletteStore(named: "Shared")
    
    typealias Emoji = EmojiArt.Emoji

    @ObservedObject var document: EmojiArtDocument
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @State private var selectedEmojis = Set<Emoji.ID>()
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    @GestureState private var emojiGestureZoom: CGFloat = 1
    @GestureState private var emojiGesturePan: CGOffset = .zero
    
    private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌞🌎🔥🌈🌧️🌨️☁️⛄️⛳️🚗🚙🚓🚲🛺🏍️🚘✈️🛩️🚀🚁🏰🏠❤️💤⛵️"
    @ScaledMetric var paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        .toolbar {
            UndoButton()
        }
        .environmentObject(paletteStore)
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(tapGesture)
            .gesture(zoomGesture.simultaneously(with: panGesture))
            .onTapGesture(count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                drop(sturldatas, at: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { _, reason in
                showBackgroundFailureAlert = (reason != nil)
            }
            .onChange(of: document.background.uiImage) { _, uiImage in
                zoomToFit(uiImage?.size, in: geometry)
            }
            .alert(
                "Set background",
                isPresented: $showBackgroundFailureAlert,
                presenting: document.background.failureReason,
                actions: { reason in
                    Button("OK", role: .cancel) { }
                },
                message: { reason in
                    Text(reason)
                }
            )
        }
    }
    
    @State private var showBackgroundFailureAlert = false
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
            }
        }
    }
    
    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                if selectedEmojis.isEmpty {
                    gestureZoom = inMotionPinchScale.magnification
                }
            }
            .updating($emojiGestureZoom) { inMotionPinchScale, emojiGestureZoom, _ in
                if !selectedEmojis.isEmpty {
                    emojiGestureZoom = inMotionPinchScale.magnification
                }
            }
            .onEnded { endingPinchScale in
                if selectedEmojis.isEmpty {
                    zoom *= endingPinchScale.magnification
                } else {
                    for emojiId in selectedEmojis {
                        document.resize(emojiWithId: emojiId, by: endingPinchScale.magnification)
                    }
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation
            }
    }
    
    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded { _ in
                selectedEmojis.removeAll()
            }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            
            switch sturldata {
            case .url(let url):
                document.setBackground(url, undoWith: undoManager)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom,
                    undoWith: undoManager
                )
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .position(Emoji.Position.zero.in(geometry))
        }
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .overlay {
                    if selectedEmojis.contains(emoji.id) {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                    }
                }
                .font(emoji.font)
                .scaleEffect(selectedEmojis.contains(emoji.id) ? emojiGestureZoom : 1)
                .position(emoji.position.in(geometry))
                .offset(selectedEmojis.contains(emoji.id) ? emojiGesturePan : .zero)
                .gesture(emojiTapGesture(for: emoji)
                    .simultaneously(with: emojiPanGesture(for: emoji))
                    
                )
        }
    }
    
    private func emojiTapGesture(for emoji: Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                selectedEmojis.toggleSelection(emoji.id)
            }
    }
    
    private func emojiPanGesture(for emoji: Emoji) -> some Gesture {
        DragGesture()
            .updating($emojiGesturePan) { value, emojiGesturePan, _ in
                if selectedEmojis.contains(emoji.id) {
                    emojiGesturePan = value.translation
                }
            }
            .onEnded { value in
                for emojiId in selectedEmojis {
                    document.move(emojiWithId: emojiId, by: value.translation)
                }
            }
    }
}

extension Set where Element: Hashable {
    mutating func toggleSelection(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
}
