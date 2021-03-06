//
//  GameURLSelectionView.swift
//  PSXCovers
//
//  Created by Digital on 23/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

@IBDesignable class GameURLSelectionView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var enclosingView: UIVisualEffectView!
    @IBOutlet weak var gameURLField: UITextField!
    @IBOutlet weak var useAnExampleButton: UIButton!

    @IBOutlet weak var delegate: GameURLSelectorViewDelegate? = nil

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            enclosingView.layer.cornerRadius = cornerRadius
            enclosingView.layer.masksToBounds = cornerRadius > 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
        contentView?.prepareForInterfaceBuilder()
    }

    func setupView() {
        let theType = type(of: self)
        let name = String(describing: theType)
        let bundle = Bundle(for: theType)
        bundle.loadNibNamed(name, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        gameURLField.delegate = self
        if #available(iOS 11, *) {
            gameURLField.contentHorizontalAlignment = .leading
        }
    }
}

//MARK: - Text field delegate
extension GameURLSelectionView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.shouldReturnTextField() ?? true
    }
}

//MARK: - Actions
extension GameURLSelectionView {
    @IBAction func didSelectUseAnExample(_ sender: Any) {
        delegate?.didSelectUseAnExample()
    }
}
