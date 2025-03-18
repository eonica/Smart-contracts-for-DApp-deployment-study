// SPDX-License-Identifier: MIT
// Author: Catalina Lazar

pragma solidity >=0.8.2 <0.9.0;

import "Utils.sol";

contract SupplyChain is Utils {
    address public administrator;

    constructor() {
        administrator = msg.sender;
        addTestingAccounts();
    }

    // actors actions

    function buySeeds(address seedSeller, string calldata _plantType) isFarmer isSeedSeller(seedSeller) public{
        plantBatches[plantBatchesCounter] = PlantBatch(_plantType, Status.SEED, plantBatchesCounter);

        emit BuySeeds(seedSeller, msg.sender, plantBatchesCounter, block.timestamp);

        plantBatchesCounter++;   
    }

    function germinateSeeds(uint batchId) isFarmer isSeedStatus(batchId) public {
        plantBatches[batchId].status = Status.GERMINATION;

        emit GerminateSeeds(msg.sender, batchId, block.timestamp);
    }

    function plant(uint batchId) isFarmer isGerminationStatus(batchId) public {
        plantBatches[batchId].status = Status.VEGETATIVE_GROWTH;

        emit Plant(msg.sender, batchId, block.timestamp);
    }

    function stimulate(uint batchId, address pesticideSeller, string calldata pesticideType) isPesticideSeller(pesticideSeller) 
                                                                                             isVegetativeGrowthStatus(batchId)
                                                                                             isFarmer
                                                                                             public {
        emit Stimulate(pesticideSeller, msg.sender, pesticideType, batchId, block.timestamp);
    }

    function harvest(uint batchId) isFarmer isVegetativeGrowthStatus(batchId) public {
        plantBatches[batchId].status = Status.HARVEST;
        
        emit Harvest(msg.sender, batchId, block.timestamp);
    }

    function transport(uint batchId, address from, address to) isReadyForTransport(batchId)
                                                               isSource(from)
                                                               isDistributer 
                                                               isDeposit(to) public {
        plantBatches[batchId].status = Status.STORED;
        
        emit Transport(msg.sender, from, to, batchId, block.timestamp);
    }

    function store(uint batchId, address location) isDistributer isDeposit(location) public {
        emit Storing(location, batchId, block.timestamp);
    }

    function displayVegetables(uint batchId) isStore public {
        plantBatches[batchId].status = Status.DISPLAYED;

        emit Display(msg.sender, batchId, block.timestamp);
    }

    function registerActor() ValidRegistration payable public {
        actorFee[msg.sender] = msg.value;
    }

    // administrator actions
    function addActor(address _actor, string calldata _companyAddress, string calldata _companyLink,
                      string calldata _companyName, string memory _role) isAdministrator(administrator) PaidFee(_actor) public{
        (Role role, mapping(address => Actor) storage actorsSet) = unmarshalRole(_role);
        
        require(actorsSet[_actor].isActive == false || testingAccounts[_actor] == true, "Actor already added");

        actorsSet[_actor] = Actor(_companyAddress, _companyName, _companyLink, block.timestamp, true, role);
     }
}