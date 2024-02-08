// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {CommonMainnet} from '@script/Common.s.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';

// BROADCAST
// source .env && forge script DeployODGCamelotRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployODGCamelotRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC

contract DeployODGCamelotRelayerMainnet is CommonMainnet {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(MAINNET_ALGEBRA_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_MAINNET_DEPLOYER_PK'));
    camelotRelayerFactory.deployAlgebraRelayer(
      MAINNET_ALGEBRA_FACTORY, MAINNET_PROTOCOL_TOKEN, MAINNET_WETH, uint32(MAINNET_ORACLE_INTERVAL)
    );
    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployOdgUsdRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployOdgUsdRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC

contract DeployOdgUsdRelayerMainnet is CommonMainnet {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(MAINNET_ALGEBRA_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_MAINNET_DEPLOYER_PK'));
    IBaseOracle _odgUsdOracle = denominatedOracleFactory.deployDenominatedOracle(
      IBaseOracle(MAINNET_CAMELOT_ODG_WETH_RELAYER), IBaseOracle(MAINNET_CHAINLINK_ETH_USD_RELAYER), false
    );

    _odgUsdOracle.symbol(); // "(ODG / WETH) * (ETH / USD)"
    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployEthUsdChainlinkRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployEthUsdChainlinkRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC

contract DeployEthUsdChainlinkRelayerMainnet is CommonMainnet {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(MAINNET_ALGEBRA_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_MAINNET_DEPLOYER_PK'));
    chainlinkRelayerFactory.deployChainlinkRelayer(MAINNET_CHAINLINK_ETH_USD_FEED, MAINNET_ORACLE_INTERVAL);
    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployRethEthChainlinkRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployRethEthChainlinkRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC

contract DeployRethEthChainlinkRelayerMainnet is CommonMainnet {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(MAINNET_ALGEBRA_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_MAINNET_DEPLOYER_PK'));
    IBaseOracle _chainlinkRethEthPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(MAINNET_CHAINLINK_RETH_ETH_FEED, MAINNET_ORACLE_INTERVAL);

    IBaseOracle _rethUsdOracle = denominatedOracleFactory.deployDenominatedOracle(
      _chainlinkRethEthPriceFeed, IBaseOracle(MAINNET_CHAINLINK_ETH_USD_RELAYER), false
    );

    _rethUsdOracle.symbol(); // "(RETH / ETH) * (ETH / USD)"
    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployWstethEthChainlinkRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployWstethEthChainlinkRelayerMainnet --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC

contract DeployWstethEthChainlinkRelayerMainnet is CommonMainnet {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(MAINNET_ALGEBRA_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_MAINNET_DEPLOYER_PK'));
    IBaseOracle _chainlinkWstethEthPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(MAINNET_CHAINLINK_WSTETH_ETH_FEED, MAINNET_ORACLE_INTERVAL);

    IBaseOracle _wstethUsdOracle = denominatedOracleFactory.deployDenominatedOracle(
      _chainlinkWstethEthPriceFeed, IBaseOracle(MAINNET_CHAINLINK_ETH_USD_RELAYER), false
    );

    _wstethUsdOracle.symbol(); // "(WSTETH / ETH) * (ETH / USD)"
    vm.stopBroadcast();
  }
}
