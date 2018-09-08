//
//  ViewController.swift
//  ScheduleSelector
//
//  Created by Mendoza, Christine Roanne on 2018/02/28.
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import UIKit

struct Constants {
    static let pickerViewHeight: CGFloat = 244.0
}

enum SelectedPicker {
    case none
    case date
    case timeslot
}

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ScheduleDataProviderDelegate {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var pickerContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var dateSelectionButton: UIButton!
    @IBOutlet weak var timeslotSelectionButton: UIButton!
    
    var dataProvider: ScheduleDataProvider!
    var selectedPickerOption: SelectedPicker = .none {
        didSet {
            switch selectedPickerOption {
            case .none:
                hidePickerView()
            case .date:
                fallthrough
            case .timeslot:
                showPickerView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider = ScheduleDataProvider(delegate: self, gateway: AvailabilityGateway())
        dataProvider.fetchData()
    }

    
    // MARK: IBActions
    
    @IBAction func selectDateOption(_ sender: Any) {
        selectedPickerOption = .date
    }
    
    @IBAction func selectTimeslotOption(_ sender: Any) {
        selectedPickerOption = .timeslot
    }
    
    @IBAction func selectPickerOption(_ sender: Any) {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        switch selectedPickerOption {
        case .date:
            dataProvider.didSelectScheduleAtIndex(index: selectedRow)
        case .timeslot:
            if dataProvider.canSelectTimeslotAtIndex(index: selectedRow) {
                dataProvider.didSelectTimeslotAtIndex(index: selectedRow)
            } else {
                showTimeslotSelectionError()
            }
        default: break
        }
    }
    
    @IBAction func cancelPickerOption(_ sender: Any) {
        selectedPickerOption = .none
    }
    
    @IBAction func reserveSchedule(_ sender: Any) {
        showSelectionConfirmation()
    }
    
    // MARK: UIPicker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedPickerOption {
        case .date:
            return dataProvider.numberOfSchedules()
        case .timeslot:
            return dataProvider.numberOfTimeslotForSelectedSchedule()
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch selectedPickerOption {
        case .date:
            return dataProvider.stringForDateAtIndex(index: row)
        case .timeslot:
            return dataProvider.stringForTimeslotAtIndex(index: row)
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    
    // MARK: ScheduleDataProviderDelegate
    
    func didUpdateSelection(date: String, time: String) {
        DispatchQueue.main.async {
            self.dateSelectionButton.setTitle(date, for: .normal)
            self.timeslotSelectionButton.setTitle(time, for: .normal)
            self.selectedPickerOption = .none
            self.loadingView.isHidden = true
        }
    }
    
    func dataFetchDidFail() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
            self.showDataFetchError()
        }
    }
    
    // MARK: UI Helpers
    
    private func loadData() {
        loadingView.isHidden = false
        dataProvider.fetchData()
    }
    
    private func hidePickerView() {
        if self.pickerContainerBottomConstraint.constant == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.pickerContainerBottomConstraint.constant = -(Constants.pickerViewHeight)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func showPickerView() {
        if abs(self.pickerContainerBottomConstraint.constant) == Constants.pickerViewHeight {
            pickerView.reloadAllComponents()
            let selectedRow = selectedPickerOption == .date ? dataProvider.indexOfSelectedDate() : dataProvider.indexOfSelectedTimeslot()
            pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            UIView.animate(withDuration: 0.3, animations: {
                self.pickerContainerBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func showTimeslotSelectionError() {
        let alert = UIAlertController.init(title: nil, message: "この時間枠は、現在選びません", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showSelectionConfirmation() {
        let alert = UIAlertController.init(title: nil,
                                           message: "以下の内容でよろしいですか？\n日時：\(dataProvider.selectedSchedule())",
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "戻る", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "確認する", style: .default) { (alert) in
            self.showToast(message: "予約は完了しました。")
        })
        present(alert, animated: true, completion: nil)
    }
    
    private func showDataFetchError() {
        let alert = UIAlertController.init(title: nil, message: "エラーが発生しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "再読み込み", style: .default) { (alert) in
            self.loadData()
        })
        present(alert, animated: true, completion: nil)
    }
}

// ref: https://stackoverflow.com/a/35130932
extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: 75, y: self.view.frame.size.height-100, width: self.view.frame.size.width - 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
