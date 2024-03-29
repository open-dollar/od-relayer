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
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {ChainlinkRelayerChild} from '@contracts/factories/ChainlinkRelayerChild.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
import {DenominatedOracleChild} from '@contracts/factories/DenominatedOracleChild.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';

abstract contract Base is DSTestPlus {
  address deployer = label('deployer');
  address authorizedAccount = label('authorizedAccount');
  address user = label('user');

  IAlgebraFactory mockAlgebraFactory = IAlgebraFactory(mockContract(SEPOLIA_ALGEBRA_FACTORY, 'UniswapV3Factory'));
  IAlgebraPool mockAlgebraPool = IAlgebraPool(mockContract('UniswapV3Pool'));
  IERC20Metadata mockBaseToken = IERC20Metadata(mockContract('BaseToken'));
  IERC20Metadata mockQuoteToken = IERC20Metadata(mockContract('QuoteToken'));

  CamelotRelayerFactory camelotRelayerFactory;
  IBaseOracle camelotRelayerChild;

  ChainlinkRelayerFactory chainlinkRelayerFactory;
  IBaseOracle chainlinkRelayerChild;

  DenominatedOracleFactory denominatedOracleFactory;
  IBaseOracle denominatedOracleChild;

  address mockAggregator = mockContract('ChainlinkAggregator');

  function setUp() public virtual {
    vm.startPrank(deployer);

    camelotRelayerFactory = new CamelotRelayerFactory();
    label(address(camelotRelayerFactory), 'CamelotRelayerFactory');

    camelotRelayerFactory.addAuthorization(authorizedAccount);

    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    label(address(chainlinkRelayerFactory), 'ChainlinkRelayerFactory');

    chainlinkRelayerFactory.addAuthorization(authorizedAccount);

    denominatedOracleFactory = new DenominatedOracleFactory();
    label(address(denominatedOracleFactory), 'DenominatedOracleFactory');

    denominatedOracleFactory.addAuthorization(authorizedAccount);

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
    vm.mockCall(address(mockAggregator), abi.encodeWithSignature('description()'), abi.encode(_symbol));
  }

  function _mockDecimals(uint8 _decimals) internal {
    vm.mockCall(address(mockBaseToken), abi.encodeWithSignature('decimals()'), abi.encode(_decimals));
    vm.mockCall(address(mockQuoteToken), abi.encodeWithSignature('decimals()'), abi.encode(_decimals));
    vm.mockCall(address(mockAggregator), abi.encodeWithSignature('decimals()'), abi.encode(_decimals));
  }
}

contract Unit_CamelotRelayerFactory_Constructor is Base {
  event AddAuthorization(address _account);

  modifier happyPath() {
    vm.startPrank(user);
    _;
  }

  function test_Emit_AddAuthorization() public happyPath {
    vm.expectEmit();
    emit AddAuthorization(user);

    camelotRelayerFactory = new CamelotRelayerFactory();
  }
}

contract Unit_RelayerFactory_DeployCamelotRelayer is Base {
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

    camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );
  }

  function test_Deploy_RelayerChild(
    uint32 _quotePeriod,
    string memory _symbol,
    uint8 _decimals
  ) public happyPath(_symbol, _decimals) {
    vm.expectEmit();
    emit NewAlgebraRelayer(
      address(0x7F85e9e000597158AED9320B5A5E11AB8cC7329A), address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );
    camelotRelayerChild = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );

    string memory concatSymbol = string(abi.encodePacked(_symbol, ' / ', _symbol));
    // params
    assertEq(camelotRelayerChild.symbol(), concatSymbol);
  }

  function test_Set_Relayers(
    uint32 _quotePeriod,
    string memory _symbol,
    uint8 _decimals
  ) public happyPath(_symbol, _decimals) {
    camelotRelayerChild = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );

    assertEq(camelotRelayerFactory.relayerById(1), address(camelotRelayerChild));
  }

  function test_Emit_NewRelayer(
    uint32 _quotePeriod,
    string memory _symbol,
    uint8 _decimals
  ) public happyPath(_symbol, _decimals) {
    vm.expectEmit();
    emit NewAlgebraRelayer(
      address(0x7F85e9e000597158AED9320B5A5E11AB8cC7329A), address(mockBaseToken), address(mockQuoteToken), _quotePeriod
    );

    camelotRelayerFactory.deployAlgebraRelayer(
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
        camelotRelayerFactory.deployAlgebraRelayer(
          SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), _quotePeriod
        )
      ),
      address(0x7F85e9e000597158AED9320B5A5E11AB8cC7329A)
    );
  }
}

contract Unit_ChainlinkRelayerFactory_Constructor is Base {
  event AddAuthorization(address _account);

  modifier happyPath() {
    vm.startPrank(user);
    _;
  }

  function test_Emit_AddAuthorization() public happyPath {
    vm.expectEmit();
    emit AddAuthorization(user);

    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
  }
}

contract Unit_RelayerFactory_DeployChainlinkRelayer is Base {
  event NewChainlinkRelayer(address indexed _chainlinkRelayer, address _aggregator, uint256 _staleThreshold);

  modifier happyPath(string memory _symbol, uint8 _decimals, uint256 _staleThreshold) {
    vm.startPrank(authorizedAccount);
    vm.assume(_staleThreshold > 0);
    _assumeHappyPath(_decimals);
    _mockSymbol(_symbol);
    _mockDecimals(_decimals);
    _;
  }

  function _assumeHappyPath(uint8 _decimals) internal pure {
    vm.assume(_decimals <= 18 && _decimals > 0);
  }

  function test_Deploy_RelayerChild(
    string memory _symbol,
    uint8 _decimals,
    uint256 _staleThreshold
  ) public happyPath(_symbol, _decimals, _staleThreshold) {
    vm.expectEmit();
    emit NewChainlinkRelayer(address(0x56D9e6a12fC3E3f589Ee5E685C9f118D62ce9C8D), mockAggregator, _staleThreshold);

    chainlinkRelayerChild = chainlinkRelayerFactory.deployChainlinkRelayer(mockAggregator, _staleThreshold);
    assertEq(chainlinkRelayerChild.symbol(), _symbol);
  }

  function test_Set_Relayers(
    string memory _symbol,
    uint8 _decimals,
    uint256 _staleThreshold
  ) public happyPath(_symbol, _decimals, _staleThreshold) {
    chainlinkRelayerChild = chainlinkRelayerFactory.deployChainlinkRelayer(mockAggregator, _staleThreshold);

    assertEq(chainlinkRelayerFactory.relayerById(1), address(chainlinkRelayerChild));
  }

  function test_Emit_NewRelayer(
    string memory _symbol,
    uint8 _decimals,
    uint256 _staleThreshold
  ) public happyPath(_symbol, _decimals, _staleThreshold) {
    vm.expectEmit();
    emit NewChainlinkRelayer(address(0x56D9e6a12fC3E3f589Ee5E685C9f118D62ce9C8D), mockAggregator, _staleThreshold);

    chainlinkRelayerChild = chainlinkRelayerFactory.deployChainlinkRelayer(mockAggregator, _staleThreshold);
    assertEq(chainlinkRelayerChild.symbol(), _symbol);
  }

  function test_Return_Relayer(
    string memory _symbol,
    uint8 _decimals,
    uint256 _staleThreshold
  ) public happyPath(_symbol, _decimals, _staleThreshold) {
    assertEq(
      address(chainlinkRelayerFactory.deployChainlinkRelayer(mockAggregator, _staleThreshold)),
      address(0x56D9e6a12fC3E3f589Ee5E685C9f118D62ce9C8D)
    );
  }
}

contract Unit_DenominatedPriceOracleFactory_Constructor is Base {
  event AddAuthorization(address _account);

  modifier happyPath() {
    vm.startPrank(user);
    _;
  }

  function test_Emit_AddAuthorization() public happyPath {
    vm.expectEmit();
    emit AddAuthorization(user);

    denominatedOracleFactory = new DenominatedOracleFactory();
  }
}

contract Unit_DenominatedPriceOracleFactory_DeployDenominatedOracle is Base {
  event NewDenominatedOracle(
    address indexed _denominatedOracle, address _priceSource, address _denominationPriceSource, bool _inverted
  );

  modifier happyPath() {
    vm.startPrank(authorizedAccount);
    _;
  }

  function setUp() public override {
    super.setUp();
    vm.startPrank(authorizedAccount);
    vm.mockCall(address(mockBaseToken), abi.encodeWithSignature('symbol()'), abi.encode('BaseToken'));
    vm.mockCall(address(mockQuoteToken), abi.encodeWithSignature('symbol()'), abi.encode('QuoteToken'));
    vm.mockCall(address(mockAggregator), abi.encodeWithSignature('description()'), abi.encode('Aggregator'));
    vm.mockCall(address(mockBaseToken), abi.encodeWithSignature('decimals()'), abi.encode(18));
    vm.mockCall(address(mockQuoteToken), abi.encodeWithSignature('decimals()'), abi.encode(18));
    vm.mockCall(address(mockAggregator), abi.encodeWithSignature('decimals()'), abi.encode(18));

    chainlinkRelayerChild = chainlinkRelayerFactory.deployChainlinkRelayer(mockAggregator, 100);
    _mockToken0(address(mockBaseToken));
    _mockToken1(address(mockQuoteToken));
    _mockGetPool(address(mockBaseToken), address(mockQuoteToken), address(mockAlgebraPool));

    camelotRelayerChild = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, address(mockBaseToken), address(mockQuoteToken), 1000
    );
    vm.stopPrank();
  }

  function test_Deploy_RelayerChild() public happyPath {
    vm.expectEmit();
    emit NewDenominatedOracle(
      address(0xb2A72B7BA8156A59fD84c61e5eF539d385D8652a),
      address(camelotRelayerChild),
      address(chainlinkRelayerChild),
      false
    );
    denominatedOracleChild =
      denominatedOracleFactory.deployDenominatedOracle(camelotRelayerChild, chainlinkRelayerChild, false);

    string memory symbol =
      string(abi.encodePacked('(', mockBaseToken.symbol(), ' / ', mockQuoteToken.symbol(), ') * (Aggregator)'));
    assertEq(denominatedOracleChild.symbol(), symbol);
  }

  function test_Deploy_RelayerChildInverted() public happyPath {
    vm.expectEmit();
    emit NewDenominatedOracle(
      address(0xb2A72B7BA8156A59fD84c61e5eF539d385D8652a),
      address(camelotRelayerChild),
      address(chainlinkRelayerChild),
      true
    );
    denominatedOracleChild =
      denominatedOracleFactory.deployDenominatedOracle(camelotRelayerChild, chainlinkRelayerChild, true);

    string memory symbol =
      string(abi.encodePacked('(', mockBaseToken.symbol(), ' / ', mockQuoteToken.symbol(), ')^-1 / (Aggregator)'));
    assertEq(denominatedOracleChild.symbol(), symbol);
  }

  function test_Set_Relayers() public happyPath {
    denominatedOracleChild =
      denominatedOracleFactory.deployDenominatedOracle(camelotRelayerChild, chainlinkRelayerChild, false);
    assertEq(denominatedOracleFactory.oracleById(1), address(denominatedOracleChild));
  }

  function test_Emit_NewRelayer() public happyPath {
    vm.expectEmit();
    emit NewDenominatedOracle(
      address(0xb2A72B7BA8156A59fD84c61e5eF539d385D8652a),
      address(camelotRelayerChild),
      address(chainlinkRelayerChild),
      false
    );
    denominatedOracleChild =
      denominatedOracleFactory.deployDenominatedOracle(camelotRelayerChild, chainlinkRelayerChild, false);
  }

  function test_Return_Relayer() public happyPath {
    assertEq(
      address(denominatedOracleFactory.deployDenominatedOracle(camelotRelayerChild, chainlinkRelayerChild, false)),
      address(0xb2A72B7BA8156A59fD84c61e5eF539d385D8652a)
    );
  }
}
