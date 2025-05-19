import Foundation
import Supabase
import Combine

class ExpenseTracker: ObservableObject {
    @Published private(set) var expenses: [UExpense] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var loadingState = LoadingState.idle
    @Published private(set) var errorMessage: String?
    
    enum LoadingState {
        case idle
        case loading
        case error(String)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    // Make this public so view can call it
    func loadInitialData() async {
        await MainActor.run {
            loadingState = .loading
            errorMessage = nil
        }
        
        do {
            let categories: [Category] = try await supabase
                .from("categories")
                .select()
                .execute()
                .value
            await MainActor.run {
                self.categories = categories
            }
            
            await loadExpenses()
            
            await MainActor.run {
                loadingState = .idle
            }
        } catch {
            await MainActor.run {
                loadingState = .error(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
            print("Error loading initial data: \(error)")
        }
    }
    
    // Load expenses and map to UExpense
    private func loadExpenses() async {
        do {
            let expenses: [Expense] = try await supabase
                .from("expenses")
                .select()
                .execute()
                .value
            
            let uExpenses: [UExpense] = expenses.compactMap { expense -> UExpense? in
                guard let category = self.categories.first(where: { $0.id == expense.categoryId }) else {
                    return nil
                }
                return UExpense(from: expense, category: category)
            }
            
            await MainActor.run {
                self.expenses = uExpenses
            }
        } catch {
            await MainActor.run {
                loadingState = .error(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
            print("Error loading expenses: \(error)")
        }
    }
    
    // CRUD Operations
    func addExpense(_ uExpense: UExpense) async {
        do {
            let expense = Expense(
                id: uExpense.id,
                amount: uExpense.amount,
                categoryId: uExpense.category.id,
                date: uExpense.date,
                description: uExpense.description,
                associatedObjectId: uExpense.associatedObjectId
            )
            
            try await supabase
                .from("expenses")
                .insert(expense)
                .execute()
            
            await loadExpenses()
        } catch {
            print("Error adding expense: \(error)")
        }
    }
    
    func addCategory(_ category: Category) async {
        do {
            try await supabase
                .from("categories")
                .insert(category)
                .execute()
            
            let categories: [Category] = try await supabase
                .from("categories")
                .select()
                .execute()
                .value
            
            await MainActor.run {
                self.categories = categories
            }
        } catch {
            print("Error adding category: \(error)")
        }
    }
    
    // Category-based analytics
    func expenses(for categoryId: UUID) -> [UExpense] {
        expenses.filter { $0.category.id == categoryId }
    }
    
    func totalExpenses(for categoryId: UUID) -> Decimal {
        expenses(for: categoryId).reduce(0) { $0 + $1.amount }
    }
    
    func isOverBudget(for categoryId: UUID) -> Bool {
        guard let category = categories.first(where: { $0.id == categoryId }),
              let budget = category.budget
        else { return false }
        return totalExpenses(for: categoryId) > budget
    }
    
    func remainingBudget(for categoryId: UUID) -> Decimal? {
        guard let category = categories.first(where: { $0.id == categoryId }),
              let budget = category.budget
        else { return nil }
        return budget - totalExpenses(for: categoryId)
    }
    
    // Optional object-based tracking
    func expenses(for objectId: String) -> [UExpense] {
        expenses.filter { $0.associatedObjectId == objectId }
    }
    
    func expenses(for objectId: String, category: Category) -> [UExpense] {
        expenses(for: objectId).filter { $0.category.id == category.id }
    }
    
    func totalExpenses(for objectId: String) -> Decimal {
        expenses(for: objectId).reduce(0) { $0 + $1.amount }
    }
    
    func totalExpenses(for objectId: String, category: Category) -> Decimal {
        expenses(for: objectId, category: category).reduce(0) { $0 + $1.amount }
    }
    
    // Time-based analytics
    func expenses(for month: Date) -> [UExpense] {
        let calendar = Calendar.current
        return expenses.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
    }
    
    func totalExpenses(for month: Date) -> Decimal {
        expenses(for: month).reduce(0) { $0 + $1.amount }
    }
}
