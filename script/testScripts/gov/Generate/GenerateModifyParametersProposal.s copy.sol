// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import {JSONScript} from '@script/testScripts/gov/helpers/JSONScript.s.sol';
import {Strings} from '@openzeppelin/utils/Strings.sol';
import {ODGovernor} from '@contracts/gov/ODGovernor.sol';
import {Modifiable} from '@contracts/utils/Modifiable.sol';
import {IModifiable} from '@interfaces/utils/IModifiable.sol';
import {Generator} from '@script/testScripts/gov/Generator.s.sol';
import 'forge-std/StdJson.sol';

contract GenerateModifyParametersProposal is Generator, JSONScript {
  using stdJson for string;

  error UnrecognizedDataType();

  address[] internal _targets;
  string[] internal _datas;
  string[] internal _params;
  string[] internal _dataTypes;

  address internal _governanceAddress;
  string internal _description;

  function _loadBaseData(string memory json) internal override {
    _description = json.readString(string(abi.encodePacked('.description')));
    _governanceAddress = json.readAddress(string(abi.encodePacked('.odGovernor')));
    uint256 len = json.readUint(string(abi.encodePacked('.arrayLength')));

    for (uint256 i; i < len; i++) {
      string memory index = Strings.toString(i);
      address target = json.readAddress(string(abi.encodePacked('.objectArray[', index, '].target')));
      string memory param = json.readString(string(abi.encodePacked('.objectArray[', index, '].param')));
      string memory dataType = json.readString(string(abi.encodePacked('.objectArray[', index, '].type')));
      string memory data = json.readString(string(abi.encodePacked('.objectArray[', index, '].data')));
      _targets.push(target);
      _params.push(param);
      _dataTypes.push(dataType);
      _datas.push(data);
    }
  }

  function _generateProposal() internal override {
    ODGovernor gov = ODGovernor(payable(_governanceAddress));

    require(
      _params.length == _dataTypes.length && _dataTypes.length == _targets.length && _targets.length == _datas.length,
      'Modify Parameters: Length Mismatch'
    );

    uint256 len = _params.length;

    address[] memory targets = new address[](len);
    uint256[] memory values = new uint256[](len);
    bytes[] memory calldatas = new bytes[](len);

    for (uint256 i; i < len; i++) {
      targets[i] = _targets[i];
      values[i] = 0;
      calldatas[i] = _readData(_dataTypes[i], _params[i], _datas[i]);
    }

    bytes32 descriptionHash = keccak256(bytes(_description));

    vm.startBroadcast(_privateKey);

    // Propose the action to add the collateral type
    uint256 proposalId = gov.hashProposal(targets, values, calldatas, descriptionHash);
    string memory stringProposalId = vm.toString(proposalId / 10 ** 69);

    {
      string memory objectKey = 'MODIFY_PARAMS_OBJECT_KEY';
      // Build the JSON output
      string memory builtProp =
        _buildProposalParamsJSON(proposalId, objectKey, targets, values, calldatas, _description, descriptionHash);
      vm.writeJson(builtProp, string.concat('./gov-output/', _network, '/', stringProposalId, '-modifyParameters.json'));
    }

    vm.stopBroadcast();
  }

  function _readData(
    string memory dataType,
    string memory param,
    string memory dataString
  ) internal pure returns (bytes memory dataOutput) {
    bytes32 typeHash = keccak256(abi.encode(dataType));
    bytes32 encodedParam = bytes32((abi.encodePacked(param)));
    bytes4 selector = IModifiable.modifyParameters.selector;
    bytes memory encodedData;

    if (typeHash == keccak256(abi.encode('uint256')) || typeHash == keccak256(abi.encode('uint'))) {
      encodedData = abi.encode(vm.parseUint(dataString));
    } else if (typeHash == keccak256(abi.encode('address'))) {
      encodedData = abi.encode(vm.parseAddress(dataString));
    } else if (typeHash == keccak256(abi.encode('string'))) {
      encodedData = abi.encode(dataString);
    } else if (typeHash == keccak256(abi.encode('int256')) || typeHash == keccak256(abi.encode('int'))) {
      encodedData = abi.encode(vm.parseInt(dataString));
    } else {
      revert UnrecognizedDataType();
    }

    return dataOutput = abi.encodeWithSelector(selector, encodedParam, encodedData);
  }

  function _serializeCurrentJson(string memory _objectKey) internal override returns (string memory _serializedInput) {
    _serializedInput = vm.serializeJson(_objectKey, json);
  }
}
