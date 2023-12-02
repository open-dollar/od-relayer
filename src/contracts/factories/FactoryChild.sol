// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

abstract contract FactoryChild {
  // --- Registry ---
  address public factory;

  // --- Init ---

  /// @dev Verifies that the contract is being deployed by a contract address
  constructor() {
    factory = msg.sender;
  }

  // --- Modifiers ---

  ///@dev Verifies that the caller is the factory
  modifier onlyFactory() {
    require(msg.sender == factory, 'CallerNotFactory');
    _;
  }
}
