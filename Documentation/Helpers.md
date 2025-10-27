# Helpers

## AppleSignInHelper

A utility to perform Sign in with Apple and produce a Firebase `AuthCredential`.

Primary API:

```swift
final class AppleSignInHelper: NSObject {
    static func signIn() async throws -> AuthCredential
}
```

Example:

```swift
import FirebaseAuth

let credential = try await AppleSignInHelper.signIn()
let result = try await Auth.auth().signIn(with: credential)
print("Signed in UID:", result.user.uid)
```

Errors:
- `AuthError.configurationError`
- `AuthError.tokenError`
- `AuthError.userCancelled` (or system error)

Notes:
- Handles nonce generation and SHA256 hashing internally.
- Presents Apple authorization UI and resumes via continuation.