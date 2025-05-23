import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: AppEnvironment.supabaseURL,
    supabaseKey: AppEnvironment.supabaseKey
)
