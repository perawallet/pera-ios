
# Building the Pera Wallet iOS App

After you clone or download this repo to your computer, you can run the project right away without any additional setup.

## Optional Configurations

1.  **Firebase account:** The project includes a `google-services.json` file connected to a demo Firebase project. If you want to link your own Firebase project, you can replace the `google-services.json` file with yours.

2. **Node and indexer:** The project already has [Nodely](https://nodely.io/docs/free/start) public API keys and URLs configured for the node and indexer. To set up a different indexer or node, you can follow these steps:

2.1 **Create a new node:**  The apps need access to instances of [Algod](https://github.com/algorand/go-algorand) and
[Indexer](https://github.com/algorand/indexer) to run. The official app supports MainNet
and TestNet; however, any network can be used if you supply your node. For a private network,
the quickest way to get started is by using the [Algorand sandbox](https://github.com/algorand/sandbox).
[This page from the Algorand developer docs](https://developer.algorand.org/docs/build-apps/setup/#how-do-i-obtain-an-algod-address-and-token)
contains more options. Regardless of how you obtain access to instances of Algod and Indexer, you
will need their addresses and API keys to continue.

2.2. **Define network access tokens:** In order to tell the app how to access Algod and Indexer, you
will need to update the keys in the `Config.xcconfig` files. You can find these files in the `Support` folder. You need to
define two values, `ALGOD_TOKEN` and `INDEXER_TOKEN`, which are the API tokens
for Algod and Indexer, respectively.

2.3. **Specify network addresses:** You will need to change the default addresses for Algod and Indexer
in the same file. The variables to change are `ALGOD_MAINNET_HOST`, `ALGOD_TESTNET_HOST`, `INDEXER_MAINNET_HOST`, and `INDEXER_TESTNET_HOST` for the MainNet and TestNet.

2.4. **Build the app:** Once all the above steps are complete, you are ready to build the iOS app.

