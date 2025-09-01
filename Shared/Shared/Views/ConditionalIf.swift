import SwiftUI

extension View {
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        apply transform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
}
