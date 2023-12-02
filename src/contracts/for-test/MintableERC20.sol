// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';

/**
 * @title  MintableERC20
 * @dev This ERC20 contract is used for testing purposes, to allow users to mint tokens
 */
contract MintableERC20 is ERC20 {
  ///@dev The number of decimals the token uses
  uint8 internal _decimals;

  /**
   * @param  _name The name of the ERC20 token
   * @param  _symbol The symbol of the ERC20 token
   * @param  __decimals The number of decimals the token uses
   */
  constructor(string memory _name, string memory _symbol, uint8 __decimals) ERC20(_name, _symbol) {
    _decimals = __decimals;
  }

  function decimals() public view virtual override returns (uint8 __decimals) {
    return _decimals;
  }

  /**
   * @dev Mint tokens to the caller
   * @param  _wei The amount of tokens to mint (in wei representation)
   * @dev    The minting amount is capped to uint192 to avoid overflowing supply
   */
  function mint(uint256 _wei) external {
    _mint(msg.sender, uint256(uint192(_wei)));
  }

  /**
   * @dev Mint tokens to the specified user
   * @param  _usr Address of the user to mint tokens to
   * @param  _wei The amount of tokens to mint (in wei representation)
   * @dev    The minting amount is capped to uint192 to avoid overflowing supply
   */
  function mint(address _usr, uint256 _wei) external {
    _mint(_usr, uint256(uint192(_wei)));
  }
}
