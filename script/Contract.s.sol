// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Script, console2 } from "forge-std/Script.sol";
import { Contract } from "../src/Contract.sol";

interface ImmutableCreate2Factory {
  function create2(bytes32 salt, bytes calldata initializationCode)
    external
    payable
    returns (address deploymentAddress);
}

contract Deploy is Script {
  Contract public cntrct;
  bytes32 public SALT = bytes32(abi.encode("lets add some salt to these eggs"));

  // default values
  bool internal _verbose = true;
  // init other variables

  /// @dev Override default values, if desired
  function prepare(bool verbose) public {
    _verbose = verbose;
    // set other variables
  }

  /// @dev Set up the deployer via their private key from the environment
  function _deployer() internal returns (address) {
    uint256 privKey = vm.envUint("PRIVATE_KEY");
    return vm.rememberKey(privKey);
  }

  function _log(string memory prefix) internal view {
    if (_verbose) {
      console2.log(string.concat(prefix, "Contract:"), address(cntrct));
    }
  }

  /// @dev Deploy the contract to a deterministic address via forge's create2 deployer factory.
  function run() public virtual returns (Contract) {
    vm.startBroadcast(_deployer());

    /**
     * @dev Deploy the contract to a deterministic address via forge's create2 deployer factory, which is at this
     * address on all chains: `0x4e59b44847b379578588920cA78FbF26c0B4956C`.
     * The resulting deployment address is determined by only two factors:
     *    1. The bytecode hash of the contract to deploy. Setting `bytecode_hash` to "none" in foundry.toml ensures that
     *       never differs regardless of where its being compiled
     *    2. The provided salt, `SALT`
     */
    cntrct = new Contract{ salt: SALT }( /* insert constructor args here */ );

    vm.stopBroadcast();

    _log("");

    return cntrct;
  }
}

/// @dev Deploy pre-compiled ir-optimized bytecode to a non-deterministic address
contract DeployPrecompiled is Deploy {
  /// @dev Update SALT and default values in Deploy contract

  function run() public override returns (Contract) {
    vm.startBroadcast(_deployer());

    bytes memory args = abi.encode( /* insert constructor args here */ );

    /// @dev Load and deploy pre-compiled ir-optimized bytecode.
    cntrct = Contract(deployCode("optimized-out/Contract.sol/Contract.json", args));

    vm.stopBroadcast();

    _log("Precompiled ");

    return cntrct;
  }
}

/* FORGE CLI COMMANDS

## A. Simulate the deployment locally
forge script script/Deploy.s.sol -f mainnet

## B. Deploy to real network and verify on etherscan
forge script script/Deploy.s.sol -f mainnet --broadcast --verify

## C. Fix verification issues (replace values in curly braces with the actual values)
forge verify-contract --chain-id 1 --num-of-optimizations 1000000 --watch --constructor-args $(cast abi-encode \
 "constructor({args})" "{arg1}" "{arg2}" "{argN}" ) \ 
 --compiler-version v0.8.19 {deploymentAddress} \
 src/{Counter}.sol:{Counter} --etherscan-api-key $ETHERSCAN_KEY

## D. To verify ir-optimized contracts on etherscan...
  1. Run (C) with the following additional flag: `--show-standard-json-input > etherscan.json`
  2. Patch `etherscan.json`: `"optimizer":{"enabled":true,"runs":100}` =>
`"optimizer":{"enabled":true,"runs":100},"viaIR":true`
  3. Upload the patched `etherscan.json` to etherscan manually

  See this github issue for more: https://github.com/foundry-rs/foundry/issues/3507#issuecomment-1465382107

*/
