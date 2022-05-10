//
//  WalletAddressViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/8/22.
//

import Foundation
import RxSwift

class WalletAddressViewModel {
    let walletAddressPublishSubject = PublishSubject<String>()
    
    func isValidWallet() -> Observable<Bool> {
        return walletAddressPublishSubject.asObservable().map { wallet in
            return wallet.count == 44
        }
    }
}
