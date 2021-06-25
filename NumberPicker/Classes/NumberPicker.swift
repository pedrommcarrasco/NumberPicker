//
//  NumberPicker.swift
//  NumberPicker
//
//  Created by Yash Thaker on 20/10/18.
//  Copyright © 2018 Yash Thaker. All rights reserved.
//

import UIKit

public protocol NumberPickerDelegate {
    func selectedNumber(_ number: Int)
}

public class NumberPicker: UIViewController {

    public var delegate: NumberPickerDelegate?
    public var maxNumber: Int = 0
    public var minNumber: Int = 0
    public var bgGradients: [UIColor] = [.white, .white]
    public var tintColor = UIColor.black
    public var heading = ""
    public var defaultSelectedNumber: Int = 0

    var bgView, pickerView: UIView!
    var cancelBtn, doneBtn: UIButton!
    var titleLbl, numberLbl: UILabel!

    var pickerViewBottomConstraint: NSLayoutConstraint?
    var cancelBtnLeftConstraint: NSLayoutConstraint?
    var doneBtnRightConstraint: NSLayoutConstraint?
    var titleLblTopConstraint: NSLayoutConstraint?

    var isPickerOpen = false

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 1, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    var layout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }

    var cellWidthIncludingSpacing: CGFloat {
        return layout.itemSize.width + layout.minimumLineSpacing
    }

    let cellId = "cellId"

    lazy var arrowImageView: UIImageView = {
        let img = UIImage(systemName: "arrow.up")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.tintColor = tintColor
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()

    // this is for iphone x
    var bottomPadding: CGFloat = 0.0

    var selectedNumber: Int = 0 {
        didSet {
            self.numberLbl.text = "\(selectedNumber)"
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        initializeViews()
        addViews()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.animatePickerView()
            self.scrollToDefaultNumber(self.defaultSelectedNumber)
        }
    }

    func initializeViews() {
        bgView = createView()
        bgView.backgroundColor = UIColor(white: 0, alpha: 0.65)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissController)))
        bgView.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(dismissController)))

        pickerView = createView()
        pickerView.layer.masksToBounds = true

        cancelBtn = createBtn(UIImage(systemName: "xmark"))
        doneBtn = createBtn(UIImage(systemName: "checkmark"))

        titleLbl = createLabel(heading, fontSize: 18)
        numberLbl = createLabel("0", fontSize: 30)

        collectionView.register(NumberPickerLineCell.self, forCellWithReuseIdentifier: cellId)
    }

    func addViews() {
        self.view.addSubview(bgView)
        bgView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        bgView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        bgView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        if let window = UIApplication.shared.keyWindow {
            bottomPadding = window.safeAreaInsets.bottom
        }

        self.view.addSubview(pickerView)
        pickerView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        pickerView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        pickerViewBottomConstraint = pickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 250 + bottomPadding)
        pickerViewBottomConstraint?.isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: 250 + bottomPadding).isActive = true

        pickerView.applyGradient(colors: bgGradients, type: .cross)
        pickerView.roundCorners([.topLeft, .topRight], radius: 10)

        pickerView.addSubview(cancelBtn)
        cancelBtnLeftConstraint = cancelBtn.leftAnchor.constraint(equalTo: pickerView.leftAnchor, constant: -54)
        cancelBtnLeftConstraint?.isActive = true
        cancelBtn.topAnchor.constraint(equalTo: pickerView.topAnchor).isActive = true
        cancelBtn.widthAnchor.constraint(equalToConstant: 46).isActive = true
        cancelBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        pickerView.addSubview(doneBtn)
        doneBtnRightConstraint = doneBtn.rightAnchor.constraint(equalTo: pickerView.rightAnchor, constant: 54)
        doneBtnRightConstraint?.isActive = true
        doneBtn.topAnchor.constraint(equalTo: pickerView.topAnchor).isActive = true
        doneBtn.widthAnchor.constraint(equalToConstant: 46).isActive = true
        doneBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        pickerView.addSubview(titleLbl)
        titleLbl.centerXAnchor.constraint(equalTo: pickerView.centerXAnchor).isActive = true
        titleLblTopConstraint = titleLbl.topAnchor.constraint(equalTo: pickerView.topAnchor, constant: -86)
        titleLblTopConstraint?.isActive = true
        titleLbl.heightAnchor.constraint(equalToConstant: 46).isActive = true

        pickerView.addSubview(numberLbl)
        numberLbl.centerXAnchor.constraint(equalTo: pickerView.centerXAnchor).isActive = true
        numberLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor).isActive = true

        pickerView.addSubview(collectionView)
        collectionView.leftAnchor.constraint(equalTo: pickerView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: pickerView.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: pickerView.topAnchor, constant: 125).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: pickerView.bounds.width / 2, bottom: 0, right: pickerView.bounds.width / 2)

        pickerView.addSubview(arrowImageView)
        arrowImageView.centerXAnchor.constraint(equalTo: pickerView.centerXAnchor).isActive = true
        arrowImageView.centerYAnchor.constraint(equalTo: pickerView.centerYAnchor, constant: 32 - bottomPadding/2).isActive = true
    }

    func scrollToDefaultNumber(_ number: Int) {
        if number < minNumber, number > maxNumber { return }
        let offset = CGPoint(x: CGFloat(number - minNumber) * cellWidthIncludingSpacing - collectionView.contentInset.left, y: -collectionView.contentInset.top)
        collectionView.setContentOffset(offset, animated: true)
    }

    @objc func btnTapped(_ sender: UIButton) {
        self.animatePickerView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: true, completion: {
                if sender == self.doneBtn {
                    self.delegate?.selectedNumber(self.selectedNumber)
                }
            })
        }
    }

    @objc func dismissController() {
        self.animatePickerView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func animatePickerView() {
        pickerViewBottomConstraint?.constant = isPickerOpen ? 250 + bottomPadding + 10 : 0
        let animationDuration = isPickerOpen ? 0.4 : 0.5

        isPickerOpen = !isPickerOpen

        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

            self.view.layoutIfNeeded()
        })

        animateButtons(animationDuration)
    }

    func animateButtons(_ duration: Double) {
        cancelBtnLeftConstraint?.constant = isPickerOpen ? 8 : -54
        doneBtnRightConstraint?.constant = isPickerOpen ? -8 : 54
        titleLblTopConstraint?.constant = isPickerOpen ? 0 : -86

        UIView.animate(withDuration: duration, delay: duration/2, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

            self.view.layoutIfNeeded()
        })
    }

    func createView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func createLabel(_ text: String, fontSize: CGFloat) -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "HelveticaNeue-Medium", size: fontSize)
        lbl.text = text
        lbl.textColor = tintColor
        return lbl
    }

    func createBtn(_ image: UIImage?) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(image, for: .normal)
        btn.tintColor = tintColor
        btn.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
        return btn
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}

extension NumberPicker: UICollectionViewDelegate, UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxNumber + 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
            as! NumberPickerLineCell
        cell.calcLineViewHeight(indexPath.row, bgColor: tintColor)
        return cell
    }
}

extension NumberPicker: UIScrollViewDelegate {

    // this is for exactly stop on line
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offset = scrollView.contentOffset
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = Int(round(index))

        selectedNumber = max(minNumber, roundedIndex + minNumber)
    }
}

