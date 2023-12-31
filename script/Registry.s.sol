// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

// DAO
address constant TEST_GOVERNOR = 0x37c5B029f9c3691B3d47cb024f84E5E257aEb0BB;

// Registry of protocol deployment
address constant SEPOLIA_SYSTEM_COIN = 0x94beB5fC16824338Eaa538c3c857D7f7fFf4B2Ce;
address constant SEPOLIA_WETH = 0x980B62Da83eFf3D4576C647993b0c1D7faf17c73;

// Testnet Params
uint256 constant ORACLE_INTERVAL_TEST = 1 minutes;
uint256 constant WAD = 1e18;
uint256 constant MINT_AMOUNT = 1_000_000 ether;
uint256 constant INIT_WETH_AMOUNT = 1 ether;
uint256 constant INIT_OD_AMOUNT = 2230 ether;

// Members for governance
address constant H = 0x37c5B029f9c3691B3d47cb024f84E5E257aEb0BB;

// Data for dexrelayer script (for test) and Router for AlgebraPool
address constant RELAYER_DATA = 0x1F17CB9B80192E5C6E9BbEdAcc5F722a4e93f16e;
address constant ROUTER = 0x2a004eA6266eA1A340D1a7D78F1e0F4e9Ae2e685;

// Camelot Relayer
address constant CAMELOT_RELAYER_FACTORY = 0x6C87b6e2E651cc4ebcE3Ba782037898dDDB445bF; // from pre-deployment
address constant RELAYER_ONE = 0xa430DD704aC39756fbA7C26FEAF9A220741c05b0;

// Chainlink Relayer
address constant CHAINLINK_RELAYER_FACTORY = 0x253c08EeB065F8940A8277901c91Ab4931d19044; // from pre-deployment

// Denominated Oracle
address constant DENOMINATED_ORACLE_FACTORY = 0xD2823Cf1F062b2E92Fc33cd733a359fEFBA607dC; // from pre-deployment

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

address constant MAINNET_ALGEBRA_FACTORY = 0x1a3c9B1d2F0529D97f2afC5136Cc23e58f1FD35B;

// Chainlink feeds to USD
address constant CHAINLINK_ARB_USD_FEED = 0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6;
address constant CHAINLINK_ETH_USD_FEED = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

// Chainlink feeds to ETH
address constant CHAINLINK_WSTETH_ETH_FEED = 0xb523AE262D20A936BC152e6023996e46FDC2A95D;
address constant CHAINLINK_CBETH_ETH_FEED = 0xa668682974E3f121185a3cD94f00322beC674275;
address constant CHAINLINK_RETH_ETH_FEED = 0xF3272CAfe65b190e76caAF483db13424a3e23dD2;

address constant ETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
address constant ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;
address constant ETH_ARB_POOL = 0xe51635ae8136aBAc44906A8f230C2D235E9c195F;
