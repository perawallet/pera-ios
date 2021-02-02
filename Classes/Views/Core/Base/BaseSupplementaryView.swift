//
//  BaseSupplementaryView.swift

import UIKit

class BaseSupplementaryView<T: UIView>: UICollectionReusableView {
   
    typealias ContextView = T
    
    private(set) lazy var contextView = ContextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureAppearance() {
    }
    
    func prepareLayout() {
        setupContextViewLayout()
    }
    
    private func setupContextViewLayout() {
        addSubview(contextView)
        
        contextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }

    static func getContext() -> ContextView.Type {
        return ContextView.self
    }
}
