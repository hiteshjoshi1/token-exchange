pragma solidity ^0.5.0;

// Import base Initializable contract
import "@openzeppelin/upgrades/contracts/Initializable.sol";

// Import the IERC20 interface and and SafeMath library
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/StandaloneERC20.sol";


contract MyToken is StandaloneERC20 {}
