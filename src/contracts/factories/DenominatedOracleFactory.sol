// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {EnumerableSet} from '@openzeppelin/contracts/utils/EnumerableSet.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {DenominatedOracleChild} from '@contracts/factories/DenominatedOracleChild.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';

contract DenominatedOracleFactory is Authorizable {
  using EnumerableSet for EnumerableSet.AddressSet;

  uint256 public oracleId;

  // --- Events ---
  event NewDenominatedOracle(
    address indexed _denominatedOracle, address _priceSource, address _denominationPriceSource, bool _inverted
  );

  // --- Data ---
  EnumerableSet.AddressSet internal _denominatedOracles;
  mapping(uint256 => address) public oracleById;

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Methods ---

  function deployDenominatedOracle(
    IBaseOracle _priceSource,
    IBaseOracle _denominationPriceSource,
    bool _inverted
  ) external isAuthorized returns (IBaseOracle _denominatedOracle) {
    _denominatedOracle =
      IBaseOracle(address(new DenominatedOracleChild(_priceSource, _denominationPriceSource, _inverted)));
    _denominatedOracles.add(address(_denominatedOracle));
    oracleId++;
    oracleById[oracleId] = address(_denominatedOracle);
    emit NewDenominatedOracle(
      address(_denominatedOracle), address(_priceSource), address(_denominationPriceSource), _inverted
    );
  }
}
