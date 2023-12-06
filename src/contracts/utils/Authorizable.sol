// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {EnumerableSet} from '@openzeppelin/contracts/utils/EnumerableSet.sol';

/**
 * @title  Authorizable
 * @notice Implements authorization control for contracts
 * @dev    Authorization control is boolean and handled by `onlyAuthorized` modifier
 */
abstract contract Authorizable {
  // --- Events ---

  /**
   * @notice Emitted when an account is authorized
   * @param _account Account that is authorized
   */
  event AddAuthorization(address _account);

  /**
   * @notice Emitted when an account is unauthorized
   * @param _account Account that is unauthorized
   */
  event RemoveAuthorization(address _account);

  using EnumerableSet for EnumerableSet.AddressSet;

  // --- Data ---

  EnumerableSet.AddressSet internal _authorizedAccounts;

  // --- Init ---

  /**
   * @param  _account Initial account to add authorization to
   */
  constructor(address _account) {
    _addAuthorization(_account);
  }

  // --- Views ---

  /**
   * @notice Checks whether an account is authorized
   * @return _authorized Whether the account is authorized or not
   */
  function authorizedAccounts(address _account) external view returns (bool _authorized) {
    return _isAuthorized(_account);
  }

  /**
   * @notice Getter for the authorized accounts
   * @return _accounts Array of authorized accounts
   * ONLY use as view function as can be very expensive
   */
  function authorizedAccounts() external view returns (address[] memory _accounts) {
    bytes32[] memory store = _authorizedAccounts._inner._values;
    address[] memory result;

    assembly {
      result := store
    }
    return result;
  }

  // --- Methods ---

  /**
   * @notice Add auth to an account
   * @param  _account Account to add auth to
   */
  function addAuthorization(address _account) external virtual isAuthorized {
    _addAuthorization(_account);
  }

  /**
   * @notice Remove auth from an account
   * @param  _account Account to remove auth from
   */
  function removeAuthorization(address _account) external virtual isAuthorized {
    _removeAuthorization(_account);
  }

  // --- Internal methods ---
  function _addAuthorization(address _account) internal {
    require(!_isAuthorized(_account), 'AlreadyAuthorized');
    _authorizedAccounts.add(_account);
    emit AddAuthorization(_account);
  }

  function _removeAuthorization(address _account) internal {
    require(_isAuthorized(_account), 'NotAuthorized');
    _authorizedAccounts.remove(_account);
    emit RemoveAuthorization(_account);
  }

  function _isAuthorized(address _account) internal view virtual returns (bool _authorized) {
    return _authorizedAccounts.contains(_account);
  }

  // --- Modifiers ---

  /**
   * @notice Checks whether msg.sender can call an authed function
   * @dev    Will revert with `Unauthorized` if the sender is not authorized
   */
  modifier isAuthorized() {
    require(_isAuthorized(msg.sender), 'Unauthorized');
    _;
  }
}
