// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

//solhint-disable

import 'forge-std/Script.sol';
import {ForkManagement} from '@script/testScripts/gov/helpers/ForkManagement.s.sol';

contract Generator is ForkManagement {
  using stdJson for string;

  string public _version = 'version 0.1';

  function _loadBaseData(string memory json) internal virtual {
    // empty
  }

  function run(string memory _filePath) public {
    _loadJson(_filePath);
    _checkNetworkParams();
    _loadPrivateKeys();
    _loadBaseData(json);
    _generateProposal();
  }

  function _generateProposal() internal virtual {
    // empty
  }
}
