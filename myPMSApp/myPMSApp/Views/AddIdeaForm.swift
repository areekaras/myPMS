import SwiftUI

struct AddIdeaForm: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var ideasManager: IdeasManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var category = ""
    @State private var priority = Idea.Priority.medium
    @State private var tags = ""
    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Category", text: $category)
                }
                
                Section("Details") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Idea.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                    
                    TextField("Tags (comma separated)", text: $tags)
                }
                
                Section("Additional Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await addIdea()
                        }
                    }
                    .disabled(title.isEmpty || isSubmitting)
                }
            }
            .overlay {
                if isSubmitting {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(8)
                }
            }
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK") {
                    error = nil
                }
            } message: {
                if let error {
                    Text(error)
                }
            }
        }
    }
    
    private func addIdea() async {
        isSubmitting = true
        error = nil
        
        do {
            try await ideasManager.addIdea(
                title: title,
                description: description.isEmpty ? nil : description,
                category: category.isEmpty ? nil : category,
                priority: priority,
                tags: tags,
                notes: notes.isEmpty ? nil : notes
            )
            
            dismiss()
        } catch {
            self.error = error.localizedDescription
            isSubmitting = false
        }
    }
}