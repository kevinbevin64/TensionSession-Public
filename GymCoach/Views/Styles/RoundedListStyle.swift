//
//  RoundedListStyle.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/2/25.
//

import SwiftUI

// MARK: - Applied to List
struct RoundedListStyle: ViewModifier {
    let horizontalPadding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .listStyle(.plain)
            .padding(.horizontal, horizontalPadding)
    }
}

extension View {
    func roundedListStyle(horizontalPadding: CGFloat = 10) -> some View {
        self.modifier(RoundedListStyle(horizontalPadding: horizontalPadding))
    }
}

// MARK: - Applied to list item
struct RoundedListItemStyle: ViewModifier {
    let cornerRadius: CGFloat
    let itemSpacing: CGFloat
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .listRowBackground(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .padding(.vertical, itemSpacing / 2) // Vertical space between elements
            )
    }
}

extension View {
    /// Applies a rounded rectangle style to list rows with spacing and horizontal padding and
    /// hides the list row separator.
    func roundedListItemStyle(
        cornerRadius: CGFloat = 10,
        itemSpacing: CGFloat = 8,
        backgroundColor: Color = .secondary.opacity(0.5)
    ) -> some View {
        self
            .listRowSeparator(.hidden)
            .modifier(RoundedListItemStyle(
                cornerRadius: cornerRadius,
                itemSpacing: itemSpacing,
                backgroundColor: backgroundColor
            ))
    }
}
