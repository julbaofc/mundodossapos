// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SapoItems is ERC1155, Ownable, Pausable {
    IERC20 public token;
    uint256 public feeBP;
    address public feeRecipient;

    constructor(
        uint256 feeBasisPoints_,
        address feeRecipient_
    )
        ERC1155("")          // URI padrão vazio
        Ownable(msg.sender)  // define o deployer como owner
    {
        token = IERC20(0x820bcDc927f5cC9b858b563fed254388139B1F13);
        feeBP = feeBasisPoints_;
        feeRecipient = feeRecipient_;
    }

    /// @notice Atualiza o URI padrão (sem id)
    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    /// @notice Mint de um item, cobrando fee em SapoToken
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external whenNotPaused {
        uint256 cost = amount * feeBP;
        require(
            token.transferFrom(msg.sender, feeRecipient, cost),
            "Fee transfer failed"
        );
        _mint(to, id, amount, data);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
