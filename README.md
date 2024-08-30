# IP.Check

IP.Check is a macOS menu bar application that displays your current public IP address and compares it with your set home country. It's perfect for digital nomads and travelers who want to keep track of their location and VPN status.

## Features

- Displays your current public IP address in the menu bar
- Shows the country flag associated with your IP
- Allows you to set a home country
- Compares your current location with your home country
- Updates automatically when network changes are detected
- Minimal and unobtrusive design

## Requirements

- macOS 14.5 or later
- Xcode 15.0 or later (for development)

## Installation

1. Clone this repository or download the source code.
2. Open the project in Xcode.
3. Build and run the application.

## Usage

1. After launching, IP.Check will appear in your menu bar.
2. Click on the menu bar icon to see your current IP and country.
3. Use the "Set Home Country" option to define your home location.
4. The menu bar icon will show ":)" when you're in your home country, and ":(" when you're not.

## Development

The app is built using SwiftUI and AppKit. Key files include:

- `IP_CheckApp.swift`: The main app structure
- `AppDelegate.swift`: Handles the menu bar functionality
- `CustomView.swift`: Contains the main logic for IP checking and UI

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgements

- Uses [ipify](https://www.ipify.org/) for IP address lookup
- Uses [ipapi](https://ipapi.co/) for country information

## Contact

For any questions or concerns, please open an issue on this repository.
