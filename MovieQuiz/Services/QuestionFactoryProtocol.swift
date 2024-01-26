//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by  Admin on 25.01.2024.
//

import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    var delegate: QuestionFactoryDelegate? { get set}
    func requestNextQuestion() -> QuizQuestion?
}
