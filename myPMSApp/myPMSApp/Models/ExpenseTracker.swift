import Foundation

class ExpenseTracker: ObservableObject {
    @Published private(set) var expenses: [Expense] = []
    @Published private(set) var categories: [Category] = []
        
    init() {} // Default initializer
    
    // Get expenses for any object
    func expenses(for objectId: String) -> [Expense] {
        expenses.filter { $0.associatedObjectId == objectId }
    }
    
    // Get expenses for any object by category
    func expenses(for objectId: String, category: Category) -> [Expense] {
        expenses(for: objectId).filter { $0.category == category }
    }
    
    // Get total expenses for any object
    func totalExpenses(for objectId: String) -> Decimal {
        expenses(for: objectId).reduce(0) { $0 + $1.amount }
    }
    
    // Get total expenses for any object by category
    func totalExpenses(for objectId: String, category: Category) -> Decimal {
        expenses(for: objectId, category: category).reduce(0) { $0 + $1.amount }
    }
    
    // Add new expense
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }
    
    // Add new category
    func addCategory(_ category: Category) {
        categories.append(category)
    }
}
