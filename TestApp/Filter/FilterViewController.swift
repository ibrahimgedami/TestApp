////
////  FilterViewController.swift
////  Seddiqi Retail
////
////  Created by Ibrahim Gedami on 20/11/2023.
////  Copyright © 2023 Amr Elghadban (AmrAngry). All rights reserved.
////
//
//import UIKit
//
//class FilterViewController: UIViewController {
//
//    @IBOutlet weak var groupTableView: UITableView?
//    @IBOutlet weak var subGroupTableView: UITableView?
//    @IBOutlet weak var brandTableView: UITableView?
//    @IBOutlet weak var minTextField: UITextField?
//    @IBOutlet weak var maxTextField: UITextField?
//    @IBOutlet weak var genderSegmentedControl: UISegmentedControl?
//    @IBOutlet weak var toolBarImage: UIImageView?
//    @IBOutlet var backgroundViews: [UIView]?
//    @IBOutlet var toolBarContainerView: UIView?
//    @IBOutlet var titleLabels: [UILabel]?
//    
//    var brands: [APBrand]? = []
//    var groups: [Group]? = []
//    var subGroups: [SubGroup]? = []
//    var selectedGroupIndex, selectedSubGroupIndex, genderIndex: Int?
//    var selectedBrands: [FilterViewModel]? = []
//    var selectedSubGroups: [FilterViewModel]? = []
//    private var centerController: APCenterController?
//    @objc var filterBlock: (([String: Any]) -> ())?
//    var tapBehindGesture: UITapGestureRecognizer?
//    
//    @objc
//    init(controller: APCenterController) {
//        self.centerController = controller
//        super.init(nibName: "FilterViewController", bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let scrollView = self.view as? UIScrollView {
//            scrollView.contentSize = self.view.frame.size
//            scrollView.showsVerticalScrollIndicator = false
//        }
//        
//        [brandTableView, subGroupTableView, groupTableView].forEach({
//            $0?.dataSource = self
//            $0?.delegate = self
//            $0?.backgroundColor = .clear
//            $0?.backgroundView = nil
//            $0?.register(cellType: FilterTableViewCell.self)
//        })
//        
//        let kColor = ThemeManager.color(for: UIColor.k)
//        let iColor = ThemeManager.color(for: UIColor.i)
//        genderSegmentedControl?.setBackgroundImage(UIImage.from(color: iColor), for: .selected, barMetrics: .default)
//        genderSegmentedControl?.setBackgroundImage(UIImage.from(color: kColor), for: .normal, barMetrics: .default)
////        genderSegmentedControl?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.themeTextColor], for: .selected)//
//        genderSegmentedControl?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
//        genderSegmentedControl?.tintColor = iColor
//        titleLabels?.forEach({ $0.textColor = kColor })
//        self.toolBarImage?.image = UIImage.from(color: iColor)
//        backgroundViews?.forEach({ view in
//            view.backgroundColor = ThemeManager.color(for: UIColor.f)
//            view.layer.borderColor = iColor.cgColor
//            view.layer.borderWidth = 1.0
//        })
//        
//        let locationCode = LoggedInInfoManager.retrieveLocationCode()
//        let fetchingManager = CoreDataMediatorManager()
//        brands = fetchingManager.APBrands(withLocation: locationCode)
//        if brands != nil {
//            brandTableView?.reloadData()
//        }
//        groups = fetchingManager.groups()
//        if groups != nil {
//            self.groups = fetchingManager.groups()
//            groupTableView?.reloadData()
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        if tapBehindGesture == nil {
//            tapBehindGesture = UITapGestureRecognizer(target: self, action: #selector(tapBehindDetected(_:)))
//            tapBehindGesture?.numberOfTapsRequired = 1
//            tapBehindGesture?.delegate = self
//            tapBehindGesture?.cancelsTouchesInView = false // So the user can still interact with controls in the modal view
//            if let tapBehindGesture {
//                view.window?.addGestureRecognizer(tapBehindGesture)
//            }
//        }
//    }
//    
//    @IBAction func cancelButtonPressed(_ sender: UIButton) {
//        self.dismissView()
//    }
//    
//    @IBAction func searchButtonPressed(_ sender: UIButton) {
//        var group: Group? = nil
//        var params = [String: Any]()
//        var subGroupCode: String? = ""
//        var brandCode: String? = ""
//        
//        if let selectedGroupIndex, selectedGroupIndex >= 0 {
//            group = groups?[selectedGroupIndex]
//        }
//        
//        if let selectedSubGroups {
//            for (number, _) in selectedSubGroups.enumerated() {
//                let subGroup = group?.subgroups?.sorted(by: { $0.name ?? "" < $1.name ?? "" })
//                subGroupCode?.append("\(subGroup?[number].cd ?? "")_")
//            }
//        }
//        if let subGroupCode, subGroupCode.trimEmpty()?.count ?? -1 > 0 {
//            params["subGroupCode"] = String(subGroupCode.dropLast())
//        }
//        
//        if let selectedBrands {
//            for (number, _) in selectedBrands.enumerated() {
//                if brandCode == nil {
//                    brandCode = ""
//                }
//                brandCode?.append("\(brands?[number].cd ?? "")_")
//            }
//        }
//        if let brandCode, brandCode.trimEmpty()?.count ?? -1 > 0 {
//            params["brandCode"] = String(brandCode.dropLast())
//        }
//        
//        let minStr = (minTextField?.text?.isEmpty ?? true) ? nil : minTextField?.text?.replacingOccurrences(of: ",", with: "")
//        let maxStr = (maxTextField?.text?.isEmpty ?? true) ? nil : maxTextField?.text?.replacingOccurrences(of: ",", with: "")
//        
//        if let group {
//            params["groupCode"] = group.cd
//        }
//        
//        if let minStr = minStr {
//            params["minPrice"] = minStr
//        }
//        
//        if let maxStr = maxStr {
//            params["maxPrice"] = maxStr
//        }
//        
//        dismiss(animated: true) {
//            self.filterBlock?(params)
//        }
//    }
//    
//}
//
//extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == brandTableView {
//            guard let count = brands?.count else { return 0 }
//            return count
//        } else if tableView == groupTableView {
//            guard let groupsCount = groups?.count else { return 0 }
//            return groupsCount
//        } else {
//            guard let subGroupCount = subGroups?.count else { return 0 }
//            return subGroupCount
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(with: FilterTableViewCell.self, for: indexPath) else { return UITableViewCell() }
//        if tableView == brandTableView {
//            guard let name = brands?[indexPath.row].name,
//                  let code = brands?[indexPath.row].cd,
//                  let isSelected = selectedBrands?.contains(where: { ($0.code == brands?[indexPath.row].cd) })
//            else { return UITableViewCell() }
//            let model = FilterViewModel(title: name, code: code, isSelected: isSelected)
//            cell.configCell(model)
//        } else if tableView == groupTableView {
//            guard let name = groups?[indexPath.row].name,
//                  let code = groups?[indexPath.row].cd
//            else { return UITableViewCell() }
//            let isSelected = selectedGroupIndex == indexPath.row
//            let model = FilterViewModel(title: name, code: code, isSelected: isSelected)
//            cell.configCell(model)
//        } else {
//            guard let name = subGroups?[indexPath.row].name,
//                  let code = subGroups?[indexPath.row].cd,
//                  let isSelected = selectedSubGroups?.contains(where: { ($0.code == subGroups?[indexPath.row].cd) })
//            else { return UITableViewCell() }
//            let model = FilterViewModel(title: name, code: code, isSelected: isSelected)
//            cell.configCell(model)
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if tableView == brandTableView {
//            didSelectedBrand(at: indexPath.row)
//        } else if tableView == groupTableView {
//            didSelectedGroup(at: indexPath.row)
//        } else {
//            didSelectedSubGroup(at: indexPath.row)
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40
//    }
//    
//}
//
//extension FilterViewController {
//    
//    func didSelectedBrand(at index: Int) {
//        guard let selectedCode = brands?[index].cd,
//        let selectedName = brands?[index].name
//        else { return }
//        if selectedBrands?.contains(where: {$0.code == selectedCode}) == true {
//            guard let brandIndex = selectedBrands?.firstIndex(where: { $0.code == selectedCode }) else { return }
//            selectedBrands?.remove(at: brandIndex)
//        } else {
//            let model = FilterViewModel(title: selectedName, code: selectedCode, isSelected: true)
//            selectedBrands?.append(model)
//        }
//        brandTableView?.reloadData()
//    }
//    
//    func didSelectedGroup(at index: Int) {
//        selectedGroupIndex = index
//        self.selectedSubGroups?.removeAll()
//        let group = groups?[index]
//        subGroups = group?.subgroups?.sorted(by: { $0.name ?? "" < $1.name ?? "" })
//        groupTableView?.reloadData()
//        subGroupTableView?.reloadData()
//    }
//    
//    func didSelectedSubGroup(at index: Int) {
//        guard let selectedCode = subGroups?[index].cd,
//        let selectedName = subGroups?[index].name
//        else { return }
//        if selectedSubGroups?.contains(where: {$0.code == selectedCode}) == true {
//            guard let subGroupIndex = selectedSubGroups?.firstIndex(where: { $0.code == selectedCode }) else { return }
//            selectedSubGroups?.remove(at: subGroupIndex)
//        } else {
//            let model = FilterViewModel(title: selectedName, code: selectedCode, isSelected: true)
//            selectedSubGroups?.append(model)
//        }
//        subGroupTableView?.reloadData()
//    }
//    
//}
//
//extension FilterViewController: UIGestureRecognizerDelegate {
//    
//    @objc
//    func tapBehindDetected(_ sender: UITapGestureRecognizer) {
//        if sender.state == .ended {
//            var location = sender.location(in: nil)
//            location = CGPoint(x: location.y, y: location.x)
//            if !self.view.point(inside: self.view.convert(location, from: self.view.window), with: nil) {
//                self.view.window?.removeGestureRecognizer(sender)
//                self.dismiss(animated: true)
//            }
//        }
//    }
//
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        return true
//    }
//    
//}
