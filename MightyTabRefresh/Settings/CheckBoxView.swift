// https://stackoverflow.com/questions/58425829/how-can-i-create-a-text-with-checkbox-in-swiftui

import SwiftUI

struct CheckBoxView: View {
    @Binding var checked: Bool
    
    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? Color(NSColor.systemBlue) : Color.secondary)
            .onTapGesture {
                self.checked.toggle()
            }
            .cursorOnHover(cursor: .pointingHand)
    }
}

struct CheckBoxView_Previews: PreviewProvider {
    struct CheckBoxViewHolder: View {
        @State var checked = false

        var body: some View {
            CheckBoxView(checked: $checked)
        }
    }

    static var previews: some View {
        CheckBoxViewHolder()
    }
}
