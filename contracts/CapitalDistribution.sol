//This contract is slightly modified from https://github.com/gitcoinco/BulkTransactions/edit/master/contracts/BulkCheckout.sol
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

/**
 * @dev We use ABIEncoderV2 to enable encoding/decoding of the array of structs. The pragma
 * is required, but ABIEncoderV2 is no longer considered experimental as of Solidity 0.6.0
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CapitalDistribution is Ownable, Pausable, ReentrancyGuard {
    using Address for address payable;
    using SafeMath for uint256;
    /**
     * @notice Placeholder token address for ETH distributions. This address is used in various other
     * projects as a stand-in for ETH
     */
    address constant ETH_TOKEN_PLACHOLDER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @notice Required parameters for each Distribution
     */
    struct Distribution {
        uint256 amount; // amount of tokens to distribute
        address payable dest; // grant address
    }

    /**
     * @dev Emitted on each Distribution
     */
    event DistributionSent(
        address indexed token,
        uint256 indexed amount,
        address dest,
        address indexed distributor
    );

    /**
     * @dev Emitted when a token or ETH is withdrawn from the contract
     */
    event TokenWithdrawn(
        address indexed token,
        uint256 indexed amount,
        address indexed dest
    );

    /**
     * @notice capaital distributions
     * @dev We assume all token approvals were already executed
     *@param _token address tokens in which capital distribution is being done
     * @param _distributions Array of Distribution structs
     */
    function distribute(address _token, Distribution[] calldata _distributions)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        // We track total ETH distributions to ensure msg.value is exactly correct
        uint256 _ethdistributionTotal = 0;

        for (uint256 i = 0; i < _distributions.length; i++) {
            emit DistributionSent(
                _token,
                _distributions[i].amount,
                _distributions[i].dest,
                msg.sender
            );
            if (_token != ETH_TOKEN_PLACHOLDER) {
                // Token Distribution
                // This method throws on failure, so there is no return value to check
                SafeERC20.safeTransferFrom(
                    IERC20(_token),
                    msg.sender,
                    _distributions[i].dest,
                    _distributions[i].amount
                );
            } else {
                // ETH Distribution
                // See comments in Address.sol for why we use sendValue over transer
                _distributions[i].dest.sendValue(_distributions[i].amount);
                _ethdistributionTotal = _ethdistributionTotal.add(
                    _distributions[i].amount
                );
            }
        }

        // Revert if the wrong amount of ETH was sent
        require(
            msg.value == _ethdistributionTotal,
            "CapitalDistribution: Too much ETH sent"
        );
    }

    /**
     * @notice Transfers all tokens of the input adress to the recipient. This is
     * useful tokens are accidentally sent to this contrasct
     * @param _tokenAddress address of token to send
     * @param _dest destination address to send tokens to
     */
    function withdrawToken(address _tokenAddress, address _dest)
        external
        onlyOwner
    {
        uint256 _balance = IERC20(_tokenAddress).balanceOf(address(this));
        emit TokenWithdrawn(_tokenAddress, _balance, _dest);
        SafeERC20.safeTransfer(IERC20(_tokenAddress), _dest, _balance);
    }

    /**
     * @notice Transfers all Ether to the specified address
     * @param _dest destination address to send ETH to
     */
    function withdrawEther(address payable _dest) external onlyOwner {
        uint256 _balance = address(this).balance;
        emit TokenWithdrawn(ETH_TOKEN_PLACHOLDER, _balance, _dest);
        _dest.sendValue(_balance);
    }

    /**
     * @notice Pause contract
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Unpause contract
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }
}
