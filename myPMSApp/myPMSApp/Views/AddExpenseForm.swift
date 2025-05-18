import SwiftUI

struct AddExpenseForm: View {
    @ObservedObject var tracker: ExpenseTracker
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = 0.0
    @State private var description: String = ""
    @State private var selectedCategory: Category?
    @State private var objectId: String = ""
    @State private var showObjectId = false
    
    var body: some View {
        Form {
            Section("Amount") {
                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }
            
            Section("Details") {
                TextField("Description", text: $description)
                
                Picker("Category", selection: $selectedCategory) {
                    Text("Select a category").tag(nil as Category?)
                    ForEach(tracker.categories) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
                
                if let category = selectedCategory {
                    if let budget = category.budget,
                       let remaining = tracker.remainingBudget(for: category.id) {
                        HStack {
                            Text("Budget Remaining:")
                            Spacer()
                            Text(remaining.formatted(.currency(code: "USD")))
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
                    guard let category = selectedCategory else { return }
                    
                    let expense = Expense(
                        amount: Decimal(amount),
                        category: category,
                        description: description,
                        associatedObjectId: showObjectId ? objectId : nil
                    )
                    
                    tracker.addExpense(expense)
                    dismiss()
                }
                .disabled(selectedCategory == nil || description.isEmpty || amount <= 0)
            }
        }
    }
}