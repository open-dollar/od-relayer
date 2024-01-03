// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';
import {Data} from '@contracts/for-test/Data.sol';

// BROADCAST
// source .env && forge script DeployFactories --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployFactories --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployFactories is Script {
  CamelotRelayerFactory public camelotRelayerFactory;
  ChainlinkRelayerFactory public chainlinkRelayerFactory;
  DenominatedOracleFactory public denominatedOracleFactory;

  /**
   * @dev CamelotRelayerFactory must be deployed by deployer of protocol
   */
  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    camelotRelayerFactory = new CamelotRelayerFactory();
    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    denominatedOracleFactory = new DenominatedOracleFactory();
    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script MockDeployFactories --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script MockDeployFactories --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract MockDeployFactories is Script {
  Data public data = Data(RELAYER_DATA);

  ChainlinkRelayerFactory public chainlinkRelayerFactory;
  CamelotRelayerFactory public camelotRelayerFactory;
  DenominatedOracleFactory public denominatedOracleFactory;

  /**
   * @dev CamelotRelayerFactory must be deployed by deployer of protocol
   */
  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    camelotRelayerFactory = new CamelotRelayerFactory();
    denominatedOracleFactory = new DenominatedOracleFactory();

    IAuthorizable(address(chainlinkRelayerFactory)).addAuthorization(vm.envAddress('ARB_SEPOLIA_PC'));
    IAuthorizable(address(camelotRelayerFactory)).addAuthorization(vm.envAddress('ARB_SEPOLIA_PC'));
    IAuthorizable(address(denominatedOracleFactory)).addAuthorization(vm.envAddress('ARB_SEPOLIA_PC'));

    data.modifyFactory(bytes32('chainlinkRelayerFactory'), address(chainlinkRelayerFactory));
    data.modifyFactory(bytes32('camelotRelayerFactory'), address(camelotRelayerFactory));
    data.modifyFactory(bytes32('denominatedOracleFactory'), address(denominatedOracleFactory));
    vm.stopBroadcast();
  }
}
