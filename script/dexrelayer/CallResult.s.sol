// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IRelayer} from '@interfaces/oracles/IRelayer.sol';

// BROADCAST
// source .env && forge script CallResult --skip-simulation --with-gas-price 2000000000 -vvvvv --rpc-url $GOERLI_RPC --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script CallResult --with-gas-price 2000000000 -vvvvv --rpc-url $GOERLI_RPC

contract CallResult is Script {
  uint256 private constant WAD = 1e18;
  uint256 private constant MINT_AMOUNT = 1_000_000 ether;
  uint256 private constant ORACLE_PERIOD = 1 seconds;

  IRelayer public relayer = IRelayer(0xd78607dfd7053014C44f10Ac4FD629EfDF086fe7);

  function run() public {
    vm.startBroadcast(vm.envUint('GOERLI_PK'));
    (
      uint160 price,
      int24 tick,
      int24 prevInitializedTick,
      uint16 fee,
      uint16 timepointIndex,
      uint8 communityFee,
      bool unlocked
    ) = getGlobalState(IAlgebraPool(relayer.camelotPool()));

    relayer.getResultWithValidity();
    vm.stopBroadcast();
  }

  /**
   * @dev helper functions
   */
  function getGlobalState(IAlgebraPool _pool)
    public
    view
    returns (
      uint160 price,
      int24 tick,
      int24 prevInitializedTick,
      uint16 fee,
      uint16 timepointIndex,
      uint8 communityFee,
      bool unlocked
    )
  {
    (price, tick, prevInitializedTick, fee, timepointIndex, communityFee, unlocked) = _pool.globalState();
  }
}
