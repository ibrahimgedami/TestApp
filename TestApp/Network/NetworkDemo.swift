//
//  NetworkDemo.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 06/06/2025.
//

import SwiftUI
import EZNetworking

class NetworkDemo {
    
    func callApi() async {
        let request = RequestFactoryImpl().build(httpMethod: .POST,
                                                 baseUrlString: "",
                                                 parameters: [],
                                                 headers: [
                                                    .accept(.json),
                                                    .contentType(.json)
                                                 ],
                                                 body: .dictionary([:]))
        do {
            let response = try await AsyncRequestPerformer().perform(request: request, decodeTo: Interaction.self)
        } catch {
            print("Error: \(error)")
        }
    }
    
}
