// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

uint256 constant WAD = 1e18;

// -- Sepolia --

// DAO
address constant TEST_GOVERNOR = 0x37c5B029f9c3691B3d47cb024f84E5E257aEb0BB;

// Registry of protocol deployment
address constant SEPOLIA_SYSTEM_COIN = 0x36D197e6145B37b8E2c6Ed20B568860835b55584;
address constant SEPOLIA_WETH = 0x980B62Da83eFf3D4576C647993b0c1D7faf17c73;

address constant SEPOLIA_SYSTEM_COIN_NEW = 0x04f2d31052c1f5012C3296710700719FDFe40B41;

// Testnet Params
uint256 constant ORACLE_INTERVAL_TEST = 1 minutes;
uint256 constant MINT_AMOUNT = 1_000_000 ether;
uint256 constant INIT_WETH_AMOUNT = 1 ether;
uint256 constant INIT_OD_AMOUNT = 3895 ether; // as of March 15, 2024

// Members for governance
address constant H = 0x37c5B029f9c3691B3d47cb024f84E5E257aEb0BB;

// Data for dexrelayer script (for test) and Router for AlgebraPool
address constant RELAYER_DATA = 0x1F17CB9B80192E5C6E9BbEdAcc5F722a4e93f16e;
address constant ROUTER = 0x2a004eA6266eA1A340D1a7D78F1e0F4e9Ae2e685;
address constant RELAYER_ONE = 0xa430DD704aC39756fbA7C26FEAF9A220741c05b0; // DEX pool relayer for `dexrelayer` scripts

// Camelot Relayer
address constant SEPOLIA_CAMELOT_RELAYER_FACTORY = 0x7C85Bceb6DE55f317fe846a2e02100Ac84e94167; // from pre-deployment
address constant SEPOLIA_CAMELOT_RELAYER = address(0); // post setup

// Chainlink Relayer
address constant SEPOLIA_CHAINLINK_RELAYER_FACTORY = 0x67760796Ae4beD0b317ECcd4e482EFca46F10D68; // from pre-deployment
address constant SEPOLIA_CHAINLINK_RELAYER = address(0); // post setup

// Denominated Oracle
address constant SEPOLIA_DENOMINATED_ORACLE_FACTORY = 0x07ACBf81a156EAe49Eaa0eF80bBAe4E050f6278e; // from pre-deployment
address constant SEPOLIA_SYSTEM_ORACLE = address(0); // post setup

// Chainlink feeds
address constant SEPOLIA_CHAINLINK_ETH_USD_FEED = 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165;
address constant SEPOLIA_CHAINLINK_ARB_USD_FEED = 0xD1092a65338d049DB68D7Be6bD89d17a0929945e;

// Algebra protocol (deployed by daopunk - not official camelot contracts)
address constant SEPOLIA_ALGEBRA_FACTORY = 0x21852176141b8D139EC5D3A1041cdC31F0F20b94;
address constant SEPOLIA_ALGEBRA_POOL_DEPLOYER = 0xca5C849a6ce036cdF83e8F87dCa71Dc2B309E59b;
address constant SEPOLIA_ALGEBRA_QUOTER = 0xf7E25be14E5F5e36d5c2FE7a7822A601d18CD120;
address constant SEPOLIA_ALGEBRA_SWAPROUTER = 0xD18583a01837c9Dc4dC02E2202955E9d71C08771;
address constant SEPOLIA_ALGEBRA_NFT_DESCRIPTOR = 0x88Fa9f46645C7c638fFA9675b36DfdeF2cbae296;
address constant SEPOLIA_ALGEBRA_PROXY = 0xDAed3376f8112570a9E319A1D425C9B37CA901B3;
address constant SEPOLIA_ALGEBRA_NFT_MANAGER = 0xAf588D87BaDE8654F26686D5502be8ceDbE8FFe0;
address constant SEPOLIA_ALGEBRA_INTERFACE_MULTICALL = 0xf94b8a5D6dBd8F4026Ae467fdDB96028F74b9B96;
address constant SEPOLIA_ALGEBRA_V3_MIGRATOR = 0x766682889b8A6070be210C2a821Ad671E3388ab3;
address constant SEPOLIA_ALGEBRA_LIMIT_FARMING = 0x62B46a9565C7ECEc4FE7Dd309174ac3B03AF44E2;
address constant SEPOLIA_ALGEBRA_ETERNAL_FARMING = 0xD8474356C6976E18275735531b22f3Aa872a8b3B;
address constant SEPOLIA_ALGEBRA_FARM_CENTER = 0x04e4A5A4E4D2A5a0fb48ECde0bbD5554652D254b;

// -- Mainnet --

address constant MAINNET_PROTOCOL_TOKEN = 0x000D636bD52BFc1B3a699165Ef5aa340BEA8939c;
address constant MAINNET_WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

address constant MAINNET_ALGEBRA_FACTORY = 0x1a3c9B1d2F0529D97f2afC5136Cc23e58f1FD35B;

// Pre-deployment relayer factories
address constant MAINNET_CAMELOT_RELAYER_FACTORY = 0xC235041D2ea652261f816e4e8F56bD02AD623E11;
address constant MAINNET_CHAINLINK_RELAYER_FACTORY = 0x62f4A8565BDca2bB2b7975D4d5B48F61DA8846f5;
address constant MAINNET_DENOMINATED_ORACLE_FACTORY = 0xb6010972669953F6212B4AD969753c6e22ed5131;

// Relayers
address constant MAINNET_CAMELOT_ODG_WETH_RELAYER = 0xF7Ec9ad3192d4ec1E54d52B3E492B5B66AB02889;

address constant MAINNET_CHAINLINK_ETH_USD_RELAYER = 0x1d2eA5253A3dc201d2275885621c095C6e656e29;
address constant MAINNET_CHAINLINK_RETH_ETH_RELAYER = 0x007E6300C8D98F5B34dFe040248A596482d82B3f;
address constant MAINNET_CHAINLINK_WSTETH_ETH_RELAYER = 0x48D3B7605B8dc3Ae231Bd59e40513C9e9Ac6D33a;

address constant MAINNET_DENOMINATED_ODG_USD_ORACLE = 0xE90E52eb676bc00DD85FAE83D2FAC22062F7f470;
address constant MAINNET_DENOMINATED_RETH_USD_ORACLE = 0xCa3AD386d14d851A5fF5f08De2Bd2de88db2d5A0;
address constant MAINNET_DENOMINATED_WSTETH_USD_ORACLE = 0xCeE84f86d76bADa12262138b860D772812334DD6;

// Oracles params
uint256 constant MAINNET_ORACLE_INTERVAL = 1 hours;

// Chainlink feeds to USD
address constant MAINNET_CHAINLINK_ARB_USD_FEED = 0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6;
address constant MAINNET_CHAINLINK_ETH_USD_FEED = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

// Chainlink feeds to ETH
address constant MAINNET_CHAINLINK_WSTETH_ETH_FEED = 0xb523AE262D20A936BC152e6023996e46FDC2A95D;
address constant MAINNET_CHAINLINK_CBETH_ETH_FEED = 0xa668682974E3f121185a3cD94f00322beC674275;
address constant MAINNET_CHAINLINK_RETH_ETH_FEED = 0xD6aB2298946840262FcC278fF31516D39fF611eF;

address constant ETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
address constant ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;
address constant ETH_ARB_POOL = 0xe51635ae8136aBAc44906A8f230C2D235E9c195F;

address constant MAINNET_DEPLOYER = 0xF78dA2A37049627636546E0cFAaB2aD664950917;
