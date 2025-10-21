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
            
            // If we have at least 3 days of data, show option to generate report
            if thisWeekStats.count >= 3 {
                // Check if report already exists for this week
                // For now, we'll regenerate each time
                currentWeekReport = nil
            }
            
            // TODO: Load past reports from Firestore weeklyReports collection
            // For now, show empty past reports
            pastReports = []
            
            print("✅ [ReportsViewModel] Loaded reports. This week has \(thisWeekStats.count) days of data")
            
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
            
            let weekFormatter = DateFormatter()
            weekFormatter.dateFormat = "'Week of' MMM d"
            let weekString = weekFormatter.string(from: weekStart)
            
            currentWeekReport = WeeklyReportModel(
                week: weekString,
                summaryText: reportText,
                avgScore: avgScore > 0 ? avgScore : 7.5, // Use real score or default
                suggestions: "Keep tracking consistently and stay within your macro targets."
            )
            
            print("✅ [ReportsViewModel] AI report generated for week with \(totalDays) days")
            
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

