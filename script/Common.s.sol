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

abstract contract CommonSepolia is Script {
  ChainlinkRelayerFactory public chainlinkRelayerFactory = ChainlinkRelayerFactory(SEPOLIA_CHAINLINK_RELAYER_FACTORY);
  CamelotRelayerFactory public camelotRelayerFactory = CamelotRelayerFactory(SEPOLIA_CAMELOT_RELAYER_FACTORY);
  DenominatedOracleFactory public denominatedOracleFactory =
    DenominatedOracleFactory(SEPOLIA_DENOMINATED_ORACLE_FACTORY);

  IAuthorizable public chainlinkRelayerFactoryAuth = IAuthorizable(SEPOLIA_CHAINLINK_RELAYER_FACTORY);
  IAuthorizable public camelotRelayerFactoryAuth = IAuthorizable(SEPOLIA_CAMELOT_RELAYER_FACTORY);
  IAuthorizable public denominatedOracleFactoryAuth = IAuthorizable(SEPOLIA_DENOMINATED_ORACLE_FACTORY);

  address public deployer = vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC');
  address public admin = vm.envAddress('ARB_SEPOLIA_PC');

  function _revoke(IAuthorizable _contract, address _authorize, address _deauthorize) internal {
    _contract.addAuthorization(_authorize);
    _contract.removeAuthorization(_deauthorize);
  }

  function revokeFactories() internal {
    _revoke(chainlinkRelayerFactoryAuth, TEST_GOVERNOR, deployer);
    _revoke(camelotRelayerFactoryAuth, TEST_GOVERNOR, deployer);
    _revoke(denominatedOracleFactoryAuth, TEST_GOVERNOR, deployer);
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
    if (!chainlinkRelayerFactoryAuth.authorizedAccounts(admin)) {
      chainlinkRelayerFactoryAuth.addAuthorization(admin);
    }
    if (!camelotRelayerFactoryAuth.authorizedAccounts(admin)) {
      camelotRelayerFactoryAuth.addAuthorization(admin);
    }
    if (!denominatedOracleFactoryAuth.authorizedAccounts(admin)) {
      denominatedOracleFactoryAuth.addAuthorization(admin);
    }
  }
}
