//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by  Admin on 26.01.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var buttonAction: (()->Void)?
}
