import Foundation
import SwiftUI

struct Idea: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String?
    let category: String?
    let priority: Priority
    let tags: [String]
    let createdAt: Date
    let notes: String?
    let status: Status
    
    enum Priority: String, Codable, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }
    
    enum Status: String, Codable, CaseIterable {
        case idea = "Idea"
        case inProgress = "In Progress"
        case completed = "Completed"
        
        var color: Color {
            switch self {
            case .idea: return .gray
            case .inProgress: return .orange
            case .completed: return .green
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, category, priority, tags, notes, status
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
