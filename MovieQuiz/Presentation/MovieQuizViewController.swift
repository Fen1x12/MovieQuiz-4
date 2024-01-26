import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    //MARK: - Lifecycle
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var yesBottun: UIButton!
    @IBOutlet private weak var noBottun: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        yesBottun.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noBottun.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
        alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        super.viewDidLoad()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func show(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
                    title: result.title,
                    message: result.text,
                    buttonText: result.buttonText,
                    buttonAction: { [weak self] in
                        guard let self = self else { return }
                        self.currentQuestionIndex = 0
                        self.correctAnswers = 0
                        self.questionFactory?.requestNextQuestion()
                    }
                )
                alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        let borderColor = isCorrect ? UIColor.ypGreen : UIColor.ypRed
        imageView.layer.borderColor = borderColor.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
                        let quizCount = statisticService.gamesCount
                        let bestGame = statisticService.bestGame
                        let formattedAccuracy = String(format: "%.0f%%", statisticService.totalAccuracy * 100)
                        let text = """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Количество сыгранных квизов: \(quizCount)
                        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                        Средняя точность: \(formattedAccuracy)
                        """
            
            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: results)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    @IBAction private func yesBottunClecked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noBottun(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    
    
}
