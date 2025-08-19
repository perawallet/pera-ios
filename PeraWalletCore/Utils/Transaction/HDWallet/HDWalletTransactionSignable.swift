import Foundation

protocol HDWalletTransactionSignable {
    /// Signs an Algorand transaction using the HD wallet
    /// - Parameters:
    ///   - transaction: The transaction data to sign
    ///   - addressDetail: The address detail containing BIP44 path components
    /// - Returns: The signed transaction data
    /// - Throws: HDWalletError if signing fails
    func signTransaction(
        _ transaction: Data,
        with addressDetail: HDWalletAddressDetail
    ) throws -> Data
    
    /// Signs multiple Algorand transactions using the HD wallet
    /// - Parameters:
    ///   - transactions: Array of transaction data to sign
    ///   - addressDetail: The address detail containing BIP44 path components
    /// - Returns: Array of signed transaction data in the same order
    /// - Throws: HDWalletError if signing fails
    func signTransactions(
        _ transactions: [Data],
        with addressDetail: HDWalletAddressDetail
    ) throws -> [Data]
    
    /// Verifies if a signature is valid for a given message and public key
    /// - Parameters:
    ///   - signature: The signature to verify
    ///   - message: The original message that was signed
    ///   - publicKey: The public key to verify against
    /// - Returns: Boolean indicating if the signature is valid
    func verifySignature(
        _ signature: Data,
        message: Data,
        publicKey: Data
    ) -> Bool
    
    /// Signs data
    /// - Parameters:
    ///   - data: Data that needs to be signed
    ///   - addressDetail: The address detail containing BIP44 path components
    /// - Returns: Signed data
    /// - Throws: HDWalletError if signing fails
    func signData(
        _ data: Data,
        with addressDetail: HDWalletAddressDetail
    ) throws -> Data
}
