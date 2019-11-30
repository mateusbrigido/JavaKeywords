import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
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
        
        self.answersTableView.dataSource = self
        self.answersTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        QuestionService.shared.loadData { (question) in
            self.question = question
        }
    }
    
    @IBAction func textfieldEdited(_ sender: UITextField) {
        guard let text = sender.text, text.count > 0 else { return }

        if let matchedText = question.answers.first(where: { $0 == text }) {
            rightAnswers.insert(matchedText, at: 0)
            sender.text = ""
            answersTableView.reloadData()
            question.answers.remove(matchedText)
        }
    }
    
}

extension QuestionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rightAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        cell.textLabel?.text = self.rightAnswers[indexPath.row]
        
        return cell
    }
}

