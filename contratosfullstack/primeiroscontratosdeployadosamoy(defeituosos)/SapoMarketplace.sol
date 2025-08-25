// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SapoItems.sol";

contract SapoMarketplace is Ownable, Pausable {
    IERC20 public token;
    SapoItems public items;

    struct Listing {
        address seller;
        uint256 price;     // price per item (in SapoToken, wei)
        uint256 quantity;
    }

    // itemId => Listing
    mapping(uint256 => Listing) public listings;

    event ItemListed(
        address indexed seller,
        uint256 indexed id,
        uint256 quantity,
        uint256 price
    );
    event ItemPurchased(
        address indexed buyer,
        uint256 indexed id,
        uint256 quantity,
        uint256 totalCost
    );

    constructor(address token_, address items_) Ownable(msg.sender) {
        require(token_ != address(0), "Token zero address");
        require(items_ != address(0), "Items zero address");
        token = IERC20(token_);
        items = SapoItems(items_);
    }

    function listItem(
        uint256 id,
        uint256 quantity,
        uint256 price
    ) external whenNotPaused {
        require(quantity > 0, "Quantity zero");
        require(price > 0, "Price zero");

        // transfere itens do seller para o marketplace
        items.safeTransferFrom(msg.sender, address(this), id, quantity, "");

        listings[id] = Listing(msg.sender, price, quantity);
        emit ItemListed(msg.sender, id, quantity, price);
    }

    function buyItem(uint256 id, uint256 quantity) external whenNotPaused {
        Listing storage lst = listings[id];
        require(quantity > 0 && quantity <= lst.quantity, "Invalid quantity");

        uint256 totalCost = lst.price * quantity;

        // transfere SapoToken do buyer para o seller
        require(
            token.transferFrom(msg.sender, lst.seller, totalCost),
            "Payment failed"
        );

        // transfere itens do marketplace para o buyer
        items.safeTransferFrom(address(this), msg.sender, id, quantity, "");

        lst.quantity -= quantity;
        emit ItemPurchased(msg.sender, id, quantity, totalCost);
    }

    function pauseMarketplace() external onlyOwner {
        _pause();
    }

    function unpauseMarketplace() external onlyOwner {
        _unpause();
    }
}
