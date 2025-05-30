import SwiftUI

struct AddIdeaForm: View {
    @ObservedObject var ideasManager: IdeasManager
    @Environment(\.dismiss) private var dismiss
    
    let ideaToEdit: Idea?
    
    @State private var title: String = ""
    @State private var ideaDescription: String = ""
    @State private var category: String = ""
    @State private var priority: Idea.Priority = .low
    @State private var tags: String = ""
    @State private var notes: String = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage: String?
    
    init(ideasManager: IdeasManager, ideaToEdit: Idea? = nil) {
        self.ideasManager = ideasManager
        self.ideaToEdit = ideaToEdit
        
        // Initialize state with existing idea values if editing
        if let idea = ideaToEdit {
            _title = State(initialValue: idea.title)
            _ideaDescription = State(initialValue: idea.description ?? "")
            _category = State(initialValue: idea.category ?? "")
            _priority = State(initialValue: idea.priority)
            _tags = State(initialValue: idea.tags.joined(separator: ", "))
            _notes = State(initialValue: idea.notes ?? "")
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $ideaDescription)
                            .frame(minHeight: 100)
                    }
                    
                    TextField("Category", text: $category)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Idea.Priority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
                
                Section("Tags") {
                    TextField("Tags (comma separated)", text: $tags)
                }
                
                Section("Additional Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(ideaToEdit != nil ? "Edit Idea" : "New Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(ideaToEdit != nil ? "Save" : "Add") {
                        Task {
                            await saveIdea()
                        }
                    }
                    .disabled(!isFormValid || isProcessing)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .overlay {
            if isProcessing {
                ProgressView(ideaToEdit != nil ? "Saving idea..." : "Adding idea...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(8)
            }
        }
    }
    
    private func saveIdea() async {
        isProcessing = true
        
        do {
            if let idea = ideaToEdit {
                try await ideasManager.updateIdea(
                    idea,
                    title: title,
                    description: ideaDescription.isEmpty ? nil : ideaDescription,
                    category: category.isEmpty ? nil : category,
                    priority: priority,
                    tags: tags,
                    notes: notes.isEmpty ? nil : notes
                )
            } else {
                try await ideasManager.addIdea(
                    title: title,
                    description: ideaDescription.isEmpty ? nil : ideaDescription,
                    category: category.isEmpty ? nil : category,
                    priority: priority,
                    tags: tags,
                    notes: notes.isEmpty ? nil : notes
                )
            }
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                isProcessing = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
