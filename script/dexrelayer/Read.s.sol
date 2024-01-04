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
// source .env && forge script Read --skip-simulation --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script Read --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract Read is Script, Test {
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
    readPrice();
    readPriceInverse();
  }

  function readPrice() public {
    int24 _arithmeticMeanTick = DataStorageLibrary.consult(address(data.pool()), uint32(ORACLE_INTERVAL_TEST));
    uint256 _quoteAmount = DataStorageLibrary.getQuoteAtTick({
      tick: _arithmeticMeanTick,
      baseAmount: 1e18,
      baseToken: data.tokenA(),
      quoteToken: data.tokenB()
    });
    emit log_named_uint('Quote Base A:', _quoteAmount);
  }

  function readPriceInverse() public {
    int24 _arithmeticMeanTick = DataStorageLibrary.consult(address(data.pool()), uint32(ORACLE_INTERVAL_TEST));
    uint256 _quoteAmount = DataStorageLibrary.getQuoteAtTick({
      tick: _arithmeticMeanTick,
      baseAmount: 1e18,
      baseToken: data.tokenB(),
      quoteToken: data.tokenA()
    });
    emit log_named_uint('Quote Base B:', _quoteAmount);
  }
}

/**
 * == Logs ==
 *   Quote Base A:: 2230
 *   Quote Base B:: 448402863189474895173495757900703
 */
