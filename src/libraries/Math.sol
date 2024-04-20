// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

uint256 constant WAD = 1e18;

library Math {
  function wdiv(uint256 _x, uint256 _y) internal pure returns (uint256 _wdiv) {
    return (_x * WAD) / _y;
  }

  function wmul(uint256 _x, uint256 _y) internal pure returns (uint256 _wmul) {
    uint256 result = (_x * _y);
    require(result / _x == _y, 'wmul overflow error detected');

    return result / WAD;
  }
}
