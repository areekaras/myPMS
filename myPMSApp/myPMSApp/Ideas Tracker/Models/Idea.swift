import Foundation
import SwiftUI

struct Idea: Identifiable, Codable {
    let id: UUID
    let userId: String
    let title: String
    let description: String?
    let category: String?
    let priority: Priority
    let tags: [String]
    let notes: String?
    let status: Status
    let createdAt: Date
    
    enum Priority: String, Codable, CaseIterable, Identifiable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var id: String { rawValue }
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
    
    enum Status: String, Codable {
        case idea = "Idea"
        case inProgress = "In Progress"
        case completed = "Completed"
        case onHold = "On Hold"
        case cancelled = "Cancelled"
        
        var color: Color {
            switch self {
            case .idea: return .blue
            case .inProgress: return .orange
            case .completed: return .green
            case .onHold: return .gray
            case .cancelled: return .red
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case category
        case priority
        case tags
        case notes
        case status
        case createdAt = "created_at"
    }
}
