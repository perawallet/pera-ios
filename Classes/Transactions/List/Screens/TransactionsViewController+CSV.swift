// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   TransactionsViewController+CSV.swift

import UIKit
import MacaroonUIKit

extension TransactionsViewController: CSVExportable {
    func fetchAllTransactionsForCSV() {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        fetchAllTransactions(
            between: getTransactionFilterDates(),
            nextToken: nil
        )
    }

    private func fetchAllTransactions(
        between dates: (Date?, Date?),
        nextToken token: String?
    ) {
        var assetId: String?
        if let id = draft.assetDetail?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: draft.accountHandle.value, dates: dates, nextToken: token, assetId: assetId, limit: nil)
        var csvTransactions = [Transaction]()

        api?.fetchTransactions(draft) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case .failure:
                self.loadingController?.stopLoading()
            case let .success(transactions):
                csvTransactions.append(contentsOf: transactions.transactions)

                if transactions.nextToken == nil {
                    self.shareCSVFile(for: csvTransactions)
                    return
                }

                self.fetchAllTransactions(between: dates, nextToken: transactions.nextToken)
            }
        }
    }

    private func shareCSVFile(for transactions: [Transaction]) {
        let keys: [String] = [
            "transaction-detail-amount".localized,
            "transaction-detail-reward".localized,
            "transaction-detail-close-amount".localized,
            "transaction-download-close-to".localized,
            "transaction-download-to".localized,
            "transaction-download-from".localized,
            "transaction-detail-fee".localized,
            "transaction-detail-round".localized,
            "transaction-detail-date".localized,
            "title-id".localized,
            "transaction-detail-note".localized
        ]
        let config = CSVConfig(fileName: formCSVFileName(), keys: NSOrderedSet(array: keys))

        if let fileUrl = exportCSV(from: createCSVData(from: transactions), with: config) {
            loadingController?.stopLoading()

            let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: fileUrl)
            }
            present(activityViewController, animated: true)
        } else {
            loadingController?.stopLoading()
        }
    }

    private func formCSVFileName() -> String {
        var assetId = "algos"
        if let assetDetailId = assetDetail?.id {
            assetId = "\(assetDetailId)"
        }
        var fileName = "\(accountHandle.value.name ?? "")_\(assetId)"
        let dates = getTransactionFilterDates()
        if let fromDate = dates.from,
           let toDate = dates.to {
            if filterOption == .today {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy")
            } else {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy") + "_" + toDate.toFormat("MM-dd-yyyy")
            }
        }
        return "\(fileName).csv"
    }

    private func createCSVData(from transactions: [Transaction]) -> [[String: Any]] {
        var csvData = [[String: Any]]()
        for transaction in transactions {
            let transactionData: [String: Any] = [
                "transaction-detail-amount".localized: getFormattedAmount(transaction.getAmount()),
                "transaction-detail-reward".localized: transaction.getRewards(for: accountHandle.value.address)?.toAlgos ?? " ",
                "transaction-detail-close-amount".localized: getFormattedAmount(transaction.getCloseAmount()),
                "transaction-download-close-to".localized: transaction.getCloseAddress() ?? " ",
                "transaction-download-to".localized: transaction.getReceiver() ?? " ",
                "transaction-download-from".localized: transaction.sender ?? " ",
                "transaction-detail-fee".localized: transaction.fee?.toAlgos.toAlgosStringForLabel ?? " ",
                "transaction-detail-round".localized: transaction.lastRound ?? " ",
                "transaction-detail-date".localized: transaction.date?.toFormat("MMMM dd, yyyy - HH:mm") ?? " ",
                "title-id".localized: transaction.id ?? " ",
                "transaction-detail-note".localized: transaction.noteRepresentation() ?? " "
            ]
            csvData.append(transactionData)
        }
        return csvData
    }

    private func getFormattedAmount(_ amount: UInt64?) -> String {
        if let assetDetail = assetDetail {
            return amount?.toFractionStringForLabel(fraction: assetDetail.decimals) ?? " "
        } else {
            return amount?.toAlgos.toAlgosStringForLabel ?? " "
        }
    }
}
