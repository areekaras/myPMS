import SwiftUI

struct Backlog: Identifiable, Codable {
    let id: UUID
    let userId: String
    let title: String
    let description: String?
    let priority: Int
    let estimatedEffort: Float?
    let status: Status
    let createdAt: Date
    let updatedAt: Date
    
    enum Status: String, Codable {
        case pending = "pending"
        case inProgress = "in_progress"
        case completed = "completed"
        case blocked = "blocked"
        
        var color: Color {
            switch self {
            case .pending: .orange
            case .inProgress: .blue
            case .completed: .green
            case .blocked: .red
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case priority
        case estimatedEffort = "estimated_effort"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}