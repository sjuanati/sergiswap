// SPDX-License-Identifier: MIT
// Info:  Bonus token: give bonus to anyone who stake the LP token in our migration SC
pragma solidity =0.6.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract BonusToken is ERC20 {
    address public admin;
    address public liquidator;

    constructor() ERC20('Bonus Token', 'BTK') public {
        admin = msg.sender;
    }

    function setLiquidator(address _liquidator) external {
        require(msg.sender == admin, 'only admin');
        liquidator = _liquidator;
    }

    // Mint bonus token every time someone sends an LP token (Give bonus to investor)
    function mint(address to, uint amount) external {
        require(msg.sender == liquidator, 'only liquidator');
        _mint(to, amount);
    }
}