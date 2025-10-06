import Foundation
import SwiftUI

struct WeeklyReportModel: Identifiable {
    let id = UUID()
    let week: String
    let summaryText: String
    let avgScore: Double
    let suggestions: String
}

@MainActor
final class ReportsViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let firebaseService: FirebaseService
    
    // MARK: - Published Properties
    @Published var currentWeekReport: WeeklyReportModel?
    @Published var pastReports: [WeeklyReportModel] = []
    @Published var isGenerating = false
    
    // MARK: - Init
    init(firebaseService: FirebaseService = FirebaseServiceImpl()) {
        self.firebaseService = firebaseService
    }
    
    // MARK: - Load Reports
    func loadReports() async {
        // TODO: Load from Firestore weeklyReports collection
        
        // Sample data for now
        pastReports = [
            WeeklyReportModel(
                week: "Week of Sep 25",
                summaryText: "Great week! You stayed consistent with your calorie goals and hit your protein targets 6 out of 7 days. Your step count averaged 9,200 steps daily.",
                avgScore: 8.2,
                suggestions: "Try to increase your vegetable intake. Aim for at least 3 servings per day."
            ),
            WeeklyReportModel(
                week: "Week of Sep 18",
                summaryText: "Good progress on your fitness goals. You logged meals consistently and stayed active. Consider improving sleep quality for better recovery.",
                avgScore: 7.5,
                suggestions: "Focus on getting 7-8 hours of sleep. This will help with recovery and weight management."
            )
        ]
    }
    
    // MARK: - Generate Weekly Report
    func generateWeeklyReport() async {
        isGenerating = true
        
        // TODO: Call OpenAI to generate report based on week's data
        // For now, create a sample report
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let weekFormatter = DateFormatter()
        weekFormatter.dateFormat = "'Week of' MMM d"
        let weekString = weekFormatter.string(from: Date())
        
        currentWeekReport = WeeklyReportModel(
            week: weekString,
            summaryText: "This week you maintained excellent consistency with your nutrition tracking. You logged 18 meals and stayed within your calorie range on 5 out of 7 days. Your macro distribution was well-balanced with adequate protein intake.",
            avgScore: 8.5,
            suggestions: "Keep up the great work! Consider adding more variety to your meals and try meal prepping on Sundays to stay consistent throughout the week."
        )
        
        print("✅ [ReportsViewModel] Weekly report generated")
        
        isGenerating = false
    }
}

