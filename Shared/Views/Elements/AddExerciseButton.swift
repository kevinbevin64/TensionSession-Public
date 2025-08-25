//
//  AddExerciseButton.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/25/25.
//

import SwiftUI

struct AddExerciseButton: View {
    var body: some View {
        Button {

        } label: {
            Image(systemName: "plus.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .quaternary)
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity)
        .frame(alignment: .center)
        .listItemTint(.clear)
    }
}
