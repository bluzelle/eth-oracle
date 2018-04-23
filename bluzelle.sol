pragma solidity ^0.4.21;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract BluzelleClient is usingOraclize {
    using strings for *;
    mapping(bytes32 => string) outstandingReads;

    // Temporary until the proxy server exists
    string constant api_read = "https://pastebin.com/raw/";
    
    function read(string key) internal {
        bytes32 id = oraclize_query("URL", api_read.toSlice().concat(key.toSlice()));
        outstandingReads[id] = key;
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
