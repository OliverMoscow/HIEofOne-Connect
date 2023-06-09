/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The root view of the app where the user can authorize access to their health records and select a category to view.
 */

import HealthKit
import UIKit

class MainViewController: UITableViewController {
    let cellReuseIdentifier = "Cell"
    var authorized: Bool = false
    
    @IBOutlet weak var authorizeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    /// An enumeration that defines two categories of data types: Health Records and Fitness Data.
    /// Health Records enumerates the clinical records the app would like to access and Fitness Data contains the
    /// fitness data types.
    enum Section {
        case healthRecords
        case fitnessData
        
        var displayName: String {
            switch self {
            case .healthRecords:
                return "Health Records"
            case .fitnessData:
                return "Fitness Data"
            }
        }
        
        var types: [HKSampleType] {
            switch self {
            case .healthRecords:
                return [
                    HKObjectType.clinicalType(forIdentifier: .allergyRecord)!,
                    HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)!,
                    HKObjectType.clinicalType(forIdentifier: .conditionRecord)!,
                    HKObjectType.clinicalType(forIdentifier: .immunizationRecord)!,
                    HKObjectType.clinicalType(forIdentifier: .labResultRecord)!,
                    HKObjectType.clinicalType(forIdentifier: .medicationRecord)!,
                    HKObjectType.clinicalType(forIdentifier: .procedureRecord)!
                ]
                
            case .fitnessData:
                return []
//                return [
//                    HKObjectType.quantityType(forIdentifier: .stepCount)!,
//                    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
//                ]
            }
        }
    }
    
    /// Create an instance of the health store. Use the health store to request authorization to access
    /// HealthKit records and to query for the records.
    let healthStore = HKHealthStore()
    
    var sampleTypes: Set<HKSampleType> {
        return Set(Section.healthRecords.types + Section.fitnessData.types)
    }
    
    
    /// The health store's requestAuthorization method presents a permissions sheet to the user, allowing the user to
    /// choose what data they allow the app to access.
    func requestAuthorization(_ sender: AnyObject? = nil) {
        healthStore.requestAuthorization(toShare: nil, read: sampleTypes) { (success, error) in
            DispatchQueue.main.async {
                self.authorized = success
                self.authorizeBtn.isEnabled = !success
                self.shareBtn.isEnabled = success
                guard success else {
                    self.handleError(error)
                    return
                }
            }
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        /// Before accessing clinical records and other health data from HealthKit, the app must ask the user for
        /// authorization. The health store's getRequestStatusForAuthorization method allows the app to check
        /// if user has already granted authorization. If the user hasn't granted authorization, the app
        /// requests authorization from the person using the app.
        healthStore.getRequestStatusForAuthorization(toShare: Set(), read: sampleTypes) { (status, error) in
            DispatchQueue.main.async {
                self.authorized = status != .shouldRequest
                self.authorizeBtn.isEnabled = !self.authorized
                self.shareBtn.isEnabled = self.authorized
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table View
    
    var sections: [Section] {
        var result: [Section] = []
        
        /// Check whether the device supports health records, because the feature is not yet available worldwide.
        if healthStore.supportsHealthRecords() {
            result.append(.healthRecords)
        }
        
        result.append(.fitnessData)
        return result
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        ///Old code was to present multiple sections where the second one was health kit data that is not needed for this project
//        return sections.count
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        let section = sections[sectionIndex]
        return section.types.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        let section = sections[sectionIndex]
        return coolify(section.displayName)
    }
    
    /// Display all available sections in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        let section = sections[indexPath.section]
        let type = section.types[indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = coolify(type.categoryDisplayName)
        
        return cell
    }
    
    /// Tapping on a particular row opens a category view initialized with data from that category, if available.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let type = section.types[indexPath.row]
        
        let displayItemProvider = categoryDisplayItemProvider(for: type)
        
        let categoryViewController = CategoryViewController(sampleType: type, displayItemProvider: displayItemProvider, healthStore: healthStore)
        self.navigationController?.pushViewController(categoryViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: -
    
    /// Set up an alert controller to display messages to the user as needed.
    func present(message: String, titled title: String) {
        dispatchPrecondition(condition: .onQueue(.main))
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    func handleError(_ error: Error?) {
        present(message: error?.localizedDescription ?? "Unknown Error", titled: "Error")
    }
    
  
    @IBAction func authorizeTapped(_ sender: Any) {
        self.requestAuthorization()
    }
    
    ///Share records with NOSH
    @IBAction func shareTapped(_ sender: Any) {
        let scanViewController = ScannerViewController() // Replace `ScanViewController` with your custom view controller for scanning
        scanViewController.modalPresentationStyle = .fullScreen
        present(scanViewController, animated: true, completion: nil)
    }
    
}
