//
//  BoardController.swift
//  Wordle
//
//  Created by Mari Batilando on 2/20/23.
//

import Foundation
import UIKit

class BoardController: NSObject,
                       UICollectionViewDataSource,
                       UICollectionViewDelegate,
                       UICollectionViewDelegateFlowLayout {

  // MARK: - Properties
  let numItemsPerRow = 5
  let numRows = 6
  let collectionView: UICollectionView
  var goalWord: [String]

  var numGuesses = 0
  var currRow: Int {
    return numGuesses / numItemsPerRow
  }

  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
    self.goalWord = WordGenerator.generateRandomWord()!.map { String($0) }
    super.init()
    collectionView.delegate = self
    collectionView.dataSource = self
  }

  // MARK: - Public Methods
  func enter(_ string: String) {
    guard numGuesses < numItemsPerRow * numRows else { return }
    let cell = collectionView.cellForItem(at: IndexPath(item: numGuesses, section: 0)) as! LetterCell
    cell.set(letter: string)
    UIView.animate(withDuration: 0.1,
                   delay: 0.0,
                   options: [.autoreverse],
                   animations: {
      cell.transform = cell.transform.scaledBy(x: 1.05, y: 1.05)
    }, completion: { finished in
      cell.transform = CGAffineTransformIdentity
    })
    
    if isFinalGuessInRow() {
      markLettersInRow()
      
      // Check if player won
      let currentRowCells = (0..<numItemsPerRow).map { index -> LetterCell in
        let indexPath = IndexPath(item: numGuesses - (numItemsPerRow - 1) + index, section: 0)
        return collectionView.cellForItem(at: indexPath) as! LetterCell
      }
      
      let currentGuess = currentRowCells.map { $0.letterLabel.text! }.joined()
      let goalWordString = goalWord.joined()
      
      if currentGuess == goalWordString {
        // Player won!
        showGameOverAlert(won: true)
        return
      } else if currRow == numRows - 1 {
        // Player lost - no more rows
        showGameOverAlert(won: false)
        return
      }
    }
    numGuesses += 1
  }

  func deleteLastCharacter() {
    guard numGuesses > 0 && numGuesses % numItemsPerRow != 0 else { return }
    let cell = collectionView.cellForItem(at: IndexPath(item: numGuesses - 1, section: 0)) as! LetterCell
    numGuesses -= 1
    cell.clearLetter()
    cell.set(style: .initial)
  }
  
  private func showGameOverAlert(won: Bool) {
    let alertController = UIAlertController(
      title: won ? "Congratulations! 🎉" : "Game Over",
      message: won ? "You won! Would you like to play again?" : "The word was '\(goalWord.joined())'. Would you like to try again?",
      preferredStyle: .alert
    )
    
    let restartAction = UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
      self?.resetGame()
    }
    let cancelAction = UIAlertAction(title: "Close", style: .cancel)
    
    alertController.addAction(restartAction)
    alertController.addAction(cancelAction)
    
    if let viewController = collectionView.window?.rootViewController {
      viewController.present(alertController, animated: true)
    }
  }
  
  private func resetGame() {
    numGuesses = 0
    goalWord = WordGenerator.generateRandomWord()!.map { String($0) }
    
    // Reset all cells
    for i in 0..<(numItemsPerRow * numRows) {
      let indexPath = IndexPath(item: i, section: 0)
      let cell = collectionView.cellForItem(at: indexPath) as! LetterCell
      cell.clearLetter()
      cell.set(style: .initial)
    }
  }
}
