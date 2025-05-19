import SwiftUI

struct ExpenseListView: View {
    @ObservedObject var tracker: ExpenseTracker
    @State private var showingAddExpense = false
    
    var body: some View {
        List {
            ForEach(tracker.categories) { category in
                Section {
                    if tracker.expenses(for: category.id).isEmpty {
                        Text("No expenses")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tracker.expenses(for: category.id)) { expense in
                            ExpenseRow(expense: expense)
                        }
                    }
                } header: {
                    CategoryHeader(
                        category: category,
                        total: tracker.totalExpenses(for: category.id),
                        isOverBudget: tracker.isOverBudget(for: category.id)
                    )
                }
            }
        }
        .navigationTitle("Expenses")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            #else
            ToolbarItem {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            #endif
        }
        .sheet(isPresented: $showingAddExpense) {
            NavigationStack {
                AddExpenseForm(tracker: tracker)
            }
        }
    }
}

private struct CategoryHeader: View {
    let category: Category
    let total: Decimal
    let isOverBudget: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(category.name)
                    .font(.headline)
                Spacer()
                Text(total.formatted(.currency(code: "USD")))
                    .foregroundStyle(isOverBudget ? .red : .primary)
            }
            
            if let budget = category.budget {
                HStack {
                    Text("Budget:")
                    Text(budget.formatted(.currency(code: "USD")))
                    Spacer()
                    Text("Remaining:")
                    let remaining = budget - total
                    Text(remaining.formatted(.currency(code: "USD")))
                        .foregroundStyle(remaining < 0 ? .red : .green)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ExpenseRow: View {
    let expense: UExpense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.description)
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(expense.amount.formatted(.currency(code: "USD")))
                .foregroundStyle(.primary)
        }
    }
}
