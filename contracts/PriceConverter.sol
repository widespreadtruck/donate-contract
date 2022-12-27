// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
  function getPrice(
    AggregatorV3Interface priceFeed
  ) internal view returns (uint256) {
    // get price dynamically instead of hardcoding it in
    // AggregatorV3Interface priceFeed = AggregatorV3Interface(
    //     0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
    // );
    (, int256 answer, , , ) = priceFeed.latestRoundData();
    return uint256(answer * 1e10);
  }

  function getConversionRate(
    uint256 ethAmount,
    AggregatorV3Interface priceFeed
  ) internal view returns (uint256) {
    uint256 ethPrice = getPrice(priceFeed);
    uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
    return ethAmountInUsd;
  }
}
