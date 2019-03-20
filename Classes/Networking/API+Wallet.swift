//
//  API+Wallet.swift
//  algorand
//
//  Created by Omer Emre Aslan on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    @discardableResult
    func createWallet(
        with draft: WalletCreationDraft,
        then completion: CompletionHandler<Wallet>? = nil
        ) -> EndpointInteractable? {
        
        var params: Params = []
        
        params.appendIfPresent(draft.name, for: AlgorandParamPairKey.walletName)
        params.appendIfPresent(draft.password, for: AlgorandParamPairKey.walletPassword)
        params.append(.custom(key: AlgorandParamPairKey.walletDriverName, value: "sqlite"))
        params.append(.custom(key: AlgorandParamPairKey.masterDerivationKey, value: ""))
        
        return send(
            Endpoint<Wallet>(Path("/v1/wallet"))
                .base("http://localhost:7833")
                .httpMethod(.post)
                .handler { response in
                    completion?(response)
                }
        )
    }
}
