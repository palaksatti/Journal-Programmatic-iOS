//
//  SelectedJournalVC.swift
//  JournalProgrammatically
//
//  Created by Palak Satti on 29/02/24.
//

import UIKit
import CoreData

class SelectedJournalVC: UIViewController, UITextViewDelegate{
    
    var selectedEntry: JournalEntry?
    weak var delegate: SelectedJournalDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //UI Components
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let entryTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            entryTextView.contentInset = contentInsets
            entryTextView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        entryTextView.contentInset = contentInsets
        entryTextView.scrollIndicatorInsets = contentInsets
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    func saveEntry() {
        guard let entry = selectedEntry else {
            print("Error: No selected entry found.")
            return
        }

        if let textToSave = entryTextView.text {
            saveToCoreData(entry: entry, content: textToSave)
        }
    }
    
    
    func saveToCoreData(entry: JournalEntry, content:String) {
        entry.content = content
        
        do{
            try context.save()
        }catch{
            print("error saving text to core data \(error.localizedDescription)")
        }
    
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    
    
    func setupUI() {
        let padding:CGFloat = 16
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        view.addSubview(entryTextView)
        
        //save button
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        
        entryTextView.returnKeyType = .done
        entryTextView.delegate = self
        
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            entryTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: padding),
            entryTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            entryTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            entryTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }
    
    
    @objc func saveButtonPressed() {
        saveEntry()
        navigationController?.popViewController(animated: true)
        delegate?.didSaveEntry()
    }
    func populateData() {
        guard let entry = selectedEntry else { return }
        
        titleLabel.text = entry.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: entry.date ?? Date())
        
        entryTextView.text = entry.content ?? ""
    
    }
    
}

protocol SelectedJournalDelegate: AnyObject{
    func didSaveEntry()
}
