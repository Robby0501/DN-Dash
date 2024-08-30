//
//  CustomView.swift
//  IP.Check
//
//  Created by Robby Ulrich on 8/29/24.
//
import Cocoa
import Foundation
import SystemConfiguration

class CustomView: NSView {
    private let containerView: NSView
    private let label: NSTextField
    private let flagLabel: NSTextField
    private let resultLabel: NSTextField
    private let homeCountryLabel: NSTextField
    private let homeCountryResultLabel: NSTextField
    var currentCountry: String?
    
    private var networkObserver: NSObjectProtocol?
    private var reachability: SCNetworkReachability?

    override init(frame frameRect: NSRect) {
        // Initialize the UI components
        containerView = NSView()
        label = NSTextField(labelWithString: "Public IP:")
        flagLabel = NSTextField(labelWithString: "")
        resultLabel = NSTextField(labelWithString: "Loading...")
        homeCountryLabel = NSTextField(labelWithString: "Home Country:")
        homeCountryResultLabel = NSTextField(labelWithString: "Not set")

        super.init(frame: frameRect)
        
        // Set bold font for "Public IP:" and "Home Country:" labels
        let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        label.font = boldFont
        homeCountryLabel.font = boldFont
        
        // Disable autoresizing mask translation to use Auto Layout
        containerView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        homeCountryLabel.translatesAutoresizingMaskIntoConstraints = false
        homeCountryResultLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure labels
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        flagLabel.isEditable = false
        flagLabel.isBordered = false
        flagLabel.drawsBackground = false
        resultLabel.isEditable = false
        resultLabel.isBordered = false
        resultLabel.drawsBackground = false
        resultLabel.alignment = .left
        homeCountryLabel.isEditable = false
        homeCountryLabel.isBordered = false
        homeCountryLabel.drawsBackground = false
        homeCountryResultLabel.isEditable = false
        homeCountryResultLabel.isBordered = false
        homeCountryResultLabel.drawsBackground = false
        homeCountryResultLabel.alignment = .left

        // Add the components to the view
        containerView.addSubview(label)
        containerView.addSubview(flagLabel)
        containerView.addSubview(resultLabel)
        containerView.addSubview(homeCountryLabel)
        containerView.addSubview(homeCountryResultLabel)
        self.addSubview(containerView)

        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),  // Increased from 5 to 20
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),

            flagLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            flagLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),

            resultLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 2),
            resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),  // Changed from -5 to -20
            resultLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),

            homeCountryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),  // Increased from 5 to 20
            homeCountryLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),

            homeCountryResultLabel.leadingAnchor.constraint(equalTo: homeCountryLabel.trailingAnchor, constant: 5),
            homeCountryResultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),  // Changed from -5 to -20
            homeCountryResultLabel.centerYAnchor.constraint(equalTo: homeCountryLabel.centerYAnchor)
        ])

        // Set up network change observer
        setupNetworkObserver()

        // Display the public IP address and home country
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchPublicIP()
            self?.loadHomeCountry()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fetchPublicIP() {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            resultLabel.stringValue = "Error: Invalid URL"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.resultLabel.stringValue = "Error: \(error.localizedDescription)"
                    self?.flagLabel.stringValue = ""
                    return
                }

                guard let data = data else {
                    self?.resultLabel.stringValue = "Error: No data received"
                    self?.flagLabel.stringValue = ""
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let ip = json["ip"] as? String {
                        self?.resultLabel.stringValue = ip
                        self?.fetchCountryInfo(for: ip)
                    } else {
                        self?.resultLabel.stringValue = "Error: Unable to parse IP"
                        self?.flagLabel.stringValue = ""
                    }
                } catch {
                    self?.resultLabel.stringValue = "Error: \(error.localizedDescription)"
                    self?.flagLabel.stringValue = ""
                }
            }
        }

        task.resume()
    }

    func fetchCountryInfo(for ip: String) {
        guard let url = URL(string: "https://ipapi.co/\(ip)/json/") else {
            flagLabel.stringValue = ""
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.resultLabel.stringValue = ip
                self?.flagLabel.stringValue = ""

                guard let data = data, error == nil else {
                    print("Error fetching country info: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let countryCode = json["country_code"] as? String,
                       let country = json["country_name"] as? String {
                        self?.flagLabel.stringValue = self?.countryFlag(from: countryCode) ?? ""
                        self?.currentCountry = country
                        print("Current country set to: \(country)")
                        self?.compareCountries()
                    }
                } catch {
                    print("Error parsing country info: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }

    func compareCountries() {
        if let currentCountry = self.currentCountry,
           let homeCountry = UserDefaults.standard.string(forKey: "homeCountry"),
           homeCountry != "Not set" {
            let title = currentCountry == homeCountry ? ":)" : ":("
            updateStatusItemTitle(title: title)
        } else {
            updateStatusItemTitle(title: "DN Dash")
        }
    }

    func updateStatusItemTitle(title: String) {
        print("CustomView: Updating status item title to \(title)")
        if let appDelegate = AppDelegate.shared {
            appDelegate.updateStatusItemTitle(title: title)
        } else {
            print("CustomView: Failed to get AppDelegate")
        }
    }

    func countryFlag(from countryCode: String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }

    func updateHomeCountry(_ country: String) {
        homeCountryResultLabel.stringValue = country
        UserDefaults.standard.set(country, forKey: "homeCountry")
        compareCountries()  // This will call updateStatusItemTitle with the correct title
    }

    func loadHomeCountry() {
        updateHomeCountry(UserDefaults.standard.string(forKey: "homeCountry") ?? "Not set")
    }
    
    deinit {
        if let observer = networkObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        if let reachability = reachability {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        }
    }

    private func setupNetworkObserver() {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com") else {
            print("Failed to create network reachability object")
            return
        }

        self.reachability = reachability

        var context = SCNetworkReachabilityContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        
        if !SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
            guard let info = info else { return }
            let customView = Unmanaged<CustomView>.fromOpaque(info).takeUnretainedValue()
            DispatchQueue.main.async {
                customView.networkStatusChanged()
            }
        }, &context) {
            print("Failed to set network reachability callback")
            return
        }

        if !SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue) {
            print("Failed to schedule network reachability")
            return
        }

        print("Network observer set up successfully")
    }

    private func networkStatusChanged() {
        print("Network status changed")
        fetchPublicIP()
    }
}



