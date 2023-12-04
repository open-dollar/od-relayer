// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

// Registry of protocol deployment
address constant SEPOLIA_SYSTEM_COIN = address(0);
address constant SEPOLIA_WETH = address(0);

// Testnet Params
uint256 constant ORACLE_PERIOD = 1 seconds;
uint256 constant ORACLE_INTERVAL_TEST = 1 minutes;
uint256 constant WAD = 1e18;
uint256 constant MINT_AMOUNT = 1_000_000 ether;

// Members for governance
address constant H = 0x37c5B029f9c3691B3d47cb024f84E5E257aEb0BB;

// Data for dexrelayer script
address constant RELAYER_DATA = 0x98A724ECA2804DE70Cae1f28E070D3973CAdcf05;

// Camelot Relayer
address constant CAMELOT_RELAYER_FACTORY = address(0); // from pre-deployment
address constant RELAYER_ONE = 0xa430DD704aC39756fbA7C26FEAF9A220741c05b0;

// Algebra protocol
address constant ALGEBRA_FACTORY = 0x21852176141b8D139EC5D3A1041cdC31F0F20b94;
address constant ALGEBRA_POOL_DEPLOYER = 0xca5C849a6ce036cdF83e8F87dCa71Dc2B309E59b;
address constant ALGEBRA_QUOTER = 0xf7E25be14E5F5e36d5c2FE7a7822A601d18CD120;
address constant ALGEBRA_SWAPROUTER = 0xD18583a01837c9Dc4dC02E2202955E9d71C08771;
address constant ALGEBRA_NFT_DESCRIPTOR = 0x88Fa9f46645C7c638fFA9675b36DfdeF2cbae296;
address constant ALGEBRA_PROXY = 0xDAed3376f8112570a9E319A1D425C9B37CA901B3;
address constant ALGEBRA_NFT_MANAGER = 0xAf588D87BaDE8654F26686D5502be8ceDbE8FFe0;
address constant ALGEBRA_INTERFACE_MULTICALL = 0xf94b8a5D6dBd8F4026Ae467fdDB96028F74b9B96;
address constant ALGEBRA_V3_MIGRATOR = 0x766682889b8A6070be210C2a821Ad671E3388ab3;
address constant ALGEBRA_LIMIT_FARMING = 0x62B46a9565C7ECEc4FE7Dd309174ac3B03AF44E2;
address constant ALGEBRA_ETERNAL_FARMING = 0xD8474356C6976E18275735531b22f3Aa872a8b3B;
address constant ALGEBRA_FARM_CENTER = 0x04e4A5A4E4D2A5a0fb48ECde0bbD5554652D254b;
