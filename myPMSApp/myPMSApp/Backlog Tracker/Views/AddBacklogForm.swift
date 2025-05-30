import SwiftUI

struct AddBacklogForm: View {
    @ObservedObject var backlogManager: BacklogManager
    @Environment(\.dismiss) private var dismiss
    
    let backlogToEdit: Backlog?
    
    @State private var title: String = ""
    @State private var backlogDescription: String = ""
    @State private var priority: Int = 0
    @State private var estimatedEffort: Float?
    @State private var status: Backlog.Status = .pending
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage: String?
    
    init(backlogManager: BacklogManager, backlogToEdit: Backlog? = nil) {
        self.backlogManager = backlogManager
        self.backlogToEdit = backlogToEdit
        
        if let backlog = backlogToEdit {
            _title = State(initialValue: backlog.title)
            _backlogDescription = State(initialValue: backlog.description ?? "")
            _priority = State(initialValue: backlog.priority)
            _estimatedEffort = State(initialValue: backlog.estimatedEffort)
            _status = State(initialValue: backlog.status)
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
                        TextEditor(text: $backlogDescription)
                            .frame(minHeight: 100)
                    }
                    
                    Stepper("Priority: \(priority)", value: $priority, in: 0...5)
                    
                    HStack {
                        Text("Estimated Effort")
                        Spacer()
                        TextField("Optional", value: $estimatedEffort, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if backlogToEdit != nil {
                        Picker("Status", selection: $status) {
                            Text("Pending").tag(Backlog.Status.pending)
                            Text("In Progress").tag(Backlog.Status.inProgress)
                            Text("Completed").tag(Backlog.Status.completed)
                            Text("Blocked").tag(Backlog.Status.blocked)
                        }
                    }
                }
            }
            .navigationTitle(backlogToEdit != nil ? "Edit Backlog" : "New Backlog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(backlogToEdit != nil ? "Save" : "Add") {
                        Task {
                            await saveBacklog()
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
                ProgressView(backlogToEdit != nil ? "Saving backlog..." : "Adding backlog...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(8)
            }
        }
    }
    
    private func saveBacklog() async {
        isProcessing = true
        
        do {
            if let backlog = backlogToEdit {
                try await backlogManager.updateBacklog(
                    backlog,
                    title: title,
                    description: backlogDescription.isEmpty ? nil : backlogDescription,
                    priority: priority,
                    estimatedEffort: estimatedEffort,
                    status: status
                )
            } else {
                try await backlogManager.addBacklog(
                    title: title,
                    description: backlogDescription.isEmpty ? nil : backlogDescription,
                    priority: priority,
                    estimatedEffort: estimatedEffort
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