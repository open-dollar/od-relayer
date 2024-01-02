// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {Test} from 'forge-std/Test.sol';
import {SafeMath} from '@openzeppelin/contracts/math/SafeMath.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IChainlinkRelayer} from '@interfaces/oracles/IChainlinkRelayer.sol';
import {ICamelotRelayer} from '@interfaces/oracles/ICamelotRelayer.sol';
import {IDenominatedOracle} from '@interfaces/oracles/IDenominatedOracle.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {Data} from '@contracts/for-test/Data.sol';

// BROADCAST
// source .env && forge script GetPrice --skip-simulation --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script GetPrice --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract GetPrice is Script, Test {
  Data public data = Data(RELAYER_DATA);

  // -- Constants --
  uint256 constant INIT_WETH = 1 ether;
  uint256 constant INIT_OD = 2355 ether;

  // Tokens
  address public tokenA = data.tokenA();
  address public tokenB = data.tokenB();

  // Pool
  IAlgebraPool public pool = data.pool();
  uint256 public initPrice = ((INIT_WETH * WAD) / INIT_OD);

  // Relayers
  IBaseOracle public chainlinkRelayer = IBaseOracle(address(data.chainlinkRelayer()));
  IBaseOracle public camelotRelayer = IBaseOracle(address(data.camelotRelayer()));
  IBaseOracle public denominatedOracle = IBaseOracle(address(data.denominatedOracle()));

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_PK'));

    poolPrice();
    chainlinkRelayerPrice();
    camelotRelayerPrice();
    denominatedOraclePrice();
  }

  function poolPrice() public {
    IAlgebraPool _pool = IAlgebraPool(pool);
    (uint160 _sqrtPriceX96,,,,,,) = _pool.globalState();

    emit log_named_uint('sqrtPriceX96', _sqrtPriceX96);

    uint256 _price = (SafeMath.div(uint256(_sqrtPriceX96), (2 ** 96))) ** 2;
    assertApproxEqAbs(initPrice, _price, 100_000_000); // 0.000000000100000000 variability

    emit log_named_uint('Price from LPool', _price); // 0.000424628419232196 ether
    emit log_named_uint('Price Calculated', (INIT_WETH * WAD) / INIT_OD); // 0.000424628450106157 ether
  }

  function chainlinkRelayerPrice() public {
    uint256 _result = chainlinkRelayer.read();
    emit log_named_uint('Chainlink ETH/USD', _result); // 2382270000000000000000 (w/ 18 decimal = 2382.270...)

    assertApproxEqAbs(INIT_OD / 1e18, _result / 1e18, 500); // $500 flex for
  }

  function camelotRelayerPrice() public {
    uint256 _result = camelotRelayer.read();
    emit log_named_uint('Camelot OD/WETH', _result); // 424620063704448204165193502948931 (w/ 36 decimal = 0.000424...)

    assertApproxEqAbs(initPrice, _result / 1e18, 10_000_000_000); // 0.000000001000000000 variability
  }

  function denominatedOraclePrice() public {
    uint256 _result = denominatedOracle.read(); // 1008432145061984058301035060743127269 (w/ 36 decimal = 1.008...)
    emit log_named_uint('SystemOracle OD/USD', _result);
  }
}
