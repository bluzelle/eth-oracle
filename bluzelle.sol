pragma solidity ^0.4.21;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract BluzelleClient is usingOraclize {
    
    enum opType {read, create, update, remove}
    struct pendingOperation {
        opType op;
        string key;
    }
    
    using strings for *;
    mapping(bytes32 => pendingOperation) pendingOps;
    string uuid;

    string constant apiRead = "http://52.161.144.87:8080/read/";
    string constant apiCreate = "http://52.161.144.87:8080/create/";
    string constant apiUpdate = "http://52.161.144.87:8080/update/";
    string constant apiRemove = "http://52.161.144.87:8080/delete/";
    
    string constant successPrefix = "ack";
    string constant failPrefix = "err";

    function setUUID(string _uuid) internal {
        uuid = _uuid;
    }
    
    function read(string key) internal {
        string memory args = composeKey(key);
        string memory request = apiRead.toSlice().concat(args.toSlice());
        bytes32 id = oraclize_query("URL", request);
        pendingOps[id] = pendingOperation(opType.read, key);
    }
    
    function remove(string key) internal {
        string memory args = composeKey(key);
        string memory request = apiRemove.toSlice().concat(args.toSlice());
        // third parameter makes the request a POST
        bytes32 id = oraclize_query("URL", request, "-");
        pendingOps[id] = pendingOperation(opType.remove, key);
    }
    
    function update(string key, string data) internal {
        string memory args = composeKey(key);
        string memory request = apiUpdate.toSlice().concat(args.toSlice());
        bytes32 id = oraclize_query("URL", request, data);
        pendingOps[id] = pendingOperation(opType.update, key);
    }
    
    function create(string key, string data) internal {
        string memory args = composeKey(key);
        string memory request = apiCreate.toSlice().concat(args.toSlice());
        bytes32 id = oraclize_query("URL", request, data);
        pendingOps[id] = pendingOperation(opType.create, key);
    }

    function composeKey(string key) internal view returns (string res) {
        string memory pre = uuid.toSlice().concat("/".toSlice());
        res = pre.toSlice().concat(key.toSlice());
    }


    function readResult(string /*key*/, string /*result*/) internal {
        // Called when a read returns sucessfully
    }
    
    function readFailure(string /*key*/) internal {
        // Called when a read fails (no such key or db unavailable)
    }
    
    function createResponse(string /*key*/, bool /*success*/) internal {
        // Called when a create returns
    }
    
    function updateResponse(string /*key*/, bool /*success*/) internal {
        // Called when an update returns
    }
    
    function removeResponse(string /*key*/, bool /*success*/) internal {
        // Called when a remove returns
    }

    // Result from oraclize
    function __callback(bytes32 myid, string result) public {
        require(msg.sender == oraclize_cbAddress());
        require(pendingOps[myid].key.toSlice().len() > 0);
        
        bool success = result.toSlice().startsWith(successPrefix.toSlice());
        string memory key = pendingOps[myid].key;
        opType op = pendingOps[myid].op;
        
        if(op == opType.read){
            if(success){
                readResult(
                    key, 
                    result.toSlice().beyond(successPrefix.toSlice()).toString()
                    );
            }else{
                readFailure(key);
            }
        }else if(op == opType.create){
            createResponse(key, success);
        }else if(op == opType.update){
            updateResponse(key, success);
        }else if(op == opType.remove){
            removeResponse(key, success);
        }
        
        delete pendingOps[myid];
    }
}
