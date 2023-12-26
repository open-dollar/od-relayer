// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';
import {RelayerFactory} from '@contracts/factories/RelayerFactory.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';

abstract contract Common is Script {
  RelayerFactory public camelotRelayerFactory = RelayerFactory(CAMELOT_RELAYER_FACTORY);
  ChainlinkRelayerFactory public chainlinkRelayerFactory = ChainlinkRelayerFactory(CHAINLINK_RELAYER_FACTORY);
  DenominatedOracleFactory public denominatedOracleFactory = DenominatedOracleFactory(DENOMINATED_ORACLE_FACTORY);

  function _revoke(IAuthorizable _contract, address _authorize, address _deauthorize) internal {
    _contract.addAuthorization(_authorize);
    _contract.removeAuthorization(_deauthorize);
  }

  function revokeFactories() internal {
    _revoke(IAuthorizable(address(camelotRelayerFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
    _revoke(IAuthorizable(address(chainlinkRelayerFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
    _revoke(IAuthorizable(address(denominatedOracleFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
  }
}
