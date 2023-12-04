// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {RelayerChild} from '@contracts/factories/RelayerChild.sol';
import {EnumerableSet} from '@openzeppelin/contracts/utils/EnumerableSet.sol';

contract RelayerFactory {
  // using EnumerableSet for EnumerableSet.AddressSet;
  uint256 relayerCounter;

  // --- Events ---
  event NewAlgebraRelayer(address indexed _relayer, address _baseToken, address _quoteToken, uint32 _quotePeriod);

  // --- Data ---
  // EnumerableSet.AddressSet internal _Relayers;
  mapping(uint256 => address) _relayers;

  // --- Init ---
  constructor() {}

  // --- Methods ---

  // TODO: add access control
  function deployAlgebraRelayer(
    address _algebraV3Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) external returns (IBaseOracle _relayer) {
    relayerCounter++;
    _relayer = IBaseOracle(address(new RelayerChild(_algebraV3Factory, _baseToken, _quoteToken, _quotePeriod)));
    _relayers[relayerCounter] = address(_relayer);
    emit NewAlgebraRelayer(address(_relayer), _baseToken, _quoteToken, _quotePeriod);
  }

  // --- Views ---
  // TODO add getter function
}
