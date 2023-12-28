// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {Sqrt} from '@algebra-core/libraries/Sqrt.sol';
import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';

abstract contract Common is Script {
  ChainlinkRelayerFactory public chainlinkRelayerFactory = ChainlinkRelayerFactory(CHAINLINK_RELAYER_FACTORY);
  CamelotRelayerFactory public camelotRelayerFactory = CamelotRelayerFactory(CAMELOT_RELAYER_FACTORY);
  DenominatedOracleFactory public denominatedOracleFactory = DenominatedOracleFactory(DENOMINATED_ORACLE_FACTORY);

  function _revoke(IAuthorizable _contract, address _authorize, address _deauthorize) internal {
    _contract.addAuthorization(_authorize);
    _contract.removeAuthorization(_deauthorize);
  }

  function revokeFactories() internal {
    _revoke(IAuthorizable(address(chainlinkRelayerFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
    _revoke(IAuthorizable(address(camelotRelayerFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
    _revoke(IAuthorizable(address(denominatedOracleFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
  }

  // basePrice = OD, quotePrice = WETH
  function initialPrice(
    uint256 _basePrice,
    uint256 _quotePrice,
    address _pool
  ) internal returns (uint160 _sqrtPriceX96) {
    address _token0 = IAlgebraPool(_pool).token0();
    bytes32 _symbol = keccak256(abi.encodePacked(IERC20Metadata(_token0).symbol()));
    uint256 _price;

    // price = token1 / token0
    if (_token0 == SEPOLIA_SYSTEM_COIN) {
      require(keccak256(abi.encodePacked('OD')) == _symbol, '!OD');
      _price = ((_quotePrice * WAD) / _basePrice);
    } else {
      require(keccak256(abi.encodePacked('WETH')) == _symbol, '!WETH');
      _price = ((_basePrice * WAD) / _quotePrice);
    }

    _sqrtPriceX96 = uint160(Sqrt.sqrtAbs(int256(_price)) * (2 ** 96));
  }

  /**
   * note FOR TEST
   */
  function authOnlyFactories() internal {
    IAuthorizable(address(chainlinkRelayerFactory)).addAuthorization(vm.envAddress('ARB_SEPOLIA_PC'));
    IAuthorizable(address(camelotRelayerFactory)).addAuthorization(vm.envAddress('ARB_SEPOLIA_PC'));
    IAuthorizable(address(denominatedOracleFactory)).addAuthorization(vm.envAddress('ARB_SEPOLIA_PC'));
  }
}
