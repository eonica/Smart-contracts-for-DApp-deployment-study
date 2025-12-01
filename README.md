# Smart-contracts-for-DApp-deployment-study

This repository includes the smart contracts code for the two use cases in the DApp deployment study submitted to the 5th International Workshop on Distributed Infrastructure for Common Good - DICG 2025.
These are as follows:

- the e-voting DApp use case: \
  [Vote.sol](Vote.sol) (lightweight contract for hashed vote information commitment to the ledger, complementary to external storage of extended vote data)

- the supply-chain DApp use case: \
  [SupplyChain.sol](SupplyChain.sol) (main contract including lightweight functions for commitment of operational flow tracking information to the ledger) \
  [Utils.sol](Utils.sol) (contract module including definitions of roles, status of batches, storage structures, modifiers for role checks and other common data used in the main contract)

### Acknowledgement
This work was supported by a grant from the Romanian Ministry of Research, Innovation and Digitization, CNCS/CCCDI - UEFISCDI, project number 86/2025 ERANET-CHISTERA-IV-SCEAL, within PNCDI IV.
