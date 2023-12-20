// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {RelayerFactory} from '@contracts/factories/RelayerFactory.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';

// BROADCAST
// source .env && forge script DeployRelayerFactory --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployRelayerFactory --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployRelayerFactory is Script {
  RelayerFactory public camelotRelayerFactory;
  ChainlinkRelayerFactory public chainlinkRelayerFactory;
  DenominatedOracleFactory public denominatedOracleFactory;

  /**
   * @dev RelayerFactory must be deployed by deployer of protocol
   */
  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    camelotRelayerFactory = new RelayerFactory();
    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    denominatedOracleFactory = new DenominatedOracleFactory();
    vm.stopBroadcast();
  }
}
