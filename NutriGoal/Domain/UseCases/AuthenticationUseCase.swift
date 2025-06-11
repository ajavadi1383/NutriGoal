//
//  AuthenticationUseCase.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

final class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let authRepository: AuthenticationRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(
        authRepository: AuthenticationRepositoryProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    func signUp(email: String, password: String) async throws -> AuthResult {
        let authResult = try await authRepository.signUp(email: email, password: password)
        
        // If this is a new user, we'll need to create their profile during onboarding
        // For now, just return the auth result
        return authResult
    }
    
    func signIn(email: String, password: String) async throws -> AuthResult {
        return try await authRepository.signIn(email: email, password: password)
    }
    
    func signInWithApple() async throws -> AuthResult {
        return try await authRepository.signInWithApple()
    }
    
    func signOut() async throws {
        try await authRepository.signOut()
    }
    
    func getCurrentUser() async throws -> User? {
        return try await userRepository.getCurrentUser()
    }
    
    func isUserLoggedIn() -> Bool {
        return userRepository.isUserLoggedIn()
    }
} 