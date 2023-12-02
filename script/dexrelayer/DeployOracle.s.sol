// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {RelayerFactory} from '@contracts/factories/RelayerFactory.sol';
import {IRelayer} from '@interfaces/oracles/IRelayer.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';

// TODO test denominated oracle after relayer works
// import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
// import {ChainlinkRelayerFactory, IChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';

// BROADCAST
// source .env && forge script DeployOracle --with-gas-price 2000000000 -vvvvv --rpc-url $GOERLI_RPC --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployOracle --with-gas-price 2000000000 -vvvvv --rpc-url $GOERLI_RPC

contract DeployOracle is Script {
  uint256 private constant WAD = 1e18;
  uint256 private constant MINT_AMOUNT = 1_000_000 ether;
  uint256 private constant ORACLE_PERIOD = 1 seconds;

  IBaseOracle public chainlinkEthUSDPriceFeed;
  IBaseOracle public camelotRelayer;
  IBaseOracle public denominatedOracle;

  // ChainlinkRelayerFactory public chainlinkRelayerFactory;
  RelayerFactory public relayerFactory;
  // DenominatedOracleFactory public denominatedOracleFactory;

  address public tokenA = 0xEEB6187f4efAE5f513Dbf2873041CE7a3a375373;
  address public tokenB = 0x1F17CB9B80192E5C6E9BbEdAcc5F722a4e93f16e;

  function run() public {
    vm.startBroadcast(vm.envUint('GOERLI_PK'));

    // deploy oracle factories
    deployFactories();

    // deploy chainlink relayer
    // chainlinkEthUSDPriceFeed =
    //   chainlinkRelayerFactory.deployChainlinkRelayer(GOERLI_CHAINLINK_ETH_USD_FEED, ORACLE_PERIOD);

    // deploy camelot relayer
    camelotRelayer = relayerFactory.deployCamelotRelayer(tokenA, tokenB, uint32(ORACLE_PERIOD));

    // deploy denominated oracle
    // denominatedOracle =
    //   denominatedOracleFactory.deployDenominatedOracle(chainlinkEthUSDPriceFeed, camelotRelayer, false);

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
