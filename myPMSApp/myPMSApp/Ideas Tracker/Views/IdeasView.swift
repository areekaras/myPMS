import SwiftUI

struct IdeasView: View {
    @StateObject private var ideasManager = IdeasManager(client: supabase)
    @State private var showingAddForm = false
    
    var body: some View {
        NavigationStack {
            Group {
                if ideasManager.isLoading {
                    ProgressView()
                } else if let error = ideasManager.error {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if ideasManager.ideas.isEmpty {
                    ContentUnavailableView("No Ideas Yet", systemImage: "lightbulb", description: Text("Tap + to add a new idea"))
                } else {
                    List(ideasManager.ideas) { idea in
                        IdeaRowView(idea: idea)
                    }
                }
            }
            .navigationTitle("Ideas")
            .toolbar {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddForm) {
                AddIdeaForm(ideasManager: ideasManager)
            }
            .task {
                await ideasManager.fetchIdeas()
            }
        }
    }
}

struct IdeaRowView: View {
    let idea: Idea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(idea.title)
                    .font(.headline)
                Spacer()
                Text(idea.status.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(idea.status.color.opacity(0.2))
                    .foregroundColor(idea.status.color)
                    .cornerRadius(4)
            }
            
            if let description = idea.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                if let category = idea.category {
                    Text(category)
                        .font(.caption)
                        .padding(4)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text(idea.priority.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(idea.priority.color.opacity(0.2))
                    .foregroundColor(idea.priority.color)
                    .cornerRadius(4)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(idea.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(4)
                            .background(.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
            
            Text(idea.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}