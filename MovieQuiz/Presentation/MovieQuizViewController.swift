import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var yesBottun: UIButton!
    @IBOutlet private weak var noBottun: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let movieQuizPresenter = MovieQuizPresenter(viewController: self)
        presenter = movieQuizPresenter
        alertPresenter = AlertPresenter(viewController: self)
        showLoadingIndicator()
        
        questionLabel.font = UIFont(name:"YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name:"YSDisplay-Medium", size: 20)
        yesBottun.titleLabel?.font = UIFont(name:"YSDisplay-Medium", size: 20)
        noBottun.titleLabel?.font = UIFont(name:"YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name:"YSDisplay-Medium", size: 20)
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    func enableButtons() {
        noBottun.isEnabled = true
        yesBottun.isEnabled = true
    }
    
    func disableButtons() {
        noBottun.isEnabled = false
        yesBottun.isEnabled = false
    }
    
    func show(quiz step: QuizStepViewModel) {
        enableButtons()
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func showAlert(quiz alertModel: AlertModel) {
        alertPresenter?.showAlert(quiz: alertModel)
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        disableButtons()
        
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] _ in
                guard let self = self else { return }
                
                self.presenter?.restartGame()
                
            }
        
        alertPresenter?.showAlert(quiz: model)
    }
}
