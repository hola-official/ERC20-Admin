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

contract ERC20Token is AccessControl {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address _to, uint256 _amount) external onlyMinter {
        require(_to != address(0), "Cannot mint to zero address");
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        emit TokensMinted(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }

    function burn(uint256 _amount) external {
        require(
            balanceOf[msg.sender] >= _amount,
            "Insufficient balance to burn"
        );
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        emit TokensBurned(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");

        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(
        address _spender,
        uint256 _amount
    ) external returns (bool) {
        require(_spender != address(0), "Cannot approve zero address");

        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool) {
        require(
            _from != address(0) && _to != address(0),
            "Cannot transfer to/from zero address"
        );
        require(balanceOf[_from] >= _amount, "Insufficient balance");
        require(
            allowance[_from][msg.sender] >= _amount,
            "Insufficient allowance"
        );

        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }
}
