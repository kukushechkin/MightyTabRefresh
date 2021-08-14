import Foundation

// https://swiftwithmajid.com/2020/04/08/binding-in-swiftui/
extension Sequence {
    func indexed() -> Array<(offset: Int, element: Element)> {
        return Array(enumerated())
    }
}
