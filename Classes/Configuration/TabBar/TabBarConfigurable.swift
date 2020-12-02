//
//  TabBarConfigurable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

protocol TabBarConfigurable: AnyObject {
    var isTabBarHidden: Bool { get set }
    var tabBarSnapshot: UIView? { get set }
}

extension TabBarConfigurable where Self: UIViewController {
    func setNeedsTabBarAppearanceUpdateOnAppearing(animated: Bool = true) {
        guard let tabBarContainer = tabBarContainer else {
            return
        }
        
        isTabBarHidden.continue(
            isTrue: { tabBarContainer.setTabBarHidden(true, animated: animated) },
            isFalse: updateTabBarAppearanceOnStacked
        )
    }

    func setNeedsTabBarAppearanceUpdateOnAppeared() {
        guard let tabBarContainer = tabBarContainer else {
            return
        }

        if !isTabBarHidden {
            removeTabBarSnapshot()
        }
        tabBarContainer.setTabBarHidden(isTabBarHidden, animated: false)
    }

    func setNeedsTabBarAppearanceUpdateOnDisappeared() {
        if tabBarContainer == nil {
            return
        }
        updateTabBarAppearanceOnPopped()
    }
}

extension TabBarConfigurable where Self: UIViewController {
    private func updateTabBarAppearanceOnStacked() {
        if isTabBarHidden {
            return
        }

        guard let stackedViewControllers = navigationController.unwrapIfPresent(either: { $0.viewControllers }) else {
            return
        }
        
        guard let stackIndex = stackedViewControllers.firstIndex(of: self)
            .unwrapConditionally(
                where: { $0 > stackedViewControllers.startIndex && $0
                    == stackedViewControllers.index(before: stackedViewControllers.endIndex)
                }
            ) // 1 -> Root, 2 -> Popping
        else {
            return
        }
        
        guard let previousViewControllerInStack = stackedViewControllers[stackedViewControllers.index(
            before: stackIndex
        )] as? TabBarConfigurable else {
            return
        }

        if previousViewControllerInStack.isTabBarHidden {
            addTabBarSnaphot()
        }
    }

    private func updateTabBarAppearanceOnPopped() {
        if isTabBarHidden {
            return
        }

        guard let stackedViewControllers = navigationController.unwrapIfPresent(either: { $0.viewControllers }) else {
            return
        }
        
        guard let nextStackIndex = stackedViewControllers.firstIndex(of: self)
            .unwrapIfPresent(either: { stackedViewControllers.index(after: $0) })
            .unwrapConditionally(where: { $0 < stackedViewControllers.endIndex })
        else {
            return
        }
        
        guard let nextViewControllerInStack = stackedViewControllers[nextStackIndex] as? TabBarConfigurable else {
            return
        }

        if nextViewControllerInStack.isTabBarHidden {
            addTabBarSnaphot()
        }
    }

    private func addTabBarSnaphot() {
        if tabBarSnapshot.unwrapConditionally(where: { $0.isDescendant(of: view) }) != nil {
            return
        }

        guard let tabBarContainer = tabBarContainer else {
            return
        }

        let tabBar = tabBarContainer.tabBar

        guard let newTabBarSnaphot = tabBar.snapshotView(afterScreenUpdates: true) else {
            return
        }
        
        if !isDarkModeDisplay {
            newTabBarSnaphot.applyShadow(tabBarShadow)
        }
        
        view.addSubview(newTabBarSnaphot)
        newTabBarSnaphot.frame = CGRect(
            origin: CGPoint(x: 0.0, y: tabBarContainer.view.bounds.height - tabBar.bounds.height),
            size: tabBar.bounds.size
        )
        
        newTabBarSnaphot.updateShadowLayoutWhenViewDidLayoutSubviews()

        tabBarSnapshot = newTabBarSnaphot
    }

    private func removeTabBarSnapshot() {
        tabBarSnapshot?.removeFromSuperview()
        tabBarSnapshot = nil
    }
}
