// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EthereumSmartWallet {
    address public owner;
    mapping(address => bool) public authorizedAddresses;
    mapping(address => string) public socialMediaAccounts;
    mapping(address => bytes32) private passcodes;

    event WalletAccessed(address user, string method);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function authorizeAddress(address _address) public onlyOwner {
        authorizedAddresses[_address] = true;
    }

    function linkSocialMedia(address _address, string memory _socialMedia) public {
        require(authorizedAddresses[_address], "Not authorized");
        socialMediaAccounts[_address] = _socialMedia;
    }

    function setPasscode(address _address, string memory _passcode) public {
        require(authorizedAddresses[_address], "Not authorized");
        passcodes[_address] = keccak256(abi.encodePacked(_passcode));
    }

    function accessWalletBySocialMedia(address _address, string memory _socialMedia) public {
        require(keccak256(abi.encodePacked(socialMediaAccounts[_address])) == keccak256(abi.encodePacked(_socialMedia)), "Invalid social media account");
        emit WalletAccessed(_address, "Social Media");
    }

    function accessWalletByBiometric(address _address) public {
        require(authorizedAddresses[_address], "Not authorized");
        emit WalletAccessed(_address, "Biometric");
    }

    function accessWalletByPasscode(address _address, string memory _passcode) public {
        require(passcodes[_address] == keccak256(abi.encodePacked(_passcode)), "Invalid passcode");
        emit WalletAccessed(_address, "Passcode");
    }
}
