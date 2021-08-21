//
//  ViewCursorModifier.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import Foundation
import SwiftUI

struct BackgroundOnHoverModifier: ViewModifier {
    @State var hover: Bool

    func body(content: Content) -> some View {
        ZStack {
            if self.hover {
                Rectangle()
                    .cornerRadius(15)
                    .colorMultiply(Color(NSColor(named: "hoverBackgroundColor")!))
            }
            content
                .onHover { isHovered in
                    self.hover = isHovered
                }
        }
    }
}

extension View {
    func backgroundOnHover() -> some View {
        self.modifier(BackgroundOnHoverModifier(hover: false))
    }
}

struct BackgroundOnHoverModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Some text")
                .modifier(BackgroundOnHoverModifier(hover: true))
                .environment(\.colorScheme, .dark)
            Text("Some text")
                .modifier(BackgroundOnHoverModifier(hover: false))
                .environment(\.colorScheme, .dark)
            Text("Some text")
                .modifier(BackgroundOnHoverModifier(hover: true))
                .environment(\.colorScheme, .light)
            Text("Some text")
                .modifier(BackgroundOnHoverModifier(hover: false))
                .environment(\.colorScheme, .light)
        }
    }
}
