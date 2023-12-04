// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IRelayer} from '@interfaces/oracles/IRelayer.sol';

contract Data {
  // Tokens
  address public tokenA;
  address public tokenB;

  // Pool
  IAlgebraPool public pool;

  //
  IRelayer public relayer;

  function getPoolBal() public view returns (uint256, uint256) {
    (address t0, address t1) = getPoolPair();
    address poolAddress = address(pool);
    return (IERC20(t0).balanceOf(poolAddress), IERC20(t1).balanceOf(poolAddress));
  }

  function getPoolPair() public view returns (address, address) {
    return (pool.token0(), pool.token1());
  }

  function generateTickParams() public view returns (int24 bottomTick, int24 topTick) {
    (, int24 tick,,,,,) = pool.globalState();
    int24 tickSpacing = pool.tickSpacing();
    bottomTick = ((tick / tickSpacing) * tickSpacing) - 3 * tickSpacing;
    topTick = ((tick / tickSpacing) * tickSpacing) + 3 * tickSpacing;
  }

  function setTokens(address _t0, address _t1) public {
    tokenA = _t0;
    tokenB = _t1;
  }

  function setPool(IAlgebraPool _pool) public {
    pool = _pool;
  }

  function setRelayer(address _relayer) public {
    relayer = IRelayer(_relayer);
  }
}
