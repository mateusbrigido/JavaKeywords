import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answersTableView: UITableView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var startResetButton: UIButton!
    
    private var rightAnswers = [String]()
    
    private var question: Question! {
        didSet {
            DispatchQueue.main.async {
                self.questionLabel.text = self.question.text
                self.scoreLabel.text = String(format: "%02d/%02d", self.rightAnswers.count, self.question.answersTotal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        QuestionService.shared.loadData { (question) in
            self.question = question
        }
    }
    
}

