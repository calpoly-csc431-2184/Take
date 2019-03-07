import Firebase
import FirebaseAuth
import Foundation
import MultiSlider
import UIKit


class PartnerMatchVC: UIViewController {
    
    let ageSlider = MultiSlider()
    var rightSliderLabel = UITextField()
    var leftSliderLabel = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BluePrimaryDark")
        
        initViews()
    }
    
    @objc func backToProf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func sliderChanged() {
        print("\(self.ageSlider.value)") // e.g., [1.0, 4.5, 5.0]
    }
    
    func initViews() {
        let backButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backToProf))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "Partner Match"
        
        
        rightSliderLabel.text = "yoo"
        leftSliderLabel.text = "yee"
        
        ageSlider.minimumValue = 18
        ageSlider.maximumValue = 35
        ageSlider.trackWidth = 5
        ageSlider.tintColor = UIColor(named: "PinkAccent")
        ageSlider.value = [18, 40]
        ageSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        ageSlider.orientation = .horizontal
        ageSlider.outerTrackColor = UIColor(named: "Placeholder")
        ageSlider.valueLabelPosition = .top
        ageSlider.valueLabels[0].textColor = .white
        ageSlider.valueLabels[1].textColor = .white
        ageSlider.valueLabels[0].font = UIFont(name: "Avenir", size: 16)
        ageSlider.valueLabels[1].font = UIFont(name: "Avenir", size: 16)
        ageSlider.thumbCount = 2
        ageSlider.snapStepSize = 1
        
        let ageLabel = UILabel()
        ageLabel.text = "Age Range"
        ageLabel.font = UIFont(name: "Avenir-Heavy", size: 22)
        ageLabel.textAlignment = .center
        ageLabel.textColor = .white
        
        view.addSubview(ageLabel)
        view.addSubview(ageSlider)
        
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: ageLabel, attribute: .centerX , relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: ageLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: ageLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: ageLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25).isActive = true
        
        ageSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: ageSlider, attribute: .centerX , relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: ageSlider, attribute: .top, relatedBy: .equal, toItem: ageLabel, attribute: .bottom, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: ageSlider, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 3/4, constant: 0).isActive = true
        NSLayoutConstraint(item: ageSlider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20).isActive = true
    }
}
