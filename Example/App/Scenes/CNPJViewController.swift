//
//  CNPJViewController.swift
//  SampleApp
//
//  Created by Diggo Silva on 19/11/24.
//

import UIKit
import CPFCNPJTools

class CNPJViewController: UIViewController {
    
    let cnpjView = CNPJView()
    
    override func loadView() {
        super.loadView()
        view = cnpjView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        setDelegatesAndDataSources()
    }
    
    private func setNavBar() {
        title = "Validador CNPJ"
    }
    
    private func setDelegatesAndDataSources() {
        cnpjView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension CNPJViewController: CNPJViewDelegate {
    func validateCNPJ() {
        let cnpj = cnpjView.cnpjResult.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        cnpjView.resultLabel.textColor = .label
        
        let cnpjResult = CNPJValidator().validate(cnpj: cnpj)
        switch cnpjResult {
        case .valid:return cnpjView.resultLabel.text = "CNPJ válido."
        case .cnpjNull: return cnpjView.resultLabel.text = "CNPJ não pode ser nulo ou vazio."
        case .invalidFormat: return cnpjView.resultLabel.text = "CNPJ inválido.\nDeve ter 14 dígitos (apenas números)."
        case .equalDigits: return cnpjView.resultLabel.text = "CNPJ inválido.\nTodos os dígitos são iguais."
        case .invalid: return cnpjView.resultLabel.text = "Número de CNPJ inválido."
        }
    }
    
    func generateCNPJ() {
        cnpjView.textField.text = ""
        cnpjView.resultLabel.textColor = .systemBrown
        let cnpj = CNPJValidator().generateFakeCNPJMasked()
        cnpjView.resultLabel.text = "Gerado CNPJ Fictício: \(cnpj ?? "")"
    }
}
