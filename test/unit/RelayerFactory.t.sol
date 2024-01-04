// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

import '@script/Registry.s.sol';
import {DSTestPlus} from '@test/utils/DSTestPlus.t.sol';
import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {CamelotRelayerChild} from '@contracts/factories/CamelotRelayerChild.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';

abstract contract Base is DSTestPlus {
  address deployer = label('deployer');
  address authorizedAccount = label('authorizedAccount');
  address user = label('user');

  IAlgebraFactory mockAlgebraFactory = IAlgebraFactory(mockContract(SEPOLIA_ALGEBRA_FACTORY, 'UniswapV3Factory'));
  IAlgebraPool mockAlgebraPool = IAlgebraPool(mockContract('UniswapV3Pool'));
  IERC20Metadata mockBaseToken = IERC20Metadata(mockContract('BaseToken'));
  IERC20Metadata mockQuoteToken = IERC20Metadata(mockContract('QuoteToken'));

  CamelotRelayerFactory relayerFactory;
  CamelotRelayerChild relayerChild = CamelotRelayerChild(
    label(address(0x0000000000000000000000007f85e9e000597158aed9320b5a5e11ab8cc7329a), 'CamelotRelayerChild')
  );

  function setUp() public virtual {
    vm.startPrank(deployer);

    relayerFactory = new CamelotRelayerFactory();
    label(address(relayerFactory), 'CamelotRelayerFactory');

    relayerFactory.addAuthorization(authorizedAccount);

    vm.stopPrank();
  }

  function _mockGetPool(address _baseToken, address _quoteToken, address _algebraPool) internal {
    vm.mockCall(
      address(mockAlgebraFactory),
      abi.encodeWithSignature('poolByPair(address,address)', _baseToken, _quoteToken),
      abi.encode(_algebraPool)
    );
  }

  function _mockToken0(address _token0) internal {
    vm.mockCall(address(mockAlgebraPool), abi.encodeWithSignature('token0()'), abi.encode(_token0));
  }

  function _mockToken1(address _token1) internal {
    vm.mockCall(address(mockAlgebraPool), abi.encodeWithSignature('token1()'), abi.encode(_token1));
  }

  function _mockSymbol(string memory _symbol) internal {
    vm.mockCall(address(mockBaseToken), abi.encodeWithSignature('symbol()'), abi.encode(_symbol));
    vm.mockCall(address(mockQuoteToken), abi.encodeWithSignature('symbol()'), abi.encode(_symbol));
  }

  function _mockDecimals(uint8 _decimals) internal {
    vm.mockCall(address(mockBaseToken), abi.encodeWithSignature('decimals()'), abi.encode(_decimals));
    vm.mockCall(address(mockQuoteToken), abi.encodeWithSignature('decimals()'), abi.encode(_decimals));
  }
}

contract Unit_RelayerFactory_Constructor is Base {
  event AddAuthorization(address _account);

  modifier happyPath() {
    vm.startPrank(user);
    _;
  }

  function test_Emit_AddAuthorization() public happyPath {
    vm.expectEmit();
    emit AddAuthorization(user);

    relayerFactory = new CamelotRelayerFactory();
  }
}

contract Unit_RelayerFactory_DeployRelayer is Base {
  event NewAlgebraRelayer(address indexed _relayer, address _baseToken, address _quoteToken, uint32 _quotePeriod);

  modifier happyPath(string memory _symbol, uint8 _decimals) {
    vm.startPrank(authorizedAccount);

    _assumeHappyPath(_decimals);
    _mockValues(_symbol, _decimals);
    _;
  }

  function _assumeHappyPath(uint8 _decimals) internal pure {
    vm.assume(_decimals <= 18);
  }

  function _mockValues(string memory _symbol, uint8 _decimals) internal {
    _mockGetPool(address(mockBaseToken), address(mockQuoteToken), address(mockAlgebraPool));
    _mockToken0(address(mockBaseToken));
    _mockToken1(address(mockQuoteToken));
    _mockSymbol(_symbol);
    _mockDecimals(_decimals);
  }

  function test_Revert_Unauthorized(uint32 _quotePeriod) public {
    vm.expectRevert('Unauthorized');

    relayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );
  }

  function test_Deploy_RelayerChild(
    uint32 _quotePeriod,
    string memory _symbol,
    uint8 _decimals
  ) public happyPath(_symbol, _decimals) {
    relayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );

    // assertEq(address(relayerChild).code, type(CamelotRelayerChild).runtimeCode);

    // params
    assertEq(relayerChild.baseToken(), address(mockBaseToken));
    assertEq(relayerChild.quoteToken(), address(mockQuoteToken));
    assert(relayerChild.quotePeriod() == _quotePeriod);
  }

  function test_Set_Relayers(
    uint32 _quotePeriod,
    string memory _symbol,
    uint8 _decimals
  ) public happyPath(_symbol, _decimals) {
    relayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );

    assertEq(relayerFactory.relayerById(1), address(relayerChild));
  }

  function test_Emit_NewRelayer(
    uint32 _quotePeriod,
    string memory _symbol,
    uint8 _decimals
  ) public happyPath(_symbol, _decimals) {
    vm.expectEmit();
    emit NewAlgebraRelayer(address(relayerChild), address(mockBaseToken), address(mockQuoteToken), _quotePeriod);

    relayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );
  }

  function test_Return_Relayer(
    uint32 _quotePeriod,
    string memory _symbol,
    uint8 _decimals
  ) public happyPath(_symbol, _decimals) {
    assertEq(
      address(
        relayerFactory.deployAlgebraRelayer(
          SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
        )
      ),
      address(relayerChild)
    );
  }
}
