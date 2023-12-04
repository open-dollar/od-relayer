// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {RelayerFactory} from '@contracts/factories/RelayerFactory.sol';
import {IRelayer} from '@interfaces/oracles/IRelayer.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Router} from '@contracts/for-test/Router.sol';
import {Data} from '@contracts/for-test/Data.sol';

// BROADCAST
// source .env && forge script DeployBase --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployBase --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployBase is Script {
  // Pool & Relayer Factories
  IAlgebraFactory public algebraFactory = IAlgebraFactory(ALGEBRA_FACTORY);

  // Router
  Router public router;

  Data public data;

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_PK'));

    data = new Data();

    deployTestTokens();
    deployPool();

    // check balance before
    (uint256 bal0, uint256 bal1) = data.getPoolBal();

    // deploy router and approve it to handle funds
    router = new Router(data.pool(), H);
    IERC20(data.tokenA()).approve(address(router), MINT_AMOUNT);
    IERC20(data.tokenB()).approve(address(router), MINT_AMOUNT);

    // add liquidity
    (int24 bottomTick, int24 topTick) = data.generateTickParams();
    router.addLiquidity(bottomTick, topTick, uint128(100));

    // check balance after
    (bal0, bal1) = data.getPoolBal();

    vm.stopBroadcast();
  }

  /**
   * @dev setup functions
   */
  function deployTestTokens() public {
    MintableERC20 token0 = new MintableERC20('LST Test1', 'LST1', 18);
    MintableERC20 token1 = new MintableERC20('LST Test2', 'LST2', 18);
    token0.mint(H, MINT_AMOUNT);
    token1.mint(H, MINT_AMOUNT);
    data.setTokens(address(token0), address(token1));
  }

  function deployPool() public {
    algebraFactory.createPool(data.tokenA(), data.tokenB());
    data.setPool(IAlgebraPool(algebraFactory.poolByPair(data.tokenA(), data.tokenB())));
    data.pool().initialize(getSqrtPrice(1 ether, 1656.62 ether));
  }

  function getSqrtPrice(uint256 _initWethAmount, uint256 _initODAmount) public returns (uint160) {
    uint256 price = (_initWethAmount * WAD) / _initODAmount;
    uint256 sqrtPriceX96 = sqrt(price * WAD) * (2 ** 96);
    return uint160(sqrtPriceX96);
  }

  // TODO test against isomate sqrt function
  function sqrt(uint256 x) public pure returns (uint256 y) {
    uint256 z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
  }
}
