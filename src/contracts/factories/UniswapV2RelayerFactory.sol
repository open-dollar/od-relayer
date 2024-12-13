// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {UniswapV2RelayerChild} from '@contracts/factories/UniswapV2RelayerChild.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';

contract UniswapV2RelayerFactory is Authorizable {
  uint256 public relayerId;

  // --- Events ---
  event NewUniswapV2Relayer(address indexed _relayer, address _baseToken, address _quoteToken, uint32 _quotePeriod);

  // --- Data ---
  mapping(uint256 => address) public relayerById;

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Methods ---

  function deployUniswapV2Relayer(
    address _algebraV2Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) external isAuthorized returns (IBaseOracle _relayer) {
    _relayer = IBaseOracle(address(new UniswapV2RelayerChild(_algebraV2Factory, _baseToken, _quoteToken, _quotePeriod)));
    relayerId++;
    relayerById[relayerId] = address(_relayer);
    emit NewUniswapV2Relayer(address(_relayer), _baseToken, _quoteToken, _quotePeriod);
  }
}
