// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import 'forge-std/console2.sol';
import '@script/Registry.s.sol';
import {Common} from '@script/Common.s.sol';
import {Sqrt} from '@algebra-core/libraries/Sqrt.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';

// BROADCAST
// source .env && forge script SetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script SetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract SetupPostEnvironment is Common {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(SEPOLIA_ALGEBRA_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    MintableERC20 mockWeth = new MintableERC20('Wrapped ETH', 'WETH', 18);

    // algebraFactory.createPool(SEPOLIA_SYSTEM_COIN, SEPOLIA_WETH);
    // address _pool = algebraFactory.poolByPair(SEPOLIA_SYSTEM_COIN, SEPOLIA_WETH);

    algebraFactory.createPool(SEPOLIA_SYSTEM_COIN, address(mockWeth));
    address _pool = algebraFactory.poolByPair(SEPOLIA_SYSTEM_COIN, address(mockWeth));

    IERC20Metadata _token0 = IERC20Metadata(IAlgebraPool(_pool).token0());
    IERC20Metadata _token1 = IERC20Metadata(IAlgebraPool(_pool).token1());

    require(keccak256(abi.encodePacked('OD')) == keccak256(abi.encodePacked(_token0.symbol())), '!OD');
    require(keccak256(abi.encodePacked('WETH')) == keccak256(abi.encodePacked(_token1.symbol())), '!WETH');

    uint256 initWethAmount = 1 ether;
    uint256 initODAmount = 2221.3997 ether;

    uint256 _price = ((initWethAmount * WAD) / initODAmount);
    console2.logUint(uint160(Sqrt.sqrtAbs(int256(_price)) * (2 ** 96)));

    // uint256 _sqrtPriceX96 = sqrt(_price * WAD) * (2 ** 96);
    uint256 _sqrtPriceX96 = Sqrt.sqrtAbs(int256(_price)) * (2 ** 96);

    IAlgebraPool(_pool).initialize(uint160(_sqrtPriceX96));

    IBaseOracle _odWethOracle = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, SEPOLIA_SYSTEM_COIN, SEPOLIA_WETH, uint32(ORACLE_INTERVAL_TEST)
    );

    IBaseOracle chainlinkEthUSDPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(SEPOLIA_CHAINLINK_ETH_USD_FEED, ORACLE_INTERVAL_TEST);

    // deploy systemOracle
    denominatedOracleFactory.deployDenominatedOracle(_odWethOracle, chainlinkEthUSDPriceFeed, false);

    revokeFactories();

    /**
     * note oracleRelayer will be set to systemOracle in odContracts post deploy script
     * code: `oracleRelayer.modifyParameters('systemCoinOracle', abi.encode(systemCoinOracle));`
     */

    vm.stopBroadcast();
  }
}
