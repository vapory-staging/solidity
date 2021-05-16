pragma solidity ^0.4.11;


/**
 * @title VRC20Basic
 * @dev Simpler version of VRC20 interface
 * @dev see https://github.com/vaporyco/EIPs/issues/20
 */
contract VRC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
