//
//  StudentPaymentsViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit

final class StudentPaymentsViewController: UIViewController {
    // MARK: - Properties
    private let router: StudentRouterProtocol
    
    // MARK: - Init
    init(router: StudentRouterProtocol) {
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
