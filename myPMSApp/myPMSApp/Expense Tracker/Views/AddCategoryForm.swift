import SwiftUI

struct AddCategoryForm: View {
    @ObservedObject var tracker: ExpenseTracker
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var budget: Double?
    @State private var isAddingCategory = false
    @State private var showError = false
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !name.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category Name", text: $name)
                    TextField("Budget (Optional)", value: $budget, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Category")
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
                            await addCategory()
                        }
                    }
                    .disabled(!isFormValid || isAddingCategory)
                }
            }
        }
        .presentationDetents([.medium])
        .alert("Error Adding Category", isPresented: $showError) {
            Button("OK") { }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .overlay {
            if isAddingCategory {
                ProgressView("Adding category...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(8)
            }
        }
    }
    
    private func addCategory() async {
        isAddingCategory = true
        
        do {
            let category = Category(
                id: UUID(),
                name: name,
                budget: budget.map { Decimal($0) }
            )
            
            try await tracker.addCategory(category)
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                isAddingCategory = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}