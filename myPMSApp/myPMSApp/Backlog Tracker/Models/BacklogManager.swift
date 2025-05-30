import SwiftUI
import Supabase

@MainActor
class BacklogManager: ObservableObject {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    @Published var backlogs: [Backlog] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchBacklogs() async {
        isLoading = true
        error = nil
        
        do {
            let response: [Backlog] = try await client
                .from("backlog_items")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.backlogs = response
            self.isLoading = false
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
    
    func addBacklog(title: String, description: String?, priority: Int, estimatedEffort: Float?) async throws {
        struct BacklogPayload: Encodable {
            let user_id: String
            let title: String
            let description: String?
            let priority: Int
            let estimated_effort: Float?
            let status: String
        }
        
        let payload = try await BacklogPayload(
            user_id: client.auth.session.user.id.uuidString,
            title: title,
            description: description,
            priority: priority,
            estimated_effort: estimatedEffort,
            status: Backlog.Status.pending.rawValue
        )
        
        try await supabase
            .from("backlog_items")
            .insert(payload)
            .execute()
        
        await fetchBacklogs()
    }
    
    func updateBacklog(_ backlog: Backlog, title: String, description: String?, priority: Int, estimatedEffort: Float?, status: Backlog.Status) async throws {
        struct BacklogPayload: Encodable {
            let title: String
            let description: String?
            let priority: Int
            let estimated_effort: Float?
            let status: String
        }
        
        let payload = BacklogPayload(
            title: title,
            description: description,
            priority: priority,
            estimated_effort: estimatedEffort,
            status: status.rawValue
        )
        
        try await supabase
            .from("backlog_items")
            .update(payload)
            .eq("id", value: backlog.id)
            .execute()
        
        await fetchBacklogs()
    }
    
    func deleteBacklog(_ backlog: Backlog) async throws {
        try await supabase
            .from("backlog_items")
            .delete()
            .eq("id", value: backlog.id)
            .execute()
        
        await fetchBacklogs()
    }
}