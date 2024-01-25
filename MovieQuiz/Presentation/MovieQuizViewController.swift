import UIKit

final class MovieQuizViewController: UIViewController {
    //MARK: - Lifecycle
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var yesBottun: UIButton!
    @IBOutlet private weak var noBottun: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactory = QuestionFactory()
    
    override func viewDidLoad() {
        yesBottun.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noBottun.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        
        
        super.viewDidLoad()
    }
    //MARK: - QueationFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?){
        guard let question = question else{
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        questionTitleLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel (
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func showAnswerResult(isCorrect: Bool){
        if isCorrect{
            correctAnswers += 1
        }
        
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesBottun.isEnabled = false
        noBottun.isEnabled = false
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        yesBottun.isEnabled = true
        noBottun.isEnabled = true
        if currentQuestionIndex == questionsAmount - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style:  .default) { [weak self] _ in guard let self = self
            else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            questionFactory.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated:  true, completion: nil)
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
