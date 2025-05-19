import SwiftUI

struct AddExpenseForm: View {
    @ObservedObject var tracker: ExpenseTracker
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = 0.0
    @State private var description: String = ""
    @State private var selectedCategory: Category?
    @State private var objectId: String = ""
    @State private var showObjectId = false
    @State private var isAddingExpense = false
    
    private var isFormValid: Bool {
        selectedCategory != nil && !description.isEmpty && amount > 0
    }
    
    var body: some View {
        Form {
            Section("Amount") {
                ZStack(alignment: .leading) {
                    if amount == 0 {
                        Text("S$")
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                    }
                    TextField("", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, amount == 0 ? 24 : 8)
                }
            }
            
            Section("Details") {
                TextField("Description", text: $description)
                
                if !tracker.categories.isEmpty {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select a category").tag(Optional<Category>.none)
                        ForEach(tracker.categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                }
                
                if let category = selectedCategory {
                    if let budget = category.budget,
                       let remaining = tracker.remainingBudget(for: category.id) {
                        HStack {
                            Text("Budget Remaining:")
                            Spacer()
                            Text(remaining.formatted(.currency(code: "SGD")))
                                .foregroundStyle(remaining < Decimal(amount) ? .red : .green)
                        }
                    }
                    
                    if tracker.isOverBudget(for: category.id) {
                        Label("Category is over budget", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            
            Section {
                Toggle("Track for Object", isOn: $showObjectId)
                
                if showObjectId {
                    TextField("Object ID", text: $objectId)
                }
            }
        }
        .navigationTitle("Add Expense")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    addExpense()
                }
                .disabled(!isFormValid || isAddingExpense)
            }
        }
    }
    
    private func addExpense() {
        guard let category = selectedCategory else { return }
        
        let uExpense = UExpense(
            id: UUID(),
            amount: Decimal(amount),
            category: category,
            date: Date(),
            description: description,
            associatedObjectId: showObjectId ? objectId : nil
        )
        
        isAddingExpense = true
        
        Task {
            await tracker.addExpense(uExpense)
            await MainActor.run {
                isAddingExpense = false
                dismiss()
            }
        }
    }
}
