//
//  CustomView.swift
//  IP.Check
//
//  Created by Robby Ulrich on 8/29/24.
//
import Cocoa
import Foundation

class CustomView: NSView {
    private let containerView: NSView
    private let label: NSTextField
    private let flagLabel: NSTextField
    private let resultLabel: NSTextField

    override init(frame frameRect: NSRect) {
        // Initialize the UI components
        containerView = NSView()
        label = NSTextField(labelWithString: "Public IP:")
        flagLabel = NSTextField(labelWithString: "")
        resultLabel = NSTextField(labelWithString: "Loading...")

        super.init(frame: frameRect)
        
        // Disable autoresizing mask translation to use Auto Layout
        containerView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false

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

        // Add the components to the view
        containerView.addSubview(label)
        containerView.addSubview(flagLabel)
        containerView.addSubview(resultLabel)
        self.addSubview(containerView)

        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 20),

            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            flagLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            flagLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            resultLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 2),
            resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            resultLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        // Display the public IP address
        fetchPublicIP()
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
                if let error = error {
                    self?.resultLabel.stringValue = ip
                    self?.flagLabel.stringValue = ""
                    print("Error fetching country info: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    self?.resultLabel.stringValue = ip
                    self?.flagLabel.stringValue = ""
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let countryCode = json["country_code"] as? String {
                        self?.resultLabel.stringValue = ip
                        self?.flagLabel.stringValue = self?.countryFlag(from: countryCode) ?? ""
                    } else {
                        self?.resultLabel.stringValue = ip
                        self?.flagLabel.stringValue = ""
                    }
                } catch {
                    self?.resultLabel.stringValue = ip
                    self?.flagLabel.stringValue = ""
                    print("Error parsing country info: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }

    func countryFlag(from countryCode: String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}



