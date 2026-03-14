//
//  StudentLessonsViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit

final class StudentLessonsViewController: UIViewController {
    // MARK: - Properties
    private weak var router: AuthRouterProtocol?
    
    // MARK: - Init
    init(router: AuthRouterProtocol?) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
