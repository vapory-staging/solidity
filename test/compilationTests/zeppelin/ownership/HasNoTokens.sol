pragma solidity ^0.4.11;

import "./Ownable.sol";
import "../token/VRC20Basic.sol";

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.
 * Should tokens (any VRC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is Ownable {

 /**
  * @dev Reject all ERC23 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) external {
    throw;
  }

  /**
   * @dev Reclaim all VRC20Basic compatible tokens
   * @param tokenAddr address The address of the token contract
   */
  function reclaimToken(address tokenAddr) external onlyOwner {
    VRC20Basic tokenInst = VRC20Basic(tokenAddr);
    uint256 balance = tokenInst.balanceOf(this);
    tokenInst.transfer(owner, balance);
  }
}
