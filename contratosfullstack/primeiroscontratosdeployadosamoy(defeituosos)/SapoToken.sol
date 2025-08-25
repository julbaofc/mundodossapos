// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SapoToken (ERC-20 do Mundo dos Sapos)
 * @notice
 *  - Cap fixo (supply máximo)
 *  - Mint restrito ao owner (carteira Tesouro)
 *  - Burn opcional pelos usuários
 *  - Pausable
 *  - Permit (EIP-2612)
 */

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract SapoToken is
    ERC20,
    ERC20Burnable,
    ERC20Capped,
    ERC20Permit,
    Ownable,
    Pausable
{
    uint8 private _customDecimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 cap_,          // Ex.: 1_000_000_000 ether
        uint8 decimals_,       // Ex.: 18
        address treasuryOwner, // Sua carteira Tesouro
        uint256 initialMint    // Quanto quer mintar no deploy
    )
        ERC20(name_, symbol_)
        ERC20Capped(cap_)
        ERC20Permit(name_)
        Ownable(treasuryOwner)
    {
        _customDecimals = decimals_;

        if (initialMint > 0) {
            require(initialMint <= cap_, "Initial mint exceeds cap");
            _mint(treasuryOwner, initialMint);
        }
    }

    function decimals() public view override returns (uint8) {
        return _customDecimals;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Hook de pausa para ERC-20 + ERC-20Capped (v5.x)
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Capped)
    {
        if (from != address(0) && to != address(0)) {
            require(!paused(), "SapoToken: transfers paused");
        }
        super._update(from, to, value);
    }

    receive() external payable {
        revert("SapoToken: no native funds");
    }

    fallback() external payable {
        revert("SapoToken: no native funds");
    }
}
