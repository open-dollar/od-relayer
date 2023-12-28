// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
import {ICamelotRelayer} from '@interfaces/oracles/ICamelotRelayer.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';
import {Data} from '@contracts/for-test/Data.sol';

// TODO test denominated oracle after relayer works
// import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
// import {ChainlinkRelayerFactory, IChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';

// BROADCAST
// source .env && forge script DeployOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployOracles --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployOracles is Script {
  Data public data = Data(RELAYER_DATA);

  IBaseOracle public chainlinkEthUSDPriceFeed;
  IBaseOracle public camelotRelayer;
  IBaseOracle public denominatedOracle;

  ChainlinkRelayerFactory public chainlinkRelayerFactory;
  CamelotRelayerFactory public camelotRelayerFactory;
  DenominatedOracleFactory public denominatedOracleFactory;

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_PK'));

    // deploy oracle factories
    deployFactories();

    // deploy chainlink relayer
    chainlinkEthUSDPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(SEPOLIA_CHAINLINK_ETH_USD_FEED, ORACLE_INTERVAL_TEST);
    data.setChainlinkRelayer(address(chainlinkEthUSDPriceFeed));

    // deploy camelot relayer
    camelotRelayer = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, data.tokenA(), data.tokenB(), uint32(ORACLE_INTERVAL_TEST)
    );
    data.setCamelotRelayer(address(camelotRelayer));

    // deploy denominated oracle
    denominatedOracle =
      denominatedOracleFactory.deployDenominatedOracle(chainlinkEthUSDPriceFeed, camelotRelayer, false);
    data.setDenominatedOracle(address(denominatedOracle));

    vm.stopBroadcast();
  }

  /**
   * @dev setup functions
   */
  function deployFactories() public {
    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    camelotRelayerFactory = new CamelotRelayerFactory();
    denominatedOracleFactory = new DenominatedOracleFactory();
  }
}
