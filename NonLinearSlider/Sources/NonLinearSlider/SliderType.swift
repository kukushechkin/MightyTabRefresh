import Foundation

public enum SliderType {
    case linear
    case parabolic
    case hyperbolic

    internal static func transformFunction(_ type: SliderType) -> SliderFunctionProtocol {
        // this fixes "outline init" error when an object is being initialized in switch
        _ = LinearFunction()
        _ = ParabolicFunction()
        _ = HyperbolicFunction()

        switch(type) {
        case .linear:
            return LinearFunction()
        case .parabolic:
            return ParabolicFunction()
        case .hyperbolic:
            return HyperbolicFunction()
        }
    }
}

internal protocol SliderFunctionProtocol {
    func value(_ x: Double) -> Double
    func inverseValue(_ y: Double) -> Double
}

internal struct LinearFunction: SliderFunctionProtocol {
    func value(_ x: Double) -> Double {
        x
    }

    func inverseValue(_ y: Double) -> Double {
        y
    }
}

internal struct ParabolicFunction: SliderFunctionProtocol {
    func value(_ x: Double) -> Double {
        x * x * x * x
    }

    func inverseValue(_ y: Double) -> Double {
        sqrt(sqrt(y))
    }
}

internal struct HyperbolicFunction: SliderFunctionProtocol {
    func value(_ x: Double) -> Double {
        100.0 / x
    }

    func inverseValue(_ y: Double) -> Double {
        100.0 / y
    }
}
