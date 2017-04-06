////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import RealmSwift

// Private Helpers

private var deduplicationNotificationToken: NotificationToken! // FIXME: Remove once core supports ordered sets: https://github.com/realm/realm-core/issues/1206

private var authenticationFailureCallback: (() -> Void)?

public func setDefaultRealmConfiguration(with user: SyncUser) {
    SyncManager.shared.errorHandler = { error, session in
        if let authError = error as? SyncAuthError, authError.code == .invalidCredential {
            authenticationFailureCallback?()
        }
    }
}

// Internal Functions

func isDefaultRealmConfigured() -> Bool {
    return try! !Realm().isEmpty
}

// returns true on success
func configureDefaultRealm() -> Bool {
    if let user = SyncUser.current {
        setDefaultRealmConfiguration(with: user)
        return true
    }
    return false
}

func resetDefaultRealm() {
    guard let user = SyncUser.current else {
        return
    }

    deduplicationNotificationToken.stop()

    user.logOut()
}

func setAuthenticationFailureCallback(callback: (() -> Void)?) {
    authenticationFailureCallback = callback
}

func authenticate(username: String, password: String, register: Bool, callback: @escaping (NSError?) -> Void) {
    let credentials = SyncCredentials.usernamePassword(username: username, password: password, register: register)
    SyncUser.logIn(with: credentials, server: Constants.syncAuthURL) { user, error in
        DispatchQueue.main.async {
            if let user = user {
                setDefaultRealmConfiguration(with: user)
            }

            callback(error as NSError?)
        }
    }
}

private extension NSError {

    convenience init(error: NSError, description: String?, recoverySuggestion: String?) {
        var userInfo = error.userInfo

        userInfo[NSLocalizedDescriptionKey] = description
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion

        self.init(domain: error.domain, code: error.code, userInfo: userInfo)
    }

}
