//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by  Admin on 26.01.2024.
//

import Foundation

protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? { get set }
    func show(alertModel: AlertModel)
}
