//
//  QuestionResponse.swift
//  Flags Challenge
//
//  Created by mac on 22/09/2025.
//


import Foundation

struct QuestionResponse: Codable {
    let questions: [Question]
}

struct Question: Codable, Identifiable {
    var id: Int { answer_id }
    let answer_id: Int
    let countries: [Country]
    let country_code: String
}

struct Country: Codable, Identifiable {
    let country_name: String
    let id: Int
}
