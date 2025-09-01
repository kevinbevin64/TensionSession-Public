import SwiftUI

struct ListStyleTester: View {
    let items = [
        "Push Ups",
        "Pull Ups",
        "Squats",
        "Lunges",
        "Plank"
    ]
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                HStack {
                    Text("This is some text")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                    
                    Image(systemName: "trash.fill")
                }
                .listRowInsets(listCardEdgeInsets)
                .roundedListItemStyle(cornerRadius: 12, backgroundColor: .exerciseCardBG)
            }
            .listStyle(.plain)
            .padding(.horizontal, 10)
            .navigationTitle("ListStyleTester")
        }
    }
}

#Preview {
    ListStyleTester()
}
