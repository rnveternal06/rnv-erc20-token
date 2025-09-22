// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RNVETERNAL ERC20 Token (RNV COIN)
 * @dev ERC20 Token dengan auto-tax ke wallet dev + watermark (OpenZeppelin v5.x compatible)
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RNVCOIN is ERC20, Ownable {

    string private constant _WATERMARK = "BY RNVETERNAL";
    address public devWallet;
    uint256 public taxPercentage = 2; // default 2%

    event TaxUpdated(uint256 newTax);
    event DevWalletUpdated(address newWallet);

    constructor(address _devWallet) ERC20("RNV COIN", "RN") Ownable(msg.sender) {
        require(_devWallet != address(0), "Dev wallet invalid");
        devWallet = _devWallet;
        _mint(msg.sender, 21000000 * 10 ** decimals());
    }

    /**
     * @dev Hook OpenZeppelin v5 untuk custom transfer (mengganti _transfer)
     */
    function _update(address from, address to, uint256 value) internal override {
        if (
            taxPercentage > 0 &&
            from != address(0) &&  // exclude mint
            to != address(0) &&    // exclude burn
            from != owner() &&
            to != owner()
        ) {
            uint256 taxAmount = (value * taxPercentage) / 100;
            uint256 sendAmount = value - taxAmount;

            super._update(from, devWallet, taxAmount);
            super._update(from, to, sendAmount);
        } else {
            super._update(from, to, value);
        }
    }

    /**
     * @notice Ubah persentase tax (max 10%)
     */
    function setTax(uint256 newTax) external onlyOwner {
        require(newTax <= 10, "Tax max 10%");
        taxPercentage = newTax;
        emit TaxUpdated(newTax);
    }

    /**
     * @notice Ubah alamat wallet dev
     */
    function setDevWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid address");
        devWallet = newWallet;
        emit DevWalletUpdated(newWallet);
    }

    /**
     * @notice Burn token dari wallet sendiri
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Cek watermark untuk verifikasi
     */
    function watermark() external pure returns (string memory) {
        return _WATERMARK;
    }
}
