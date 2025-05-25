import Foundation

struct Category: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let budget: Decimal?
    let color: String // Store as hex string
    
    init(
        id: UUID = UUID(),
        name: String,
        budget: Decimal? = nil,
        color: String = "#007AFF"
    ) {
        self.id = id
        self.name = name
        self.budget = budget
        self.color = color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}
