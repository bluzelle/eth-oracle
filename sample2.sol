pragma solidity ^0.4.20;

import "https://github.com/bluzelle/eth-oracle/bluzelle.sol";

/* This is a minimal sample client that watches the value of a single key in
 * Bluzelle */
contract SampleClient2 is BluzelleClient {

    string public key;
    string public value;
    
    bool public keyExists = false;

    address private owner = msg.sender;

    function SampleClient2(string _key, string _initial_value, string _uuid) public {
        require(bytes(_key).length > 0);
        require(bytes(_uuid).length > 0);
        key = _key;
        owner = msg.sender;
        setUUID(_uuid);
        create(_key, _initial_value);
    }

    /* Read the value from Bluzelle (this requires a small fee to pay Oraclize) */
    function update(string _key) public payable {
        read(_key);
    }
    
    /* Set a value */
    function set(string _key, string _value) public payable {
        update(_key, _value);
    }

    /* callback invoked by bluzelle upon read */
    function readResult(string /*unused*/, string v) internal {
        value = v;
    }
    
    /* callback invoked by bluzelle upon create */
    function createResponse(string /*unused*/, bool success) internal {
        if(success){
            keyExists = true;
        }
    }
    
    /* callback invoked by bluzelle upon delete */
    function removeResponse(string /*unusued*/, bool success) internal {
        if(success){
            keyExists = false;
        }
    }

    function refund() public payable {
        require(msg.sender == owner);
        remove(key);
        owner.transfer(address(this).balance);
    }
}

