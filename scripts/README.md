# Scripts

The main CLI is `generate-wallets.sh`. It purposes is for generating leequid wallets and keys.
It uses others scripts:

- `lukso-key-gen-cli` which generates keystore and mnemonic (from [percenuage/tools-lukso-cli](https://github.com/percenuage/tools-lukso-cli))
- `prysm-validator` which generates wallets from keystore (from [prysmaticlabs/prysm](https://github.com/prysmaticlabs/prysm))
- `leequid-cli` which encrypts all mnemonics for sharing with shareholders (from [dropps-io/leequid-cli](https://github.com/dropps-io/leequid-cli))
