pragma solidity ^0.4.21;

import "https://github.com/bluzelle/eth-oracle/bluzelle.sol";

/* This is a minimal sample client that watches the value of a single key in
 * Bluzelle */
contract SampleClient is BluzelleClient {
    
    string private key;
    string public value;
    
    address private owner = msg.sender;
    
    constructor(string _key, string _uuid) public {
        key = _key;
        owner = msg.sender;
        setUUID(_uuid);
    }
    
    /* Read the value from Bluzelle (this requires a small fee to pay Oraclize) */
    function update() public payable {
        require(msg.sender == owner);
        read(key);
    }
    
    function readCallback(string /*unused*/, string v) internal {
        value = v;
    }
    
    function refund() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
}
