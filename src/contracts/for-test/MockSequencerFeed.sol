// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

contract MockSequencerFeed {
  uint256 internal constant _ARBITRARY_DATA = 1;
  uint256 public startedAt;
  int256 public answer; // 0 = online, 1 = offline

  constructor() {
    startedAt = block.timestamp;
  }

  function switchSequencer() external {
    if (answer == 0) answer = 1;
    else answer = 0;
  }

  function resetStartTime() external {
    startedAt = block.timestamp;
  }

  function latestRoundData()
    external
    view
    returns (uint256 _roundId, int256 _answer, uint256 _startedAt, uint256 _updatedAt, uint256 _answeredInRound)
  {
    _roundId = _ARBITRARY_DATA;
    _answer = answer;
    _startedAt = startedAt;
    _updatedAt = _ARBITRARY_DATA;
    _answeredInRound = _ARBITRARY_DATA;
  }
}
