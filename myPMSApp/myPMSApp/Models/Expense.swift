import Foundation

// Database model
struct Expense: Codable {
    let id: UUID
    let amount: Decimal
    let categoryId: UUID
    let date: Date
    let description: String
    let associatedObjectId: String?
}

// UI model
struct UExpense: Identifiable {
    let id: UUID
    let amount: Decimal
    let category: Category
    let date: Date
    let description: String
    let associatedObjectId: String?
    
    init(from expense: Expense, category: Category) {
        self.id = expense.id
        self.amount = expense.amount
        self.category = category
        self.date = expense.date
        self.description = expense.description
        self.associatedObjectId = expense.associatedObjectId
    }
    
    init(
        id: UUID = UUID(),
        amount: Decimal,
        category: Category,
        date: Date = Date(),
        description: String,
        associatedObjectId: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.description = description
        self.associatedObjectId = associatedObjectId
    }
}
