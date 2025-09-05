import Foundation
import HealthKit

// MARK: - Protocol
protocol HealthKitService {
    func requestPermissions() async throws -> Bool
    func getSteps(for date: Date) async throws -> Int
    func getActiveCalories(for date: Date) async throws -> Double
    func getSleepHours(for date: Date) async throws -> Double
    func getWorkoutMinutes(for date: Date) async throws -> Int
    func getHeartRate(for date: Date) async throws -> Double?
    func getBodyWeight() async throws -> Double?
}

// MARK: - HealthKit Service Implementation
final class HealthKitServiceImpl: HealthKitService {
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Health data types we want to read
    private let readTypes: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.workoutType()
    ]
    
    // MARK: - Permissions
    func requestPermissions() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ [HealthKitService] HealthKit not available on this device")
            throw HealthKitError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error = error {
                    print("❌ [HealthKitService] Permission request failed: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("✅ [HealthKitService] Permissions granted: \(success)")
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // MARK: - Steps
    func getSteps(for date: Date) async throws -> Int {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.invalidType
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: date),
            end: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    print("❌ [HealthKitService] Steps query failed: \(error)")
                    continuation.resume(throwing: error)
                } else if let sum = result?.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    print("✅ [HealthKitService] Steps for \(date): \(steps)")
                    continuation.resume(returning: steps)
                } else {
                    continuation.resume(returning: 0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Active Calories
    func getActiveCalories(for date: Date) async throws -> Double {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitError.invalidType
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: date),
            end: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: caloriesType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    print("❌ [HealthKitService] Active calories query failed: \(error)")
                    continuation.resume(throwing: error)
                } else if let sum = result?.sumQuantity() {
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    print("✅ [HealthKitService] Active calories for \(date): \(calories)")
                    continuation.resume(returning: calories)
                } else {
                    continuation.resume(returning: 0.0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Sleep Hours
    func getSleepHours(for date: Date) async throws -> Double {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.invalidType
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: date),
            end: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    print("❌ [HealthKitService] Sleep query failed: \(error)")
                    continuation.resume(throwing: error)
                } else if let sleepSamples = samples as? [HKCategorySample] {
                    let totalSleepTime = sleepSamples
                        .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
                        .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                    
                    let hours = totalSleepTime / 3600
                    print("✅ [HealthKitService] Sleep hours for \(date): \(hours)")
                    continuation.resume(returning: hours)
                } else {
                    continuation.resume(returning: 0.0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Workout Minutes
    func getWorkoutMinutes(for date: Date) async throws -> Int {
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: date),
            end: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    print("❌ [HealthKitService] Workout query failed: \(error)")
                    continuation.resume(throwing: error)
                } else if let workouts = samples as? [HKWorkout] {
                    let totalMinutes = workouts.reduce(0.0) { $0 + $1.duration } / 60
                    print("✅ [HealthKitService] Workout minutes for \(date): \(totalMinutes)")
                    continuation.resume(returning: Int(totalMinutes))
                } else {
                    continuation.resume(returning: 0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Heart Rate
    func getHeartRate(for date: Date) async throws -> Double? {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.invalidType
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: date),
            end: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    print("❌ [HealthKitService] Heart rate query failed: \(error)")
                    continuation.resume(throwing: error)
                } else if let average = result?.averageQuantity() {
                    let bpm = average.doubleValue(for: HKUnit(from: "count/min"))
                    print("✅ [HealthKitService] Average heart rate for \(date): \(bpm)")
                    continuation.resume(returning: bpm)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Body Weight
    func getBodyWeight() async throws -> Double? {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            throw HealthKitError.invalidType
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    print("❌ [HealthKitService] Weight query failed: \(error)")
                    continuation.resume(throwing: error)
                } else if let weightSample = samples?.first as? HKQuantitySample {
                    let weight = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    print("✅ [HealthKitService] Latest weight: \(weight) kg")
                    continuation.resume(returning: weight)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(query)
        }
    }
}

// MARK: - HealthKit Errors
enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case permissionDenied
    case invalidType
    case noData
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .permissionDenied:
            return "HealthKit permissions not granted"
        case .invalidType:
            return "Invalid HealthKit data type"
        case .noData:
            return "No health data available"
        }
    }
}

// MARK: - Resolver Registration
// Resolver.register { HealthKitServiceImpl() as HealthKitService }
