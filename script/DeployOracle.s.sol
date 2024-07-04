// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {CommonMainnet} from '@script/Common.s.sol';

// BROADCAST
// source .env && forge script DeployEthUsdRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployEthUsdRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC

contract DeployEthUsdRelayerMainnet is Script, CommonMainnet {
  function run() public {
    vm.startBroadcast(vm.envUint('ARB_MAINNET_DEPLOYER_PK'));

    chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_ETH_USD_FEED, MAINNET_CHAINLINK_SEQUENCER_FEED, MAINNET_ORACLE_INTERVAL, MAINNET_GRACE_PERIOD
    );

    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployLinkGrtEthOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployLinkGrtEthOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC

contract DeployLinkGrtEthOracles is Script, CommonMainnet {
  IBaseOracle public _linkUSDRelayer;
  IBaseOracle public _grtUSDRelayer;
  IBaseOracle public _ethDelayedOracle;

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_MAINNET_DEPLOYER_PK'));

    _linkUSDRelayer = chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_LINK_USD_FEED, MAINNET_CHAINLINK_SEQUENCER_FEED, MAINNET_ORACLE_INTERVAL, MAINNET_GRACE_PERIOD
    );
    _grtUSDRelayer = chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_LINK_USD_FEED, MAINNET_CHAINLINK_SEQUENCER_FEED, MAINNET_ORACLE_INTERVAL, MAINNET_GRACE_PERIOD
    );

    delayedOracleFactory.deployDelayedOracle(_linkUSDRelayer, MAINNET_ORACLE_INTERVAL);
    delayedOracleFactory.deployDelayedOracle(_grtUSDRelayer, MAINNET_ORACLE_INTERVAL);
    delayedOracleFactory.deployDelayedOracle(
      IBaseOracle(MAINNET_CHAINLINK_L2VALIDITY_ETH_USD_RELAYER), MAINNET_ORACLE_INTERVAL
    );

    vm.stopBroadcast();
  }
}
