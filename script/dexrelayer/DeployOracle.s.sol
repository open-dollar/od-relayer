// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {RelayerFactory} from '@contracts/factories/RelayerFactory.sol';
import {IRelayer} from '@interfaces/oracles/IRelayer.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';
import {Data} from '@contracts/for-test/Data.sol';

// TODO test denominated oracle after relayer works
// import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
// import {ChainlinkRelayerFactory, IChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';

// BROADCAST
// source .env && forge script DeployOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployOracle --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployOracle is Script {
  Data public data = Data(RELAYER_DATA);

  // IBaseOracle public chainlinkEthUSDPriceFeed;
  // IBaseOracle public relayer;
  // IBaseOracle public denominatedOracle;

  // ChainlinkRelayerFactory public chainlinkRelayerFactory;
  RelayerFactory public relayerFactory;
  // DenominatedOracleFactory public denominatedOracleFactory;

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_PK'));

    // deploy oracle factories
    deployFactories();

    // deploy chainlink relayer
    // chainlinkEthUSDPriceFeed =
    //   chainlinkRelayerFactory.deployChainlinkRelayer(GOERLI_CHAINLINK_ETH_USD_FEED, ORACLE_PERIOD);

    // deploy camelot relayer
    address relayer =
      address(relayerFactory.deployAlgebraRelayer(SEPOLIA_ALGEBRA_FACTORY, data.tokenA(), data.tokenB(), uint32(ORACLE_PERIOD)));
    data.setRelayer(relayer);

    // deploy denominated oracle
    // denominatedOracle =
    //   denominatedOracleFactory.deployDenominatedOracle(chainlinkEthUSDPriceFeed, camelotRelayer, false);

    vm.stopBroadcast();
  }

  /**
   * @dev setup functions
   */
  function deployFactories() public {
    // chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    relayerFactory = new RelayerFactory();
    // denominatedOracleFactory = new DenominatedOracleFactory();
  }
}
