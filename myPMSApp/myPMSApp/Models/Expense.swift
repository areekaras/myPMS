import Foundation

struct Expense: Identifiable, Hashable, Codable {
    let id: UUID
    let amount: Decimal
    let categoryId: UUID
    let date: Date
    let description: String
    let associatedObjectId: String?
    
    init(
        id: UUID = UUID(),
        amount: Decimal,
        categoryId: UUID,
        date: Date = Date(),
        description: String,
        associatedObjectId: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.categoryId = categoryId
        self.date = date
        self.description = description
        self.associatedObjectId = associatedObjectId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
}

// UI-compatible Expense model
struct UExpense: Identifiable, Hashable {
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
}
