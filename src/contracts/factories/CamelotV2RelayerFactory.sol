// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {CamelotV2RelayerChild} from '@contracts/factories/CamelotV2RelayerChild.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';

contract CamelotV2RelayerFactory is Authorizable {
  uint256 public relayerId;

  // --- Events ---
  event NewCamelotV2Relayer(address indexed _relayer, address _baseToken, address _quoteToken, uint32 _quotePeriod);

  // --- Data ---
  mapping(uint256 => address) public relayerById;

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Methods ---

  function deployCamelotV2Relayer(
    address _camelotV2Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) external isAuthorized returns (IBaseOracle _relayer) {
    _relayer = IBaseOracle(address(new CamelotV2RelayerChild(_camelotV2Factory, _baseToken, _quoteToken, _quotePeriod)));
    relayerId++;
    relayerById[relayerId] = address(_relayer);
    emit NewCamelotV2Relayer(address(_relayer), _baseToken, _quoteToken, _quotePeriod);
  }
}
