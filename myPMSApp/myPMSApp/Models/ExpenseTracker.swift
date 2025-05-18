import Foundation

class ExpenseTracker: ObservableObject {
    @Published private(set) var expenses: [Expense] = []
    @Published private(set) var categories: [Category] = []
    
    
    // Category-based analytics
    func expenses(for categoryId: UUID) -> [Expense] {
        expenses.filter { $0.category.id == categoryId }
    }
    
    func totalExpenses(for categoryId: UUID) -> Decimal {
        expenses(for: categoryId).reduce(0) { $0 + $1.amount }
    }
    
    func isOverBudget(for categoryId: UUID) -> Bool {
        guard let category = categories.first(where: { $0.id == categoryId }),
                let budget = category.budget
        else { return false }
        return totalExpenses(for: categoryId) > budget
    }
    
    func remainingBudget(for categoryId: UUID) -> Decimal? {
        guard let category = categories.first(where: { $0.id == categoryId }),
                let budget = category.budget
        else { return nil }
        return budget - totalExpenses(for: categoryId)
    }
    
    // Optional object-based tracking
    func expenses(for objectId: String) -> [Expense] {
        expenses.filter { $0.associatedObjectId == objectId }
    }
    
    func expenses(for objectId: String, category: Category) -> [Expense] {
        expenses(for: objectId).filter { $0.category.id == category.id }
    }
    
    func totalExpenses(for objectId: String) -> Decimal {
        expenses(for: objectId).reduce(0) { $0 + $1.amount }
    }
    
    func totalExpenses(for objectId: String, category: Category) -> Decimal {
        expenses(for: objectId, category: category).reduce(0) { $0 + $1.amount }
    }
    
    // Time-based analytics
    func expenses(for month: Date) -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
    }
    
    func totalExpenses(for month: Date) -> Decimal {
        expenses(for: month).reduce(0) { $0 + $1.amount }
    }
    
    // Basic CRUD operations
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
    }
}
