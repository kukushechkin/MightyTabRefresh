import Foundation
import SwiftUI

public struct NonLinearSlider: View {
    @Binding var value: Double
    @State var x: Double
    @State var isEditing: Bool = false
    let valueTransformFunction: SliderFunctionProtocol
    let onEditingChanged: (Bool) -> Void
    let onSubmit: () -> Void

    public init(value: Binding<Double>,
                type: SliderType,
                onEditingChanged: @escaping (Bool) -> Void,
                onSubmit: @escaping () -> Void)
    {
        valueTransformFunction = SliderType.transformFunction(type)
        _value = value
        _x = .init(initialValue: valueTransformFunction.inverseValue(value.wrappedValue))
        self.onEditingChanged = onEditingChanged
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Slider(value: self.$x, in: 1 ... 15) { editing in
            self.onEditingChanged(editing)
            if self.isEditing && !editing {
                self.onSubmit()
            }
            self.isEditing = editing
        }.onChange(of: self.x) { _ in
            DispatchQueue.main.async {
                self.value = self.valueTransformFunction.value(self.x)
            }
        }
    }
}

struct NonLinearSlider_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NonLinearSlider(value: .constant(0.0), type: .linear) { _ in
                //
            } onSubmit: {
                //
            }
        }.environment(\.colorScheme, .light)

        Group {
            NonLinearSlider(value: .constant(0.0), type: .linear) { _ in
                //
            } onSubmit: {
                //
            }
        }.environment(\.colorScheme, .dark)
    }
}
