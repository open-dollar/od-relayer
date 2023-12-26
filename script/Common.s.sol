// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';

abstract contract Common is Script {
  function _revoke(IAuthorizable _contract, address _authorize, address _deauthorize) internal {
    _contract.addAuthorization(_authorize);
    _contract.removeAuthorization(_deauthorize);
  }

  function revokeFactories() external {
    _revoke(IAuthorizable(address(camelotRelayerFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
    _revoke(IAuthorizable(address(chainlinkRelayerFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
    _revoke(IAuthorizable(address(densominatedOracleFactory)), TEST_GOVERNOR, vm.envAddress('ARB_SEPOLIA_DEPLOYER_PC'));
  }
}
