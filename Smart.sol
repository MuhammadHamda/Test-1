// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SmartWallet {
    address public owner;
    mapping(address => bool) public authorizedUsers;
    mapping(bytes32 => bool) public usedOTPs;
    mapping(address => bytes32) public passcodes;
    mapping(address => bool) public biometricVerified;

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    event OTPUsed(bytes32 otpHash);
    event PasscodeSet(address indexed user, bytes32 passcodeHash);
    event AuthorizedUser(address indexed user);
    event DeauthorizedUser(address indexed user);
    event BiometricVerified(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    modifier onlyAuthorized() {
        require(authorizedUsers[msg.sender], "Not an authorized user");
        _;
    }
    modifier onlyBiometricVerified() {
        require(biometricVerified[msg.sender], "Biometric authentication not verified");
        _;
    }
    constructor() {
        owner = msg.sender;
        authorizedUsers[owner] = true;
    }
    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint256 amount, bytes32 otpHash, bytes32 passcodeHash) 
        external 
        onlyAuthorized 
        onlyBiometricVerified 
    {
        require(address(this).balance >= amount, "Insufficient balance");
        require(!usedOTPs[otpHash], "OTP already used");
        require(passcodes[msg.sender] == passcodeHash, "Invalid passcode");
        usedOTPs[otpHash] = true;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
        emit OTPUsed(otpHash);
    }
     function authorizeUser(address user) external onlyOwner {
        authorizedUsers[user] = true;
        emit AuthorizedUser(user);
    }
    function deauthorizeUser(address user) external onlyOwner {
        authorizedUsers[user] = false;
        emit DeauthorizedUser(user);
    }
    function setPasscode(bytes32 passcodeHash) external {
        passcodes[msg.sender] = passcodeHash;
        emit PasscodeSet(msg.sender, passcodeHash);
    }
    function verifyOTP(bytes32 otpHash) external onlyAuthorized {
        require(!usedOTPs[otpHash], "OTP already used");
        usedOTPs[otpHash] = true;
        emit OTPUsed(otpHash);
    }
    function verifyBiometric() external onlyAuthorized {
        biometricVerified[msg.sender] = true;
        emit BiometricVerified(msg.sender);
    }
    function hashString(string memory input) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(input));
    }
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
