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

    /// This function returns a boolean if the wallet address string provided is of valid length for a Solana address
    ///
    /// - Returns: Boolean representing validity of wallet address length
    func isValidWallet() -> Observable<Bool> {
        return walletAddressPublishSubject.asObservable().map { wallet in
            wallet.count == 44
        }
    }
}
