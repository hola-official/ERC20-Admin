// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    address public admin;
    mapping(address => bool) public authorizedMinters;

    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyMinter() {
        require(
            authorizedMinters[msg.sender] || msg.sender == admin,
            "Only minters can call this function"
        );
        _;
    }

    function changeAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "New admin cannot be zero address");
        emit AdminChanged(admin, _newAdmin);
        admin = _newAdmin;
    }

    function addMinter(address _minter) external onlyAdmin {
        require(_minter != address(0), "Minter cannot be zero address");
        require(!authorizedMinters[_minter], "Address is already a minter");
        authorizedMinters[_minter] = true;
        emit MinterAdded(_minter);
    }

    function removeMinter(address _minter) external onlyAdmin {
        require(authorizedMinters[_minter], "Address is not a minter");
        authorizedMinters[_minter] = false;
        emit MinterRemoved(_minter);
    }
}
