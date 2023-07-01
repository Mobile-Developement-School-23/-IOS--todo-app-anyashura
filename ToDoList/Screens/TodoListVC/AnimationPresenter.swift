//
//  AnimationPresenter.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 01.07.2023.
//

import Foundation
import UIKit

final class AnimationPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    
    private let cellFrame: CGRect
    
    // MARK: - Init
    
    init(cellFrame: CGRect) {
        self.cellFrame = cellFrame
    }
    
    // MARK: - Methods
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let secondVC = transitionContext.viewController(forKey: .to) else
        {
            transitionContext.completeTransition(true)
            return
        }
        transitionContext.containerView.addSubview(secondVC.view)
        
        guard let cellSnapshot = secondVC.view.snapshotView(afterScreenUpdates: true) else { return }
        let endFrame = transitionContext.finalFrame(for: secondVC)
        cellSnapshot.frame = cellFrame
        secondVC.view.isHidden = true
        
        transitionContext.containerView.addSubview(cellSnapshot)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {cellSnapshot.frame = endFrame}) { _ in
            secondVC.view.isHidden = false
            cellSnapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}

