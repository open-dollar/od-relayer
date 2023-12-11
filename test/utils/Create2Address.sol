// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

/// @title Provides functions for deriving a contract address using Create2
library Create2Address {
  /// @notice Deterministically computes a contract address given the deployer/factory, salt and initCodeHash
  /// @param _deployer The address of the deployer or factory contract
  /// @param _salt The salt encoded bytes
  /// @param _initCodeHash The Init Code Hash of the target
  /// @return _computedAddress The address of the target contract
  function computeDeterministicAddress(
    address _deployer,
    bytes32 _salt,
    bytes32 _initCodeHash
  ) internal pure returns (address _computedAddress) {
    _computedAddress = address(uint160(uint256(keccak256(abi.encodePacked(hex'ff', _deployer, _salt, _initCodeHash)))));
  }
}
