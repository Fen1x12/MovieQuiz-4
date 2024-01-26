//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by  Admin on 26.01.2024.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}