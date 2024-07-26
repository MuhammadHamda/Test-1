// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlumeToken is ERC20, Ownable {
    constructor() ERC20("Blume Token", "BLS") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

contract StakedBlumeToken is ERC20, Ownable {
    address public stakingContract;

    constructor() ERC20("Staked Blume Token", "stBLS") Ownable(msg.sender) {
        stakingContract = msg.sender; // Initially set to deployer's address
    }

    function setStakingContract(address _stakingContract) external onlyOwner {
        stakingContract = _stakingContract;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == stakingContract, "Only staking contract can mint");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(msg.sender == stakingContract, "Only staking contract can burn");
        _burn(from, amount);
    }
}

contract BlumeLiquidStaking is Ownable {
    BlumeToken public bls;
    StakedBlumeToken public stBls;

    constructor(address _bls, address _stBls) Ownable(msg.sender) {
        bls = BlumeToken(_bls);
        stBls = StakedBlumeToken(_stBls);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake zero tokens");
        bls.transferFrom(msg.sender, address(this), amount);
        stBls.mint(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Cannot unstake zero tokens");
        stBls.burn(msg.sender, amount);
        bls.transfer(msg.sender, amount);
    }
}
