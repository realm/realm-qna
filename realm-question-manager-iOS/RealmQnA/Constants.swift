////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
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

struct Constants {
    // add host here
    static let syncHost = "q.earlybird.kr"

    static let syncAuthURL = URL(string: "http://\(syncHost):9080")!
    static let syncEventURL = URL(string: "realm://\(syncHost):9080/qna-event-realm")!
    static let syncQuestionURL = "realm://\(syncHost):9080/qna/question-realm"
    
    static let appID = Bundle.main.bundleIdentifier!
}
