pragma solidity =0.6.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // for the BonusToken
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./IUniswapV2Pair.sol";
import "./BonusToken.sol";

contract LiquidityMigrator {
    IUniswapV2Router02 public router;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public routerFork;
    IUniswapV2Pair public pairFork;
    BonusToken public bonusToken;
    address public admin;
    mapping(address => uint256) public unclaimedBalances ; // people who invested the LP token in the contract
    bool public migrationDone;

    constructor(
        address _router,
        address _pair,
        address _routerFork,
        address _pairFork,
        address _bonusToken
    ) public {
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Pair(_pair);
        routerFork = IUniswapV2Router02(_routerFork);
        pairFork = IUniswapV2Pair(_pairFork);
        bonusToken = BonusToken(_bonusToken);
        admin = msg.sender;
    }

    // Deposit LP token to the Liquidity contract
    function deposit(uint256 amount) external {
        require(migrationDone == false, "migration already done");
        // approve needs to be done before
        pair.transferFrom(msg.sender, address(this), amount);
        bonusToken.mint(msg.sender, amount);
        unclaimedBalances[msg.sender] += amount;
    }

    function migrate() external {
        require(msg.sender == admin, "only admin");
        require(migrationDone == false, "migration already done");
        IERC20 token0 = IERC20(pair.token0());
        IERC20 token1 = IERC20(pair.token1());
        uint256 totalBalance = pair.balanceOf(address(this)); // LP token balance of our SC

        // remove liquidity from Uniswap to our SC
        router.removeLiquidity(
            address(token0),
            address(token1),
            totalBalance, // Total balance of LP token we want to withdraw
            0,
            0,
            address(this), // recipient
            block.timestamp
        );

        // forward the underlying tokens to our uniswap fork
        uint256 token0Balance = token0.balanceOf(address(this));
        uint256 token1Balance = token1.balanceOf(address(this));
        token0.approve(address(routerFork), token0Balance);
        token1.approve(address(routerFork), token1Balance);
        routerFork.addLiquidity(
            address(token0),
            address(token1),
            token0Balance,
            token1Balance,
            token0Balance, // min amount
            token1Balance, // min amount
            address(this), // to this SC
            block.timestamp
        );

        migrationDone = true;
    }

    // Reedem LP tokens individually by each investor
    function claimLptokens() external {
        require(unclaimedBalances[msg.sender] >= 0, "no unclaimed balance");
        require(migrationDone == true, "migration bot done yet");
        uint256 amountToSend = unclaimedBalances[msg.sender];
        unclaimedBalances[msg.sender] = 0;
        pairFork.transfer(msg.sender, amountToSend);
    }
}
