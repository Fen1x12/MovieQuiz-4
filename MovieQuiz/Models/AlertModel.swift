//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by  Admin on 26.01.2024.
//
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: ((UIAlertAction) -> Void)?
}

