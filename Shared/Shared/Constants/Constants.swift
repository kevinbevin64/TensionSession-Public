//
//  Constants.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/29/25.
//

import Foundation
import SwiftUI

// MARK: - for UI

// MARK: - Toolbars

// Used for padding around buttons in the toolbar
let toolbarButtonEdgeInsets = EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)

// MARK: - Lists

// Used for padding the elements inside of a list element
let listCardEdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

// Used for padding the contents of an ExercisePlanCard in the PlanView.
let exercisePlanCardEdgeInsets = EdgeInsets(top: 12, leading: 15, bottom: 10, trailing: 10)

// Used for padding the contents of an ExerciseRecordCardin the RecordView.
let exerciseRecordCardEdgeInsets = EdgeInsets(top: 12, leading: 15, bottom: 15, trailing: 10)

// Used for padding the contents of an exercise list item in the AnalyzeView
let exerciseAnalyzeCardEdgeInsets = EdgeInsets(top: 20, leading: 15, bottom: 20, trailing: 18)

// MARK: - Grids

let gridItemCornerRadius: CGFloat = 30

// MARK: - Pickers

// The amount of spacing between text and a picker when they are placed in a VStack
let textPickerSpacing: CGFloat = 12

// The height and width applied to pickers in PlanView
let pickerWidth: CGFloat = 80
let pickerHeight: CGFloat = 100

// MARK: - Prompts

// The width of glyphs in prompt views
let promptGlyphWidth: CGFloat = 100

// The height of glyphs in prompt views
let promptGlyphHeight: CGFloat = 100

// The text style used in prompt views
let promptTextFont: Font = .body

// The font design used in prompt views
let promptTextDesign: Font.Design = .rounded

// The spacing between a glyph and text in prompt views
let promptSpacing: CGFloat = 12

// MARK: - User input constraints

// The minimum number of sets a user can choose for an exercise
let minSetCount: Int = 1

// The maximum number of sets a user can choose for an exercise
let maxSetCount: Int = 20

// The minimum number of reps a user can choose for a set
let minRepCount: Int = 1

// The maxinum number of reps a user can choose for a set/
let maxRepCount: Int = 100

// The minimum (displayed) weight value (as a double) a user can choose for a set
let minWeightValue: Double = 0.0

// The maximum (displayed) weight value (as a double) a user can choose for a set
let maxWeightValue: Double = 1000.0

// The default number of sets
let defaultSetCount: Int = 3

// The default number of reps
let defaultRepCount: Int = 12

// The default weight value
let defaultWeightValue: Double = 20.0
