pragma solidity ^0.4.21;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract BluzelleClient is usingOraclize {
    using strings for *;
    mapping(bytes32 => string) outstandingReads;
    string uuid;

    string constant api_read = "http://52.161.144.87:8080/read/";

    function setUUID(string _uuid) internal {
        uuid = _uuid;
    }
    
    function read(string key) internal {
        string memory args = composeKey(key);
        string memory request = api_read.toSlice().concat(args.toSlice());
        bytes32 id = oraclize_query("URL", request);
        outstandingReads[id] = key;
    }

    function composeKey(string key) internal view returns (string res) {
        string memory pre = uuid.toSlice().concat("/".toSlice());
        res = pre.toSlice().concat(key.toSlice());
    }


    function readCallback(string key, string result) internal;

    // Result from oraclize
    function __callback(bytes32 myid, string result) public {
        require(msg.sender == oraclize_cbAddress());
        require(bytes(outstandingReads[myid]).length > 0);

        readCallback(outstandingReads[myid], result);
        delete outstandingReads[myid];
    }

}

