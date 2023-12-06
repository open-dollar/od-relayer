// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@script/Registry.s.sol';
import {Script} from 'forge-std/Script.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';

abstract contract Common is Script {
  function _revoke(IAuthorizable _contract, address _target) internal {
    _contract.addAuthorization(_target);
    _contract.removeAuthorization(msg.sender);
  }
}
