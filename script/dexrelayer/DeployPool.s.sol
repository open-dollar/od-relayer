// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {Sqrt} from '@algebra-core/libraries/Sqrt.sol';
import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {ICamelotRelayer} from '@interfaces/oracles/ICamelotRelayer.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Router} from '@contracts/for-test/Router.sol';
import {Data} from '@contracts/for-test/Data.sol';

// BROADCAST
// source .env && forge script DeployPool --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script DeployPool --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract DeployPool is Script {
  Data public data = Data(RELAYER_DATA);

  // Pool Factory
  IAlgebraFactory public algebraFactory = IAlgebraFactory(SEPOLIA_ALGEBRA_FACTORY);

  // Router
  Router public router;

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_PK'));

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
    MintableERC20 token0 = new MintableERC20('Open Dollar', 'OD', 18);
    MintableERC20 token1 = new MintableERC20('Wrapped ETH', 'WETH', 18);
    token0.mint(H, MINT_AMOUNT);
    token1.mint(H, MINT_AMOUNT);
    data.setTokens(address(token0), address(token1));
  }

  function deployPool() public {
    algebraFactory.createPool(data.tokenA(), data.tokenB());
    data.setPool(IAlgebraPool(algebraFactory.poolByPair(data.tokenA(), data.tokenB())));
    uint160 _sqrtPriceX96 = initialPrice(INIT_OD_AMOUNT, INIT_WETH_AMOUNT, address(data.pool()));
    data.pool().initialize(_sqrtPriceX96);
  }

  // basePrice = OD, quotePrice = WETH
  function initialPrice(
    uint256 _basePrice,
    uint256 _quotePrice,
    address _pool
  ) internal view returns (uint160 _sqrtPriceX96) {
    address _token0 = IAlgebraPool(_pool).token0();
    bytes32 _symbol = keccak256(abi.encodePacked(IERC20Metadata(_token0).symbol()));
    uint256 _price;

    // price = token1 / token0
    if (_token0 == data.tokenA()) {
      require(keccak256(abi.encodePacked('OD')) == _symbol, '!OD');
      _price = ((_quotePrice * WAD) / _basePrice);
    } else {
      require(keccak256(abi.encodePacked('WETH')) == _symbol, '!WETH');
      _price = ((_basePrice * WAD) / _quotePrice);
    }

    _sqrtPriceX96 = uint160(Sqrt.sqrtAbs(int256(_price)) * (2 ** 96));
  }
}
