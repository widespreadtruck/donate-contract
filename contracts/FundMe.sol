// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();

/**@title A sample Funding Contract
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as a library
 */

contract FundMe {
  // type declarations
  using PriceConverter for uint256;

  // state variables
  mapping(address => uint256) public s_addressToAmountFunded;
  address[] public s_funders;

  address public immutable i_owner;
  uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

  AggregatorV3Interface public s_priceFeed;

  modifier onlyOwner() {
    if (msg.sender != i_owner) revert FundMe__NotOwner();
    _;
  }

  constructor(address priceFeedAddress) {
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  receive() external payable {
    fund();
  }

  fallback() external payable {
    fund();
  }

  /// @notice Funds the contract based on the ETH/USD price
  function fund() public payable {
    require(
      msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
      "You need to spend more ETH!"
    );
    s_addressToAmountFunded[msg.sender] += msg.value;
    s_funders.push(msg.sender);
  }

  function withdraw() public onlyOwner {
    for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
      address funder = s_funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call failed");
  }

  function cheaperWithdraw() public onlyOwner {
    address[] memory funders = s_funders;
    // mappings can't be in memory, sorry!
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);
    // payable(msg.sender).transfer(address(this).balance);
    (bool success, ) = i_owner.call{value: address(this).balance}("");
    require(success);
  }

  function getAddressToAmountFunded(
    address fundingAddress
  ) public view returns (uint256) {
    return s_addressToAmountFunded[fundingAddress];
  }

  function getVersion() public view returns (uint256) {
    return s_priceFeed.version();
  }

  function getFunder(uint256 index) public view returns (address) {
    return s_funders[index];
  }

  function getOwner() public view returns (address) {
    return i_owner;
  }

  function getPriceFeed() public view returns (AggregatorV3Interface) {
    return s_priceFeed;
  }
}
