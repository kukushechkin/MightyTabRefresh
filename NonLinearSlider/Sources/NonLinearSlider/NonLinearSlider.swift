import Foundation
import SwiftUI

public struct NonLinearSlider: View {
    @Binding var value: Double
    @State var xValue: Double
    @State var isEditing: Bool = false
    let valueTransformFunction: SliderFunctionProtocol
    let onEditingChanged: (Bool) -> Void
    let onSubmit: () -> Void

    var x: Binding<Double> {
        get {
            DispatchQueue.main.async {
                self.value = self.valueTransformFunction.value(self.xValue)
            }
            return self.$xValue
        }
        set {
            // not being called in the context of this component, but hey, for the sake of completness
            self.xValue = newValue.wrappedValue
        }
    }

    public init(value: Binding<Double>,
                type: SliderType,
                onEditingChanged: @escaping (Bool) -> Void,
                onSubmit: @escaping () -> Void) {
        self.valueTransformFunction = SliderType.transformFunction(type)
        self._value = value
        self._xValue = .init(initialValue: self.valueTransformFunction.inverseValue(value.wrappedValue))
        self.onEditingChanged = onEditingChanged
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Slider(value: self.x, in: 1...100) {
            // content
        } onEditingChanged: { editing in
            self.onEditingChanged(editing)
            if self.isEditing && !editing {
                self.onSubmit()
            }
            self.isEditing = editing
        }
    }
}

struct NonLinearSlider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // TODO:
//            NonLinearSlider(value: .constant(0.0), type: .linear, content: { Spacer() }).environment(\.colorScheme, .light)
//            NonLinearSlider(value: .constant(0.0), type: .linear, content: { Spacer() }).environment(\.colorScheme, .dark)
        }
    }
}
