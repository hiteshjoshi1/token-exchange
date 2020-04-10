pragma solidity ^0.5.0;

// Import base Initializable contract
import "@openzeppelin/upgrades/contracts/Initializable.sol";

// Import the IERC20 interface and and SafeMath library
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/lifecycle/Pausable.sol";


contract TokenExchange is Initializable, Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Contract state: exchange rate and token
    uint256 public rate;
    IERC20 public token;

    // Initializer function (replaces constructor) -10, 0xabc
    function initialize(uint256 _rate, IERC20 _token) public initializer {
        rate = _rate;
        token = _token;
    }

    // this is some admin on DeepAuto who has authorization of let say 10 USDC
    function depositStableCoin(
        address _stableCoinAddress,
        address _investor,
        uint256 _investmentAmount
    ) public {
        IERC20 stableCoin = IERC20(_stableCoinAddress);
        //Take stable coins
        stableCoin.safeTransferFrom(
            _investor,
            address(this),
            _investmentAmount
        );

        // send some tokens back 10,10 = 100
        uint256 tokensInternal = _investmentAmount.mul(rate);
        token.transfer(_investor, tokensInternal);
    }
}
