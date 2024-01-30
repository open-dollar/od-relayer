<p align="center">
<svg width="60" height="60" viewBox="0 0 74 73" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M37.2501 0.559999C30.143 0.558021 23.1949 2.66387 17.2847 6.61115C11.3745 10.5584 6.76772 16.1698 4.04702 22.7355C1.32633 29.3013 0.613915 36.5265 1.99996 43.4971C3.38601 50.4678 6.80826 56.8709 11.8338 61.8964C16.8593 66.9219 23.2623 70.3441 30.2329 71.7301C37.2036 73.1161 44.4288 72.4038 50.9945 69.6831C57.5603 66.9624 63.1717 62.3556 67.119 56.4454C71.0663 50.5352 73.172 43.5871 73.1701 36.48C73.1674 26.9542 69.3822 17.8194 62.6464 11.0837C55.9107 4.34795 46.7758 0.56265 37.2501 0.559999ZM37.2501 63.07C31.9911 63.07 26.8502 61.5106 22.4775 58.5888C18.1048 55.6671 14.6966 51.5143 12.6841 46.6556C10.6716 41.7969 10.145 36.4505 11.171 31.2925C12.197 26.1346 14.7295 21.3967 18.4481 17.678C22.1668 13.9594 26.9047 11.4269 32.0626 10.4009C37.2206 9.37496 42.5669 9.90153 47.4256 11.9141C52.2843 13.9266 56.4371 17.3347 59.3588 21.7074C62.2806 26.0801 63.8401 31.221 63.8401 36.48C63.8414 39.9722 63.1545 43.4305 61.8187 46.6571C60.4829 49.8837 58.5243 52.8155 56.055 55.2849C53.5856 57.7543 50.6538 59.7128 47.4272 61.0486C44.2006 62.3845 40.7423 63.0713 37.2501 63.07Z" fill="#1A74EC"/>
    <path d="M37.2401 57.18C48.6723 57.18 57.9401 47.9123 57.9401 36.48C57.9401 25.0477 48.6723 15.78 37.2401 15.78C25.8078 15.78 16.54 25.0477 16.54 36.48C16.54 47.9123 25.8078 57.18 37.2401 57.18Z" fill="#1A74EC"/>
    <path d="M10.66 36.48C10.6587 39.9722 11.3456 43.4305 12.6814 46.6571C14.0172 49.8837 15.9758 52.8155 18.4451 55.2849C20.9145 57.7543 23.8462 59.7128 27.0729 61.0486C30.2995 62.3844 33.7578 63.0713 37.25 63.07V72.41C32.4818 72.4895 27.7455 71.6191 23.3172 69.8494C18.8889 68.0797 14.8572 65.4462 11.4571 62.1024C8.057 58.7586 5.35656 54.7713 3.51324 50.3732C1.66993 45.975 0.720581 41.2538 0.720581 36.485C0.720581 31.7161 1.66993 26.995 3.51324 22.5969C5.35656 18.1987 8.057 14.2114 11.4571 10.8676C14.8572 7.52378 18.8889 4.89023 23.3172 3.12054C27.7455 1.35085 32.4818 0.480438 37.25 0.559993V9.89001C33.7578 9.8887 30.2995 10.5756 27.0729 11.9114C23.8462 13.2472 20.9145 15.2057 18.4451 17.6751C15.9758 20.1445 14.0172 23.0763 12.6814 26.3029C11.3456 29.5296 10.6587 32.9878 10.66 36.48Z" fill="#6396FF"/>
    <path d="M37.24 15.78V57.18C42.73 57.18 47.9951 54.9991 51.8771 51.1171C55.7591 47.2351 57.94 41.97 57.94 36.48C57.94 30.99 55.7591 25.7249 51.8771 21.8429C47.9951 17.9609 42.73 15.78 37.24 15.78Z" fill="#6396FF"/>
</svg>
</p>
<h1 align="center">
  Open Dollar Relayer
</h1>

This repository contains the smart contracts for the relayers used in Open Dollar.

# Resources

**Documentation**

- Technical Contracts docs: https://contracts.opendollar.com
- Protocol Docs: https://docs.opendollar.com

**Contract Deployments**

Addresses for testnet can be found in the app: https://app.dev.opendollar.com/stats

# Usage

## Selecting a Foundry profile

When running `forge`, you can specify the profile to use using the FOUNDRY_PROFILE environment variable. e.g. `export FOUNDRY_PROFILE=test && forge test`. Alternatively, you can add `FOUNDRY_PROFILE=test` to `.env` and run `source .env`.

# Development

## Anvil

Start Anvil:

```bash
anvil
```

Next, copy the private key from anvil terminal output into your `.env`

```
ANVIL_RPC=http://127.0.0.1:8545
ANVIL_ONE=0x....
```

Deploy the contracts locally:

```bash
yarn deploy:anvil
```

You now have a local anvil test environment with a locally deployed and instantiated version of the Open Dollar Protocol.

> NOTE: You may need to manually verify that all required addresses were updated in `AnvilContracts.t.sol`. The script `parseAnvilDeployments.js` is not perfect.

# Tests

## Coverage Reports

Coverage testing is performed using lcov and a local Anvil fork of the contracts. First install [lcov for mac/linx](https://formulae.brew.sh/formula/lcov).

1. Start Anvil using the instructions above.

2. To generate a report, run the command:

```bash
yarn test:coverage
```

3. Open `coverage-report/index.html` to view the report.
