//
//  TestAppApp.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/05/2024.
//

import SwiftUI
import AppBase
import CombineNetwork

public struct MockedToken {
    
    static func mockData() -> Token? {
        let model = mockSuccessCase()?.content
        return model
    }
    
    static private func mockSuccessCase() -> BaseResponse<Token>? {
        guard let model = FileHelper.shared.decodeJSONFromFile(filename: "R.file.branchAuthJsonJson.name", as: BaseResponse<Token>.self) else { return nil }
        return model
    }
    
    static func mockFailureCase() -> BaseResponse<Token>? {
        let jsonString = """
        {
            "status": 1003,
            "message": "Ref.#403_1-PARAM003\\nLocation username is mandatory.",
            "content": null,
            "pagination": null,
            "error": {
                "code": "PARAM003",
                "message": "Location username is mandatory.",
                "reason": "Location username is mandatory."
            }
        }
        """
        guard let model = FileHelper.shared.decodeJSONFromString(jsonString: jsonString, as: BaseResponse<Token>.self) else {
            debugPrint("Failed to decode JSON string")
            return nil
        }
        return model
    }
    
}

@main
struct TestAppApp: App {
    
    var body: some Scene {
        WindowGroup {
            InvoiceView()
        }
    }
    
}
