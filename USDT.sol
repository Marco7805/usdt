// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ITRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract USDT is ITRC20 {
    string public constant name = "Tether USD";
    string public constant symbol = "USDT";
    uint8 public constant decimals = 6;
    uint256 private _totalSupply;
    address private immutable _owner;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event TokensBurned(uint256 amount);

    constructor(uint256 initialSupply) {
        _owner = msg.sender;
        _totalSupply = initialSupply * (10 ** uint256(decimals));
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Solo l'amministratore puo eseguire questa operazione");
        _;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "Destinatario non valido");
        require(_balances[msg.sender] >= amount, "Saldo insufficiente");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "Spender non valido");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0) && recipient != address(0), "Indirizzo non valido");
        require(_balances[sender] >= amount, "Saldo insufficiente");
        require(_allowances[sender][msg.sender] >= amount, "Spesa non autorizzata");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) external onlyOwner {
        require(amount > 0, "Devi bruciare almeno 1 token");
        require(_balances[_owner] >= amount, "Token insufficienti per la distruzione");
        _balances[_owner] -= amount;
        _totalSupply -= amount;
        emit TokensBurned(amount);
    }
}

