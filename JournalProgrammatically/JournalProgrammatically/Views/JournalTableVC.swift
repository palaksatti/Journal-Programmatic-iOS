//
//  ViewController.swift
//  JournalProgrammatically
//
//  Created by Palak Satti on 29/02/24.
//

import UIKit
import CoreData

class JournalTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectedJournalDelegate {

    var journalEntries = [JournalEntry]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let journalTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchEntries()

        journalTableView.dataSource = self
        journalTableView.delegate = self
        
    }

    // MARK: - UI SETUP
    func configureUI() {
        navigationItem.title = "Your Journal"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))

        journalTableView.register(UITableViewCell.self, forCellReuseIdentifier: "JournalCell")

        view.addSubview(journalTableView)

        journalTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            journalTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            journalTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            journalTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            journalTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }

    // MARK: - Data Methods
    func fetchEntries() {
        let fetchRequest: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()

        // Sort the entries by date in descending order
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            journalEntries = try context.fetch(fetchRequest)
            journalTableView.reloadData()
        } catch {
            print("Error fetching entries: \(error.localizedDescription)")
        }
    }


    func saveEntry() {
        do {
            try context.save()
        } catch {
            print("Error saving entry: \(error.localizedDescription)")
        }
        journalTableView.reloadData()
    }

    func didSaveEntry() {
        fetchEntries()
        journalTableView.reloadData()
    }

    // MARK: - Button Action
    @objc func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Entry", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { [self] _ in
            let newEntry = JournalEntry(context: self.context)
            newEntry.title = textField.text
            newEntry.date = Date()
            
            journalEntries.insert(newEntry, at: 0)
            saveEntry()
            journalTableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add new journal entry"
            textField = alertTextField
        }

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journalEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalCell", for: indexPath)
        let entry = journalEntries[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = entry.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        if let date = entry.date {
            content.secondaryText = dateFormatter.string(from: date)
        } else {
            content.secondaryText = ""
        }

        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = journalEntries[indexPath.row]
        showEntry(for: selectedRow)
    }

    func showEntry(for entry: JournalEntry) {
        let destinationVC = SelectedJournalVC()
        destinationVC.selectedEntry = entry
        destinationVC.delegate = self
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    // MARK: - Swipe to Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entryToDelete = journalEntries[indexPath.row]
            context.delete(entryToDelete)

            do {
                try context.save()
                journalEntries.remove(at: indexPath.row)
                journalTableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting entry: \(error.localizedDescription)")
            }
        }
    }
}

