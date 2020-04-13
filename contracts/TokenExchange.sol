pragma solidity ^0.5.0;

// Import base Initializable contract
import "@openzeppelin/upgrades/contracts/Initializable.sol";

// Import the IERC20 interface and and SafeMath library
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/lifecycle/Pausable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/StandaloneERC20.sol";

import "./MyToken.sol";


contract TokenExchange is Initializable, Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event DisableToken(uint256 indexed tokenId);
    event EnableToken(uint256 indexed tokenId);

    event TokenAdded(
        uint256 indexed platformTokenId,
        address indexed platformToken,
        address indexed stableCoinAddress
    );

    mapping(uint256 => address) public tokenIdToStableCoinAddressMap;
    mapping(uint256 => address) public tokenIdToPlatformCoinAddressMap;
    mapping(address => uint256) public stableCoinAddressToTokenIdMap;
    mapping(address => uint256) public platformCoinAddressToTokenIdMap;

    mapping(uint256 => bool) public disabledTokenIdMap;

    uint256[] public platformTokenIds;

    modifier whenNotPaused() {
        require(!paused(), "ECOSYSTEM_PAUSED");
        _;
    }

    modifier whenPaused() {
        require(paused(), "ECOSYSTEM_NOT_PAUSED");
        _;
    }

    modifier checkTokenExists(uint256 tokenId) {
        require(
            tokenIdToPlatformCoinAddressMap[tokenId] != address(0x0),
            "TOKEN_DOES_NOT_EXIST"
        );
        _;
    }

    function initialize() public initializer {
        Ownable.initialize(msg.sender);
        Pausable.initialize(msg.sender);
    }

    /**
     * @dev Adds a new stable coin to the exchange and mints corresponding platform tokens
     * @notice Admin function to add a new stable coin market
     */
    function addTokenToExchange(
        address stableCoinAddress,
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 mintAmount
    ) public onlyOwner whenNotPaused {
        require(
            stableCoinAddressToTokenIdMap[stableCoinAddress] == 0,
            "TOKEN_ALREADY_EXISTS"
        );

        address[] memory minterArray = new address[](1);
        minterArray[0] = msg.sender;
        address[] memory pauserArray = new address[](1);
        pauserArray[0] = msg.sender;

        StandaloneERC20 platformToken = new StandaloneERC20();

        // Mint platform tokens and assign them to the exchange contract
        platformToken.initialize(
            name,
            symbol,
            decimals,
            mintAmount,
            address(this),
            minterArray,
            pauserArray
        );
        _addToken(address(platformToken), stableCoinAddress);
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

        uint256 tokenId = stableCoinAddressToTokenIdMap[_stableCoinAddress];
        address underlyingTokenAddrs = tokenIdToPlatformCoinAddressMap[tokenId];
        IERC20 underlyingCoin = IERC20(underlyingTokenAddrs);

        // hardcoded Interest rate of 1
        uint256 tokensInternal = _investmentAmount.mul(1);
        underlyingCoin.transfer(_investor, tokensInternal);
    }

    function enableTokenMarket(uint256 platformTokenId)
        public
        checkTokenExists(platformTokenId)
        whenNotPaused
        onlyOwner
    {
        require(disabledTokenIdMap[platformTokenId], "MARKET_ALREADY_ENABLED");
        disabledTokenIdMap[platformTokenId] = false;
        emit EnableToken(platformTokenId);
    }

    function disableTokenMarket(uint256 platformTokenId)
        public
        checkTokenExists(platformTokenId)
        whenNotPaused
        onlyOwner
    {
        require(
            !disabledTokenIdMap[platformTokenId],
            "MARKET_ALREADY_DISABLED"
        );
        disabledTokenIdMap[platformTokenId] = true;
        emit DisableToken(platformTokenId);
    }

    function _addToken(address platformToken, address stableCoinAddress)
        private
    {
        // Start the IDs at 1. Zero is reserved for the empty case when it doesn't exist.
        uint256 platformTokenId = platformTokenIds.length + 1;

        // Update the maps
        tokenIdToPlatformCoinAddressMap[platformTokenId] = platformToken;
        platformCoinAddressToTokenIdMap[platformToken] = platformTokenId;
        stableCoinAddressToTokenIdMap[stableCoinAddress] = platformTokenId;
        tokenIdToStableCoinAddressMap[platformTokenId] = stableCoinAddress;

        disabledTokenIdMap[platformTokenId] = false;
        platformTokenIds.push(platformTokenId);

        emit TokenAdded(platformTokenId, platformToken, stableCoinAddress);
    }

    function getPlatformToken(address _stableCoinAddress)
        public
        view
        returns (address)
    {
        uint256 tokenId = stableCoinAddressToTokenIdMap[_stableCoinAddress];


            address underlyingTokenAddress
         = tokenIdToPlatformCoinAddressMap[tokenId];
        return underlyingTokenAddress;
    }
}
