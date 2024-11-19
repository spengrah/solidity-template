// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { Contract } from "../src/Contract.sol";
import { Deploy, DeployPrecompiled } from "../script/Contract.s.sol";

contract ContractTest is Test {
  /// @dev Inherit from DeployPrecompiled instead of Deploy if working with pre-compiled contracts

  Contract public cntrct;
  uint256 public constant TEST_SALT_NONCE = 1;
  bytes32 public constant TEST_SALT = bytes32(abi.encode(TEST_SALT_NONCE));

  uint256 public fork;
  uint256 public BLOCK_NUMBER;

  function _deploy() internal returns (Contract) {
    Deploy deployer = new Deploy();
    deployer.prepare(false);
    return deployer.run();
  }

  function setUp() public virtual {
    // OPTIONAL: create and activate a fork, at BLOCK_NUMBER
    // fork = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

    // deploy the contract
    cntrct = _deploy();
  }
}

contract UnitTests is ContractTest {
  function test_empty() public view { }
}
