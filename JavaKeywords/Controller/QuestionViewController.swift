import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answersTableView: UITableView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var startResetButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var bottomConstraintForKeyboard: NSLayoutConstraint!
    
    lazy private var countdown = Countdown(duration: 300, tick: { [weak self] (remaininingTime) in
        DispatchQueue.main.async {
            self?.countdownLabel.text = remaininingTime
        }
        }, timeOver: { [weak self] in
            self?.showGameOverAlert()
    })
    
    private var gameState: GameState! {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = self.gameState.score
                
                if self.gameState.isRunning {
                    self.startResetButton.setTitle("Reset", for: .normal)
                    self.answerTextField.isEnabled = true
                    self.answerTextField.becomeFirstResponder()
                } else {
                    self.startResetButton.setTitle("Start", for: .normal)
                    self.answerTextField.isEnabled = false
                    self.answerTextField.resignFirstResponder()
                    self.countdownLabel.text = "00:00"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.isHidden = true
        registerKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let loadingAlert = self.showLoadingAlert()
        
        QuestionService.shared.loadData { (question) in
            self.gameState = GameState(question: question)
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: false)
                self.questionLabel.text = self.gameState.question.text
                self.contentView.isHidden = false
                self.answersTableView.dataSource = self
                self.answersTableView.delegate = self
            }
        }
    }
    
    @IBAction func textfieldEdited(_ sender: UITextField) {
        guard let text = sender.text, text.count > 0 else { return }

        if let matchedText = gameState.checkWord(text) {
            gameState.addRightAnswer(matchedText)
            sender.text = ""
            answersTableView.reloadData()
            
            if gameState.won {
                countdown.stop()
                answerTextField.resignFirstResponder()
                showCongratulationsAlert()
            }
        }
    }
    
    @IBAction func startResetButtonPressed(_ sender: Any) {
        if !gameState.isRunning {
            startGame()
        } else {
            resetGame()
        }
    }
    
    private func startGame() {
        gameState.start()
        countdown.start()
    }
    
    private func resetGame() {
        gameState.reset()
        countdown.stop()
        
        answersTableView.reloadData()
    }
    
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension QuestionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameState.rightAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        cell.textLabel?.text = self.gameState.rightAnswers[indexPath.row]
        
        return cell
    }
}

//MARK: - Alert Management
extension QuestionViewController {
    private func showLoadingAlert() -> UIAlertController {
        let title = "Loading"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 40, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        alertController.view.addSubview(loadingIndicator)
        
        self.present(alertController, animated: true)
        
        return alertController
    }
    
    private func showCongratulationsAlert() {
        let title = "Congratulations"
        let message = "Good job! You found all the answers on time. Keep up with the great work"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let playAgainAction = UIAlertAction(title: "Play Again", style: .default, handler: { [weak self] (alertAction) in
            self?.resetGame()
        })
        
        alertController.addAction(playAgainAction)
        
        self.present(alertController, animated: true)
    }
    
    private func showGameOverAlert() {
        let title = "Time finished"
        let message = String(format: "Sorry, time is up! You got %02d out of %02d answers", self.gameState.rightAnswers.count, self.gameState.question.answersTotal)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] (alertAction) in
            self?.resetGame()
        })
        
        alertController.addAction(tryAgainAction)
        
        self.present(alertController, animated: true)
    }
}

//MARK: - Keyboard management
extension QuestionViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let keyboardFrame = sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        bottomConstraintForKeyboard.constant = keyboardFrame.cgRectValue.height - view.safeAreaInsets.bottom 
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded();
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        bottomConstraintForKeyboard.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded();
        }
    }
}
