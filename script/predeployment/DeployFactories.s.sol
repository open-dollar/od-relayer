// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';

// BROADCAST
// source .env && forge script DeployFactories --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployFactories --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployFactories is Script {
  CamelotRelayerFactory public camelotRelayerFactory;
  ChainlinkRelayerFactory public chainlinkRelayerFactory;
  DenominatedOracleFactory public denominatedOraclFactory;

  /**
   * @dev CamelotRelayerFactory must be deployed by deployer of protocol
   */
  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    camelotRelayerFactory = new CamelotRelayerFactory();
    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    denominatedOraclFactory = new DenominatedOracleFactory();
    vm.stopBroadcast();
  }
}
