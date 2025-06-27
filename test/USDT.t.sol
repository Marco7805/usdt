// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

/// @dev Interfaccia ERC-20 minimale
interface IERC20 {
    function symbol()      external view returns (string memory);
    function name()        external view returns (string memory);
    function decimals()    external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

/// @dev Mock “USDT-like”
contract MockUSDT is IERC20 {
    string public override symbol   = "USDT";
    string public override name     = "Tether USD";
    uint8  public override decimals = 6;
    uint256 public override totalSupply;
    mapping(address => uint256) private _balances;

    /// @dev Mint per popolare i bilanci nei test
    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        totalSupply   += amount;
    }

    function balanceOf(address who) external view override returns (uint256) {
        return _balances[who];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount, "MockUSDT: insufficient");
        _balances[msg.sender] -= amount;
        _balances[to]           += amount;
        return true;
    }
}

/// @dev Suite di test per MockUSDT
contract USDTTest is Test {
    MockUSDT public usdt;
    address   public whale;
    address   public recipient;

    function setUp() public {
        // Deploy del mock
        usdt      = new MockUSDT();
        // Creazione di due account di prova
        whale     = vm.addr(1);
        recipient = vm.addr(2);
        // Popoliamo il whale con 10 USDT (10 * 1e6 unità base)
        usdt.mint(whale, 10 * 1e6);
    }

    function testMetadata() public view {
        assertEq(usdt.symbol(),      "USDT");
        assertEq(usdt.name(),        "Tether USD");
        assertEq(usdt.decimals(),    6);
        assertEq(usdt.totalSupply(), 10 * 1e6);
    }

    function testTransferViaImpersonation() public {
        // Recipient parte da zero
        assertEq(usdt.balanceOf(recipient), 0);

        // Impersoniamo il whale e trasferiamo 1 USDT
        vm.startPrank(whale);
        bool ok = usdt.transfer(recipient, 1e6);
        vm.stopPrank();
        assertTrue(ok);

        // Verifichiamo saldi
        assertEq(usdt.balanceOf(recipient), 1e6);
        assertEq(usdt.balanceOf(whale),     9 * 1e6);
    }
}

