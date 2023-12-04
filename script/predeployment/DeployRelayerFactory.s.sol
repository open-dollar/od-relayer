// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {RelayerFactory} from '@contracts/factories/RelayerFactory.sol';

// BROADCAST
// source .env && forge script DeployRelayerFactory --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployRelayerFactory --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployRelayerFactory is Script {
  RelayerFactory public relayerFactory;

  /**
   * @dev RelayerFactory must be deployed by deployer of protocol
   */
  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    relayerFactory = new RelayerFactory();
    vm.stopBroadcast();
  }
}
