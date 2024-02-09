// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import 'forge-std/console2.sol';
import '@script/Registry.s.sol';
import {CommonSepolia} from '@script/Common.s.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';

// BROADCAST
// source .env && forge script MockSetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script MockSetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

// ToDo: add liquidity

contract MockSetupPostEnvironment is CommonSepolia {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(SEPOLIA_ALGEBRA_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    MintableERC20 mockWeth = new MintableERC20('Wrapped ETH', 'WETH', 18);

    algebraFactory.createPool(SEPOLIA_SYSTEM_COIN, address(mockWeth));
    address _pool = algebraFactory.poolByPair(SEPOLIA_SYSTEM_COIN, address(mockWeth));

    uint160 _sqrtPriceX96 = initialPrice(INIT_OD_AMOUNT, INIT_WETH_AMOUNT, _pool);
    IAlgebraPool(_pool).initialize(_sqrtPriceX96);

    IBaseOracle _odWethOracle = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, SEPOLIA_SYSTEM_COIN, address(mockWeth), uint32(ORACLE_INTERVAL_TEST)
    );

    IBaseOracle chainlinkEthUSDPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(SEPOLIA_CHAINLINK_ETH_USD_FEED, ORACLE_INTERVAL_TEST);

    // deploy systemOracle
    denominatedOracleFactory.deployDenominatedOracle(_odWethOracle, chainlinkEthUSDPriceFeed, false);

    authOnlyFactories();

    vm.stopBroadcast();
  }
}
