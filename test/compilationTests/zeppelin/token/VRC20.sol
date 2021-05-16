pragma solidity ^0.4.11;


import './VRC20Basic.sol';


/**
 * @title VRC20 interface
 * @dev see https://github.com/vaporyco/EIPs/issues/20
 */
contract VRC20 is VRC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value);
  function approve(address spender, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
