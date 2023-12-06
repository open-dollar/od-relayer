// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import 'forge-std/console2.sol';
import '@script/Registry.s.sol';
import {Common} from '@script/Common.s.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {RelayerFactory} from '@contracts/factories/RelayerFactory.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';

// BROADCAST
// source .env && forge script SetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script SetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract SetupPostEnvironment is Common {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(ALGEBRA_FACTORY);
  RelayerFactory public camelotRelayerFactory = RelayerFactory(CAMELOT_RELAYER_FACTORY);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    algebraFactory.createPool(SEPOLIA_SYSTEM_COIN, SEPOLIA_WETH);
    address _pool = algebraFactory.poolByPair(SEPOLIA_SYSTEM_COIN, SEPOLIA_WETH);

    IERC20Metadata _token0 = IERC20Metadata(IAlgebraPool(_pool).token0());
    IERC20Metadata _token1 = IERC20Metadata(IAlgebraPool(_pool).token1());

    require(keccak256(abi.encodePacked('OD')) == keccak256(abi.encodePacked(_token0.symbol())), '!OD');
    require(keccak256(abi.encodePacked('WETH')) == keccak256(abi.encodePacked(_token1.symbol())), '!WETH');

    uint256 initWethAmount = 1 ether;
    uint256 initODAmount = 1656.62 ether;

    uint256 _price = (initWethAmount * WAD) / initODAmount;
    uint256 _sqrtPriceX96 = sqrt(_price * WAD) * (2 ** 96);
    console2.logUint((_sqrtPriceX96 / (2 ** 96)) ** 2);

    IAlgebraPool(_pool).initialize(uint160(_sqrtPriceX96));

    IBaseOracle _odWethOracle = camelotRelayerFactory.deployAlgebraRelayer(
      ALGEBRA_FACTORY, SEPOLIA_SYSTEM_COIN, SEPOLIA_WETH, uint32(ORACLE_INTERVAL_TEST)
    );

    /**
     * TODO: set denominated oracle to (_odWethOracle + chainlink ETH/USD)
     * systemCoinOracle = denominatedOracleFactory.deployDenominatedOracle(_odWethOracle, chainlinkEthUSDPriceFeed, false);
     * oracleRelayer.modifyParameters('systemCoinOracle', abi.encode(systemCoinOracle));
     */

    _revoke(IAuthorizable(address(camelotRelayerFactory)), TEST_GOVERNOR);

    vm.stopBroadcast();
  }

  function sqrt(uint256 x) public pure returns (uint256 y) {
    uint256 z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
  }
}
