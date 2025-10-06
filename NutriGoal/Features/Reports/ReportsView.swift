import SwiftUI

struct ReportsView: View {
    @StateObject private var viewModel = ReportsViewModel()
    
    var body: some View {
        NavigationView {
            HeroBaseView {
                ScrollView {
                    VStack(spacing: NGSize.spacing * 2) {
                        // Header
                        Text("📊 Weekly Reports")
                            .font(NGFont.titleL)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Text("AI-generated insights about your progress")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Current Week Summary
                        if let currentReport = viewModel.currentWeekReport {
                            CurrentWeekCard(report: currentReport)
                                .padding(.horizontal)
                        }
                        
                        // Past Reports
                        if !viewModel.pastReports.isEmpty {
                            VStack(alignment: .leading, spacing: NGSize.spacing) {
                                Text("Past Reports")
                                    .font(NGFont.titleM)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.pastReports) { report in
                                    WeeklyReportCard(report: report)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Generate Report Button
                        if viewModel.currentWeekReport == nil {
                            PrimaryButton(title: viewModel.isGenerating ? "Generating..." : "Generate This Week's Report") {
                                Task {
                                    await viewModel.generateWeeklyReport()
                                }
                            }
                            .disabled(viewModel.isGenerating)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadReports()
            }
        }
    }
}

// MARK: - Current Week Card
struct CurrentWeekCard: View {
    let report: WeeklyReportModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(report.week)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Score badge
                ZStack {
                    Circle()
                        .fill(scoreColor(report.avgScore))
                        .frame(width: 50, height: 50)
                    
                    VStack(spacing: 0) {
                        Text(String(format: "%.1f", report.avgScore))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("/10")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            // AI Summary
            Text(report.summaryText)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            // Suggestions
            if !report.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Suggestions")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(report.suggestions)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 8.0 {
            return .green
        } else if score >= 5.0 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Weekly Report Card
struct WeeklyReportCard: View {
    let report: WeeklyReportModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(report.week)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.1f", report.avgScore))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(report.summaryText)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

#Preview {
    ReportsView()
}

