//
//  BluetoothSettingsView.swift
//  Robo Zen
//
//  Created by Wes Cook on 10/14/24.
//


import UIKit
import CoreBluetooth

var isBluetoothConnected: Bool = false

class BluetoothSettingsViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)

        let titleLabel = UILabel()
        titleLabel.text = "Bluetooth Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])

        setupButtons()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let buttonTitles = [
            "Scan for Devices",
            "Disconnect Device"
        ]
        
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 28)
            button.backgroundColor = UIColor.systemTeal
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor.black.cgColor
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func buttonTapped(_ sender: UIButton) {
        switch sender.currentTitle {
        case "Scan for Devices":
            scanForDevices()
        case "Disconnect Device":
            disconnectDevice()
        default:
            break
        }
    }

    @objc func scanForDevices() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            showAlert(title: "Scanning", message: "Scanning for Bluetooth devices...")
        } else {
            showAlert(title: "Bluetooth Error", message: "Bluetooth is not available.")
        }
    }

    @objc func disconnectDevice() {
        if let peripheral = discoveredPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            showAlert(title: "Error", message: "No device connected to disconnect.")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on.")
        } else {
            showAlert(title: "Bluetooth Error", message: "Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown")")
        discoveredPeripheral = peripheral
        
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        
        showAlert(title: "Device Found", message: "Connecting to \(peripheral.name ?? "Unknown")...")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        isBluetoothConnected = true
        showAlert(title: "Connected", message: "You are now connected to the device.")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown")")
        isBluetoothConnected = false
        showAlert(title: "Disconnected", message: "You have disconnected from the device.")
    }
}
