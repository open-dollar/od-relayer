// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import 'forge-std/console2.sol';
import '@script/Registry.s.sol';
import {CommonSepolia} from '@script/Common.s.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Router} from '@contracts/for-test/Router.sol';

interface IVault721 {
  function getProxy(address _user) external view returns (address);
  function build(address _user) external returns (address payable);
}

interface ODProxy {
  function execute(address _target, bytes memory _data) external returns (bytes memory);
}

// BROADCAST
// source .env && forge script MockSetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script MockSetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract MockSetupPostEnvironment is CommonSepolia {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(SEPOLIA_ALGEBRA_FACTORY);
  MintableERC20 public mockWeth;
  MintableERC20 public mockWsteth = MintableERC20(0x5Ae92E2cBce39b74f149B7dA16d863382397d4a7);

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    mockWeth = new MintableERC20('Wrapped ETH', 'WETH', 18);

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

    // check pool balance before
    IERC20(SEPOLIA_SYSTEM_COIN).balanceOf(_pool);
    IERC20(mockWeth).balanceOf(_pool);

    // mint SystemCoin and Weth to use as liquidity
    mintMockWeth();
    mintSystemCoin();

    // deploy Router for AlgebraPool
    Router _router = new Router(IAlgebraPool(_pool), deployer);

    // approve tokens to Router
    IERC20(SEPOLIA_SYSTEM_COIN).approve(address(_router), MINT_AMOUNT);
    IERC20(mockWeth).approve(address(_router), MINT_AMOUNT);

    // add liquidity
    (int24 bottomTick, int24 topTick) = generateTickParams(IAlgebraPool(_pool));
    _router.addLiquidity(bottomTick, topTick, uint128(100));

    // check pool balance after
    IERC20(SEPOLIA_SYSTEM_COIN).balanceOf(_pool);
    IERC20(mockWeth).balanceOf(_pool);

    vm.stopBroadcast();
  }

  function mintMockWeth() public {
    mockWeth.mint(deployer, MINT_AMOUNT);
  }

  // todo: remove `magic` numbers - refactor
  function mintSystemCoin() public {
    IVault721 vault721 = IVault721(0xa602c0cFf8028Dd4c99fbC5e85cF0c083C5b991A);
    address _safeManager = 0x8ca7D88eaFB6f666997Ca0F62Beddd8A09a62910;
    address _basicActions = 0x60487E0a0eFbfbD30908b03ea6b7833E2520604F;
    address _coinJoin = 0x93544B224AB94F2b568CaeD5A074f4217fC782c7;
    address _collateralJoin_wsteth = 0x52400D3AEB82b0923898D918be51439A9198D980;

    // create proxy for deployer
    address _proxy = vault721.getProxy(deployer);
    if (_proxy == address(0)) {
      _proxy = vault721.build(deployer);
    }

    // create safe for deployer
    bytes memory _payload =
      abi.encodeWithSignature('openSAFE(address,bytes32,address)', _safeManager, bytes32('WSTETH'), _proxy);
    bytes memory _safeData = ODProxy(_proxy).execute(_basicActions, _payload);
    uint256 _safeId = abi.decode(_safeData, (uint256));

    // mint token
    mockWsteth.mint(deployer, MINT_AMOUNT);
    IERC20(mockWsteth).approve(_proxy, MINT_AMOUNT);

    // lock collateral & generate debt
    bytes memory payload = abi.encodeWithSignature(
      'lockTokenCollateralAndGenerateDebt(address,address,address,uint256,uint256,uint256)',
      _safeManager,
      _collateralJoin_wsteth,
      _coinJoin,
      _safeId,
      850_000_000_000_000_000,
      500_000_000_000_000_000_000
    );
    ODProxy(_proxy).execute(_basicActions, payload);
  }

  function generateTickParams(IAlgebraPool pool) public view returns (int24 bottomTick, int24 topTick) {
    (, int24 tick,,,,,) = pool.globalState();
    int24 tickSpacing = pool.tickSpacing();
    bottomTick = ((tick / tickSpacing) * tickSpacing) - 3 * tickSpacing;
    topTick = ((tick / tickSpacing) * tickSpacing) + 3 * tickSpacing;
  }
}
