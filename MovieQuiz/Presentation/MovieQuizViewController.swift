import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var yesBottun: UIButton!
    @IBOutlet private weak var noBottun: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService = StatisticServiceImplementation()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        imageView.backgroundColor = UIColor.ypBlack
        
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()

        super.viewDidLoad()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
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
    
    func show(alert: UIAlertController) {
        hideLoadingIndicator()
        self.present(alert, animated: true)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать снова",
                                    buttonAction: { [weak self] in
                                        guard let self = self else { return }
                                        self.currentQuestionIndex = 0
                                        self.correctAnswers = 0
                                        self.questionFactory?.loadData()
                                    }
        )
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
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
        hideLoadingIndicator()
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
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
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    @IBAction private func yesBottunClecked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = true
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        statisticService.corectAnswerAll += isCorrect ? 1 : 0
        statisticService.totalAnswerAll += 1
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func noBottun(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        statisticService.corectAnswerAll += isCorrect ? 1 : 0
        statisticService.totalAnswerAll += 1
        
        showAnswerResult(isCorrect: isCorrect)
    }
    
    
    
    
    
}
