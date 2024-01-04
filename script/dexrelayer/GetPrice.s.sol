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
import {DataStorageLibrary} from '@algebra-periphery/libraries/DataStorageLibrary.sol';

// BROADCAST
// source .env && forge script GetPrice --skip-simulation --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script GetPrice --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract GetPrice is Script, Test {
  Data public data = Data(RELAYER_DATA);

  // Tokens
  address public tokenA = data.tokenA();
  address public tokenB = data.tokenB();

  // Pool
  IAlgebraPool public pool = data.pool();
  uint256 public initPrice = ((INIT_WETH_AMOUNT * WAD) / INIT_OD_AMOUNT);

  // Relayers
  IBaseOracle public chainlinkRelayer = IBaseOracle(address(data.chainlinkRelayer()));
  IBaseOracle public camelotRelayer = IBaseOracle(address(data.camelotRelayer()));
  IBaseOracle public denominatedOracle = IBaseOracle(address(data.denominatedOracle()));

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_PK'));

    poolPrice();
    camelotRelayerPrice();
    chainlinkRelayerPrice();
    denominatedOraclePrice();
  }

  function poolPrice() public {
    IAlgebraPool _pool = IAlgebraPool(pool);
    (uint160 _sqrtPriceX96,,,,,,) = _pool.globalState();

    emit log_named_uint('Sq Root Price X96', _sqrtPriceX96);

    uint256 _price = (SafeMath.div(uint256(_sqrtPriceX96), (2 ** 96))) ** 2;

    emit log_named_uint('Price from L-Pool', _price);
    emit log_named_uint('Price  Calculated', (INIT_WETH_AMOUNT * WAD) / INIT_OD_AMOUNT);
  }

  function camelotRelayerPrice() public {
    uint256 _result = camelotRelayer.read();
    emit log_named_uint('Camelot   OD/WETH', _result);
  }

  function chainlinkRelayerPrice() public {
    uint256 _result = chainlinkRelayer.read();
    emit log_named_uint('Chainlink ETH/USD', _result);
  }

  function denominatedOraclePrice() public {
    uint256 _result = denominatedOracle.read();
    emit log_named_uint('SystOracle OD/USD', _result);
  }
}

/**
 * == Logs ==
 *   Sq Root Price X96: 1677749592786826637668640749594345472
 *   Price from L-Pool: 448430472335329
 *   Price  Calculated: 448430493273542
 *   Camelot   OD/WETH: 448402863189474        ($0.0004484)
 *   Chainlink ETH/USD: 2217140000000000000000 ($2217.1400000)
 *   SystOracle OD/USD: 994171924091910384     ($0.9941719)
 */
