//
//  DrawingView.swift
//  Robo Zen
//
//  Created by Wes Cook on 10/14/24.
//


import UIKit


struct Drawing: Encodable {
    let id: Int
    let name: String
    let points: [[CGPoint]]
}

var idCount = 0
var globalDrawings: [Drawing] = []
var isDrawingAllowed = true

class DrawingView: UIView {
    public var lines: [[CGPoint]] = []
    public var currentLine: [CGPoint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawingAllowed {
            if let touch = touches.first {
                let point = touch.location(in: self)
                if isPointInsideCircle(point) {
                    currentLine.append(point)
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawingAllowed {
            if let touch = touches.first {
                let point = touch.location(in: self)
                if isPointInsideCircle(point) {
                    currentLine.append(point)
                    setNeedsDisplay()
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !currentLine.isEmpty {
            lines.append(currentLine)
            currentLine = []
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect)
        
        circlePath.addClip()
        
        UIColor.black.setStroke()
        let linePath = UIBezierPath()
        linePath.lineWidth = 8.0

        for line in lines {
            if let firstPoint = line.first {
                linePath.move(to: firstPoint)
                for point in line.dropFirst() {
                    linePath.addLine(to: point)
                }
            }
        }

        if !currentLine.isEmpty {
            linePath.move(to: currentLine.first!)
            for point in currentLine.dropFirst() {
                linePath.addLine(to: point)
            }
        }

        linePath.stroke()
        
        UIColor.black.setStroke()
        circlePath.lineWidth = 2.0
        circlePath.stroke()
    }

    private func isPointInsideCircle(_ point: CGPoint) -> Bool {
        let radius = bounds.width / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let distance = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
        return distance <= radius
    }

    func clearDrawing() {
        lines.removeAll()
        currentLine.removeAll()
        setNeedsDisplay()
    }


    func getDrawingData() -> [[CGPoint]] {
        return lines
    }
}

class RoboZenDrawingViewController: UIViewController {
    
    private let drawingView = DrawingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)

        let titleLabel = UILabel()
        titleLabel.text = "Drawing Creator"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        setupDrawingArea()
    }

    func setupDrawingArea() {
        drawingView.layer.borderColor = UIColor.black.cgColor
        drawingView.layer.borderWidth = 0
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawingView)

        NSLayoutConstraint.activate([
            drawingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            drawingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            drawingView.widthAnchor.constraint(equalToConstant: 300),
            drawingView.heightAnchor.constraint(equalToConstant: 300)
        ])

        let submitButton = createStyledButton(withTitle: "Submit")
        submitButton.addTarget(self, action: #selector(submitDrawing), for: .touchUpInside)

        let clearButton = createStyledButton(withTitle: "Clear")
        clearButton.addTarget(self, action: #selector(clearDrawing), for: .touchUpInside)

        view.addSubview(submitButton)
        view.addSubview(clearButton)

        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: drawingView.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            clearButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 10),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createStyledButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 28)
        button.backgroundColor = UIColor.systemTeal
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.black.cgColor


        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc func submitDrawing() {
        let alert = UIAlertController(title: "Name Your Drawing", message: "Please enter a name descriptor for your drawing.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Drawing Name"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let nameDescriptor = alert?.textFields?.first?.text,
                  !nameDescriptor.isEmpty else {

                print("Name descriptor cannot be empty.")
                return
            }

            let drawingData = self.drawingView.getDrawingData()
            let newDrawing = Drawing(id: idCount+1, name: nameDescriptor, points: drawingData)
            globalDrawings.append(newDrawing)

            let successAlert = UIAlertController(title: "Success", message: "Drawing successfully saved! You can find it in the View Designs section on the home screen.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(successAlert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func clearDrawing() {
        drawingView.clearDrawing()
    }
}
