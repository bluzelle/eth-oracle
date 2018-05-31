pragma solidity ^0.4.20;

import "https://github.com/bluzelle/eth-oracle/bluzelle.sol";

/* This is a minimal sample client that watches the value of a single key in
 * Bluzelle */
contract SampleClient is BluzelleClient {

    string public key;
    string public value;
    
    bool public keyExists = false;

    address private owner = msg.sender;

    function SampleClient(string _key, string _uuid) public {
        require(bytes(_key).length > 0);
        require(bytes(_uuid).length > 0);
        key = _key;
        owner = msg.sender;
        setUUID(_uuid);
        create(_key, "initial value");
    }

    /* Read the value from Bluzelle (this requires a small fee to pay Oraclize) */
    function update() public payable {
        require(msg.sender == owner);
        read(key);
    }
    
    /* Set the value */
    function set(string _value) public payable {
        require(msg.sender == owner);
        update(key, _value);
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

