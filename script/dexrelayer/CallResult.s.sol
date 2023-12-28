// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {ICamelotRelayer} from '@interfaces/oracles/ICamelotRelayer.sol';
import {Data} from '@contracts/for-test/Data.sol';

// BROADCAST
// source .env && forge script CallResult --skip-simulation --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script CallResult --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract CallResult is Script {
  Data public data = Data(RELAYER_DATA);

  ICamelotRelayer public relayer = data.camelotRelayer();

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_PK'));
    (
      uint160 price,
      int24 tick,
      int24 prevInitializedTick,
      uint16 fee,
      uint16 timepointIndex,
      uint8 communityFee,
      bool unlocked
    ) = getGlobalState(IAlgebraPool(relayer.algebraPool()));

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
