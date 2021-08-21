//
//  ViewCursorModifier.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import Foundation
import SwiftUI

struct CursorOnHoverModifier: ViewModifier {
    let cursor: NSCursor
    @State var hover: Bool = false

    func body(content: Content) -> some View {
        content
        .onHover { isHovered in
            self.hover = isHovered
            DispatchQueue.main.async {
                if (self.hover) {
                    self.cursor.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

extension View {
    func cursorOnHover(cursor: NSCursor) -> some View {
        self.modifier(CursorOnHoverModifier(cursor: cursor))
    }
}
