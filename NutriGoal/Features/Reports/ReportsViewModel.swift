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
    private let openAIService: OpenAIService
    
    // MARK: - Published Properties
    @Published var currentWeekReport: WeeklyReportModel?
    @Published var pastReports: [WeeklyReportModel] = []
    @Published var isGenerating = false
    
    // MARK: - Init
    init(
        firebaseService: FirebaseService = FirebaseServiceImpl(),
        openAIService: OpenAIService = OpenAIService()
    ) {
        self.firebaseService = firebaseService
        self.openAIService = openAIService
    }
    
    // MARK: - Load Reports
    func loadReports() async {
        do {
            // Calculate current week range
            let calendar = Calendar.current
            let today = Date()
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
                return
            }
            
            // Fetch this week's dayStats to see if we have data
            let thisWeekStats = try await firebaseService.fetchDayStatsRange(from: weekStart, to: weekEnd)
            
            // Generate week ID (e.g., "2024-W42")
            let weekFormatter = DateFormatter()
            weekFormatter.dateFormat = "'W'ww"
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let weekId = "\(yearFormatter.string(from: weekStart))-\(weekFormatter.string(from: weekStart))"
            
            // Load past reports from Firestore
            let fetchedReports = try await firebaseService.fetchWeeklyReports()
            
            // Check if report for current week already exists
            if let existingReport = fetchedReports.first(where: { $0.weekId == weekId }) {
                let weekDisplayFormatter = DateFormatter()
                weekDisplayFormatter.dateFormat = "'Week of' MMM d"
                currentWeekReport = WeeklyReportModel(
                    week: weekDisplayFormatter.string(from: existingReport.weekStart),
                    summaryText: existingReport.reportText,
                    avgScore: existingReport.avgScore,
                    suggestions: ""
                )
            } else if thisWeekStats.count >= 3 {
                // Can generate new report for this week
                currentWeekReport = nil
            }
            
            // Load past reports (excluding current week)
            pastReports = fetchedReports
                .filter { $0.weekId != weekId }
                .map { report in
                    let weekDisplayFormatter = DateFormatter()
                    weekDisplayFormatter.dateFormat = "'Week of' MMM d"
                    return WeeklyReportModel(
                        week: weekDisplayFormatter.string(from: report.weekStart),
                        summaryText: report.reportText,
                        avgScore: report.avgScore,
                        suggestions: ""
                    )
                }
            
            print("✅ [ReportsViewModel] Loaded reports. This week: \(thisWeekStats.count) days. Past reports: \(pastReports.count)")
            
        } catch {
            print("❌ [ReportsViewModel] Failed to load reports: \(error)")
        }
    }
    
    // MARK: - Generate Weekly Report
    func generateWeeklyReport() async {
        isGenerating = true
        
        do {
            // Get this week's data
            let calendar = Calendar.current
            let today = Date()
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
                isGenerating = false
                return
            }
            
            // Fetch week's dayStats
            let dayStats = try await firebaseService.fetchDayStatsRange(from: weekStart, to: weekEnd)
            
            guard !dayStats.isEmpty else {
                print("⚠️ [ReportsViewModel] No data for this week yet")
                isGenerating = false
                return
            }
            
            // Calculate week statistics
            let totalDays = dayStats.count
            let avgCalories = dayStats.map(\.caloriesTotal).reduce(0, +) / totalDays
            let avgProtein = dayStats.map(\.proteinTotal).reduce(0, +) / totalDays
            let avgSteps = dayStats.map(\.steps).reduce(0, +) / totalDays
            let avgScore = dayStats.map(\.score).reduce(0.0, +) / Double(totalDays)
            
            // Generate AI report using OpenAI
            let reportText = try await generateAIReport(
                dayStats: dayStats,
                avgCalories: avgCalories,
                avgProtein: avgProtein,
                avgSteps: avgSteps
            )
            
            let weekDisplayFormatter = DateFormatter()
            weekDisplayFormatter.dateFormat = "'Week of' MMM d"
            let weekString = weekDisplayFormatter.string(from: weekStart)
            
            // Generate week ID for Firestore (e.g., "2024-W42")
            let weekIdFormatter = DateFormatter()
            weekIdFormatter.dateFormat = "'W'ww"
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let weekId = "\(yearFormatter.string(from: weekStart))-\(weekIdFormatter.string(from: weekStart))"
            
            currentWeekReport = WeeklyReportModel(
                week: weekString,
                summaryText: reportText,
                avgScore: avgScore > 0 ? avgScore : 7.5,
                suggestions: ""
            )
            
            // Save report to Firestore
            try await firebaseService.saveWeeklyReport(
                weekId: weekId,
                reportText: reportText,
                avgScore: avgScore > 0 ? avgScore : 7.5,
                weekStart: weekStart
            )
            
            print("✅ [ReportsViewModel] AI report generated and saved to Firestore: \(weekId)")
            
        } catch {
            print("❌ [ReportsViewModel] Failed to generate report: \(error)")
        }
        
        isGenerating = false
    }
    
    // MARK: - AI Report Generation
    private func generateAIReport(dayStats: [DayStats], avgCalories: Int, avgProtein: Int, avgSteps: Int) async throws -> String {
        
        // Fetch user goals from Firestore or UserDefaults
        var userGoals: (calories: Int, protein: Int, carbs: Int, fat: Int)? = nil
        
        do {
            if let profile = try await firebaseService.fetchUserProfile() {
                let goals = NutritionCalculator.calculateDailyGoals(
                    birthDate: profile.birthDate,
                    sex: profile.sex,
                    heightCm: profile.heightCm,
                    weightKg: profile.weightKg,
                    activityLevel: profile.activityLevel,
                    target: profile.target,
                    weeklyPaceKg: profile.weeklyPaceKg
                )
                userGoals = (calories: goals.calories, protein: goals.protein, carbs: goals.carbs, fat: goals.fat)
                print("✅ [ReportsViewModel] Loaded user goals for AI report: \(goals.calories) cal")
            }
        } catch {
            print("⚠️ [ReportsViewModel] Could not load user goals, generating report without goals")
        }
        
        // Use OpenAI to generate personalized, creative weekly report
        print("🤖 [ReportsViewModel] Calling OpenAI to generate weekly report...")
        
        let aiReport = try await openAIService.generateWeeklyReport(
            dayStats: dayStats,
            avgCalories: avgCalories,
            avgProtein: avgProtein,
            avgSteps: avgSteps,
            userGoals: userGoals
        )
        
        return aiReport
    }
}

