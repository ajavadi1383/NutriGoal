//
//  UserProfileUseCase.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

final class UserProfileUseCase: UserProfileUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func updateUserProfile(_ user: User) async throws -> User {
        return try await userRepository.updateUser(user)
    }
    
    func getUserProfile() async throws -> User? {
        return try await userRepository.getCurrentUser()
    }
    
    func calculateUserGoals(_ user: User) -> (CalorieRange, MacroTargets) {
        return (user.calorieRange, user.macroTargets)
    }
} 