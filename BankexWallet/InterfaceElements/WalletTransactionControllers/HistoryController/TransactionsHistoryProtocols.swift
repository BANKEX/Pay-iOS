

protocol TransactionsHistoryViewOutput {
    func viewIsReady()
}

protocol TransactionsHistoryViewInput: class {
    func showEmptyView()
    func showNoKeysAvailableView()
    func show(transactions: [Any])
}
