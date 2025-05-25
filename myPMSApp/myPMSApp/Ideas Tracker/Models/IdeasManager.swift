import SwiftUI
import Supabase

@MainActor
class IdeasManager: ObservableObject {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    @Published var ideas: [Idea] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchIdeas() async {
        isLoading = true
        error = nil
        
        do {
            let response: [Idea] = try await client
                .from("ideas")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.ideas = response
            self.isLoading = false
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
    
    func addIdea(title: String, description: String?, category: String?, priority: Idea.Priority, tags: String, notes: String?) async throws {
        let tagsArray = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        struct IdeaPayload: Encodable {
            let user_id: String
            let title: String
            let description: String?
            let category: String?
            let priority: String
            let tags: [String]
            let notes: String?
            let status: String
        }
        
        let payload = try await IdeaPayload(
            user_id: client.auth.session.user.id.uuidString,
            title: title,
            description: description,
            category: category,
            priority: priority.rawValue,
            tags: tagsArray,
            notes: notes,
            status: Idea.Status.idea.rawValue
        )
        
        try await supabase
            .from("ideas")
            .insert(payload)
            .execute()
        
        await fetchIdeas()
    }
}
