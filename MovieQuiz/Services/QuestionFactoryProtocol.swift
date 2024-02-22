//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by  Admin on 25.01.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    func loadData()
}
