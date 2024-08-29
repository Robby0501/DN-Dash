//
//  CustomView.swift
//  IP.Check
//
//  Created by Robby Ulrich on 8/29/24.
//
import Cocoa

class CustomView: NSView {
    private let label: NSTextField
    private let ipTextField: NSTextField
    private let checkButton: NSButton
    private let resultLabel: NSTextField

    override init(frame frameRect: NSRect) {
        // Initialize the UI components
        label = NSTextField(labelWithString: "Enter your IP:")
        ipTextField = NSTextField(string: "")
        checkButton = NSButton(title: "Check IP", target: nil, action: #selector(checkIP))
        resultLabel = NSTextField(labelWithString: "")

        super.init(frame: frameRect)
        
        // Disable autoresizing mask translation to use Auto Layout
        label.translatesAutoresizingMaskIntoConstraints = false
        ipTextField.translatesAutoresizingMaskIntoConstraints = false
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add the components to the view
        self.addSubview(label)
        self.addSubview(ipTextField)
        self.addSubview(checkButton)
        self.addSubview(resultLabel)
        
        checkButton.target = self
        checkButton.action = #selector(checkIP)

        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            ipTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            ipTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            ipTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            ipTextField.heightAnchor.constraint(equalToConstant: 24),

            checkButton.topAnchor.constraint(equalTo: ipTextField.bottomAnchor, constant: 10),
            checkButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            
            resultLabel.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 10),
            resultLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            resultLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            resultLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This method checks if the entered IP matches the local IP
    @objc func checkIP() {
        let localIP = getLocalIP() ?? "Unavailable"
        let enteredIP = ipTextField.stringValue
        
        if enteredIP == localIP {
            resultLabel.stringValue = "😊 IP matches!"
        } else {
            resultLabel.stringValue = "😞 IP does not match."
        }
    }

    // This method retrieves the local IP address of the device
    func getLocalIP() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" { // Typically the Wi-Fi adapter
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }

        return address
    }
}


