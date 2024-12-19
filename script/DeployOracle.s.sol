// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {CommonMainnet} from '@script/Common.s.sol';
import 'forge-std/console2.sol';

import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';

// BROADCAST
// source .env && forge script DeployEthUsdRelayer --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY --account defaultKey --sender $DEFAULT_KEY_PUBLIC_ADDRESS

// SIMULATE
// source .env && forge script DeployEthUsdRelayer --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --sender $DEFAULT_KEY_PUBLIC_ADDRESS

contract DeployEthUsdRelayer is Script, CommonMainnet {
  function run() public {
    vm.startBroadcast();

    chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_ETH_USD_FEED,
      MAINNET_CHAINLINK_SEQUENCER_FEED,
      1 days,
      MAINNET_CHAINLINK_L2VALIDITY_GRACE_PERIOD
    );

    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployLinkGrtEthOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY --account defaultKey --sender $DEFAULT_KEY_PUBLIC_ADDRESS

// SIMULATE
// source .env && forge script DeployLinkGrtEthOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --sender $DEFAULT_KEY_PUBLIC_ADDRESS

contract DeployLinkGrtEthOracles is Script, CommonMainnet {
  IBaseOracle public _linkUSDRelayer;
  IBaseOracle public _grtUSDRelayer;
  IBaseOracle public _ethDelayedOracle;

  function run() public {
    vm.startBroadcast();

    _linkUSDRelayer = chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_LINK_USD_FEED,
      MAINNET_CHAINLINK_SEQUENCER_FEED,
      1 hours,
      MAINNET_CHAINLINK_L2VALIDITY_GRACE_PERIOD
    );
    _grtUSDRelayer = chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_GRT_USD_FEED,
      MAINNET_CHAINLINK_SEQUENCER_FEED,
      1 days,
      MAINNET_CHAINLINK_L2VALIDITY_GRACE_PERIOD
    );

    IBaseOracle linkOracle = delayedOracleFactory.deployDelayedOracle(_linkUSDRelayer, MAINNET_ORACLE_DELAY);
    IBaseOracle grtOracle = delayedOracleFactory.deployDelayedOracle(_grtUSDRelayer, MAINNET_ORACLE_DELAY);
    IBaseOracle ethOracle = delayedOracleFactory.deployDelayedOracle(
      IBaseOracle(MAINNET_CHAINLINK_L2VALIDITY_ETH_USD_RELAYER), MAINNET_ORACLE_DELAY
    );

    linkOracle.getResultWithValidity();
    grtOracle.getResultWithValidity();
    ethOracle.getResultWithValidity();

    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployWstethRethL2ValidityOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY --account defaultKey --sender $DEFAULT_KEY_PUBLIC_ADDRESS

// SIMULATE
// source .env && forge script DeployWstethRethL2ValidityOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --sender $DEFAULT_KEY_PUBLIC_ADDRESS

contract DeployWstethRethL2ValidityOracles is Script, CommonMainnet {
  IBaseOracle public _wstethETHRelayer;
  IBaseOracle public _rethETHRelayer;

  function run() public {
    vm.startBroadcast();

    _wstethETHRelayer = chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_WSTETH_ETH_FEED,
      MAINNET_CHAINLINK_SEQUENCER_FEED,
      1 days,
      MAINNET_CHAINLINK_L2VALIDITY_GRACE_PERIOD
    );
    _rethETHRelayer = chainlinkRelayerFactory.deployChainlinkRelayerWithL2Validity(
      MAINNET_CHAINLINK_RETH_ETH_FEED,
      MAINNET_CHAINLINK_SEQUENCER_FEED,
      1 days,
      MAINNET_CHAINLINK_L2VALIDITY_GRACE_PERIOD
    );

    IBaseOracle _wstethUsdOracle = denominatedOracleFactory.deployDenominatedOracle(
      _wstethETHRelayer, IBaseOracle(MAINNET_CHAINLINK_L2VALIDITY_ETH_USD_RELAYER), false
    );

    IBaseOracle _rethUsdOracle = denominatedOracleFactory.deployDenominatedOracle(
      _rethETHRelayer, IBaseOracle(MAINNET_CHAINLINK_L2VALIDITY_ETH_USD_RELAYER), false
    );

    IBaseOracle wstethOracle = delayedOracleFactory.deployDelayedOracle(_wstethUsdOracle, MAINNET_ORACLE_DELAY);
    IBaseOracle rethOracle = delayedOracleFactory.deployDelayedOracle(_rethUsdOracle, MAINNET_ORACLE_DELAY);

    wstethOracle.getResultWithValidity();
    rethOracle.getResultWithValidity();

    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployCamelotOdUsdOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY --sender $DEFAULT_KEY_PUBLIC_ADDRESS --account defaultKey

// SIMULATE
// source .env && forge script DeployCamelotOdUsdOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --sender $DEFAULT_KEY_PUBLIC_ADDRESS

contract DeployCamelotOdUsdOracle is Script, CommonMainnet {
  IBaseOracle public _odEthCamelotRelayer;
  IBaseOracle public _odUsdOracle;

  function run() public {
    vm.startBroadcast();

    _odEthCamelotRelayer = camelotRelayerFactory.deployAlgebraRelayer(
      MAINNET_ALGEBRA_V3_FACTORY, MAINNET_SYSTEM_COIN, MAINNET_WETH, uint32(MAINNET_CAMELOT_QUOTE_PERIOD)
    );

    _odUsdOracle = denominatedOracleFactory.deployDenominatedOracle(
      _odEthCamelotRelayer, IBaseOracle(MAINNET_CHAINLINK_L2VALIDITY_ETH_USD_RELAYER), false
    );

    _odUsdOracle.getResultWithValidity();

    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployCamelotOdgUsdOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY --sender $DEFAULT_KEY_PUBLIC_ADDRESS --account defaultKey

// SIMULATE
// source .env && forge script DeployCamelotOdgUsdOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --sender $DEFAULT_KEY_PUBLIC_ADDRESS

contract DeployCamelotOdgUsdOracle is Script, CommonMainnet {
  IBaseOracle public _odgEthCamelotRelayer;
  IBaseOracle public _odgUsdOracle;

  function run() public {
    vm.startBroadcast();

    _odgEthCamelotRelayer = camelotRelayerFactory.deployAlgebraRelayer(
      MAINNET_ALGEBRA_V3_FACTORY, MAINNET_PROTOCOL_TOKEN, MAINNET_WETH, uint32(MAINNET_CAMELOT_QUOTE_PERIOD)
    );

    _odgUsdOracle = denominatedOracleFactory.deployDenominatedOracle(
      _odgEthCamelotRelayer, IBaseOracle(MAINNET_CHAINLINK_L2VALIDITY_ETH_USD_RELAYER), false
    );

    _odgUsdOracle.getResultWithValidity();

    vm.stopBroadcast();
  }
}

// BROADCAST
// source .env && forge script DeployCamelotPendleUsdOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY --sender $DEFAULT_KEY_PUBLIC_ADDRESS --account defaultKey

// SIMULATE
// source .env && forge script DeployCamelotPendleUsdOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_MAINNET_RPC --sender $DEFAULT_KEY_PUBLIC_ADDRESS

contract DeployCamelotPendleUsdOracle is Script, CommonMainnet {
  IBaseOracle public _PendleEthOracleRelayer;
  IBaseOracle public _PendleUsdOracleRelayer;

  address public MAINNET_PENDLE = 0x0c880f6761F1af8d9Aa9C466984b80DAb9a8c9e8;
  CamelotRelayerFactory public _camelotRelayerFactory =
    CamelotRelayerFactory(0xC4E3cE2941476faCC2447497731A6050eEfa25C8);
  DenominatedOracleFactory public _denominatedOracleFactory =
    DenominatedOracleFactory(0x7028f637d5340da4bC8D3Ef9DfeC5D4D79dE8116);

  function run() public {
    vm.startBroadcast();

    _PendleEthOracleRelayer = _camelotRelayerFactory.deployAlgebraRelayer(
      MAINNET_ALGEBRA_V3_FACTORY, MAINNET_PENDLE, MAINNET_WETH, uint32(MAINNET_CAMELOT_QUOTE_PERIOD)
    );

    _PendleUsdOracleRelayer = _denominatedOracleFactory.deployDenominatedOracle(
      _PendleEthOracleRelayer, IBaseOracle(MAINNET_CHAINLINK_L2VALIDITY_ETH_USD_RELAYER), false
    );

    _PendleUsdOracleRelayer.symbol();
    _PendleUsdOracleRelayer.getResultWithValidity();

    vm.stopBroadcast();
  }
}
