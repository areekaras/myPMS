import Foundation

struct Expense: Identifiable, Hashable, Codable {
    let id: UUID
    let amount: Decimal
    let category: Category
    let date: Date
    let description: String
    let associatedObjectId: String // To map expense to any object
    
    init(
        id: UUID = UUID(),
        amount: Decimal,
        category: Category,
        date: Date = Date(),
        description: String,
        associatedObjectId: String
    ) {
        self.id = id
        self.amount = amount
        self.category = category
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
