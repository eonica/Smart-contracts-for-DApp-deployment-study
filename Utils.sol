// SPDX-License-Identifier: MIT
// Author: Catalina Lazar

pragma solidity >=0.8.2 <0.9.0;

contract Utils {
    // enums
    enum Role {SEED_SELLER, FARMER, PESTICIDES_SELLER, DISTRIBUTER, WAREHOUSE, STORE} 
    enum Status {SEED, GERMINATION, VEGETATIVE_GROWTH, HARVEST, STORED, DISPLAYED}

    // structs
    struct Actor {
        string companyAddress;
        string companyName;
        string companyLink;
        uint initialDate;
        bool isActive;
        Role role;
    }

    struct PlantBatch {
        string species;
        Status status;
        uint batchId;
    }

    //storage
    mapping(address => Actor) public pesticidesSellers;
    mapping(address => Actor) public distributers;
    mapping(address => Actor) public seedSellers;
    mapping(address => Actor) public warehouses;
    mapping(address => Actor) public farmers;
    mapping(address => Actor) public stores;

    mapping(address => bool) public testingAccounts;

    mapping(uint => PlantBatch) public plantBatches;

    mapping(address => uint) public actorFee;

    uint internal plantBatchesCounter;

    //events
    event Stimulate(address pesticideSeller, address farmer, string pesticideType, uint indexed batchId, uint date);
    event Transport(address distributer, address from, address to, uint indexed batchId, uint date);
    event BuySeeds(address seedSeller, address farmer, uint indexed batchId, uint date);
    event GerminateSeeds(address farmer, uint indexed batchId, uint date);
    event Storing(address location, uint indexed batchId, uint date);
    event Harvest(address farmer, uint indexed batchId, uint date);
    event Display(address store, uint indexed batchId, uint date);
    event Plant(address farmer, uint indexed batchId, uint date);

    //modifiers    
    modifier isPesticideSeller(address pesticideSeller) {
      require(pesticidesSellers[pesticideSeller].isActive==true, "Require Pesticide Seller Role");
      _;
   }

   modifier isAdministrator(address administrator) {
    require(msg.sender==administrator, "Require Administrator Role");
    _;
   }

    modifier isDeposit(address location) {
      require(warehouses[location].isActive==true || 
              stores[location].isActive==true, "Require a Deposit, the role is neither Warehouse or Store");
      _;
   }

   modifier isSource(address location) {
        require(farmers[location].isActive == true || 
        warehouses[location].isActive == true, "Require a Source, the role is neither Warehouse or Farmer");
        _;
   }

    modifier isDistributer {
      require(distributers[msg.sender].isActive==true, "Require Distributer Role");
      _;
   }

   modifier isSeedSeller(address seedSeller) {
      require(seedSellers[seedSeller].isActive==true, "Require Seed Seller Role");
      _;
   }

   modifier isFarmer {
      require(farmers[msg.sender].isActive==true, "Require Farmer Role");
      _;
   }

   modifier isStore {
      require(stores[msg.sender].isActive==true, "Require Store Role");
      _;
   }

   modifier isReadyForTransport(uint batchId) {
    require(plantBatches[batchId].status == Status.HARVEST ||
    plantBatches[batchId].status == Status.STORED, "Not ready to transport, status is neither Harvest or Stored" );
      _;
   }

   modifier isVegetativeGrowthStatus(uint batchId) {
    require(plantBatches[batchId].status == Status.VEGETATIVE_GROWTH, "Require Vegetative Growth Status");
    _;
   }

   modifier isGerminationStatus(uint batchId) {
    require(plantBatches[batchId].status == Status.GERMINATION, "Require Germination Status");
    _;
   }

   modifier isDisplayedStatus(uint batchId) {
    require(plantBatches[batchId].status == Status.DISPLAYED, "Require Displayed Status");
    _;
   }

   modifier isHarvestStatus(uint batchId) {
    require(plantBatches[batchId].status == Status.HARVEST, "Require Harvest Stastus");
    _;
   }

   modifier isStoredStatus(uint batchId) {
     require(plantBatches[batchId].status == Status.STORED, "Require Stored Status");
      _;
   }

    modifier isSeedStatus(uint batchId) {
     require(plantBatches[batchId].status == Status.SEED, "Require Seed Status");
      _;
   }

    modifier PaidFee(address _actor) {
        require(actorFee[_actor]>0, "Actor did not paid the fee");
        _;
    }

    modifier ValidRegistration() {
        require(msg.value > 0, "Registration fee must not be 0");
        require(actorFee[msg.sender]==0 || testingAccounts[msg.sender] == true, "Registration can be done once per actor");

        _;
    }

   //utils 
    function unmarshalRole(string memory _role) internal view returns(Role role, mapping(address => Actor) storage set) {
        bytes32 encodedRole = keccak256(abi.encodePacked(_role));
        bytes32 encodedRole_PESTICIDES_SELLER = keccak256(abi.encodePacked("PESTICIDES_SELLER"));
        bytes32 encodedRole_DISTRIBUTER = keccak256(abi.encodePacked("DISTRIBUTER"));
        bytes32 encodedRole_SEED_SELLER = keccak256(abi.encodePacked("SEED_SELLER"));
        bytes32 encodedRole_WAREHOUSE = keccak256(abi.encodePacked("WAREHOUSE"));
        bytes32 encodedRole_FARMER = keccak256(abi.encodePacked("FARMER"));
        bytes32 encodedRole_STORE = keccak256(abi.encodePacked("STORE"));

        if(encodedRole == encodedRole_PESTICIDES_SELLER) {
            return (Role.PESTICIDES_SELLER, pesticidesSellers);
        }

        if(encodedRole == encodedRole_DISTRIBUTER) {
            return (Role.DISTRIBUTER, distributers);
        }

       if(encodedRole == encodedRole_SEED_SELLER) {
            return (Role.SEED_SELLER, seedSellers);
        }

        if(encodedRole == encodedRole_WAREHOUSE) {
            return (Role.WAREHOUSE, warehouses);
        }

        if(encodedRole == encodedRole_FARMER) {
            return (Role.FARMER, farmers);
        }

        if(encodedRole == encodedRole_STORE) {
            return (Role.STORE, stores);
        }

        revert("Received Invalid Role");
    }

    function addTestingAccounts() internal {
        testingAccounts[address(0x77ec9296D5B62c496F23e72F15d91D77bEbf1EBD)] = true;
        testingAccounts[address(0x1864aE84dBD93C94dee4B1ec909E80d58c382AC5)] = true;
        testingAccounts[address(0xefc1F110e7Cc9230873bb534E63A213df39B6700)] = true;
        testingAccounts[address(0x4d664138565579534965F8FFe859648421E0c400)] = true;
        testingAccounts[address(0xa18fAcCc459bb5a3B4746C5D129d3433d995e1a5)] = true;
        testingAccounts[address(0x8d0314db673ea07C10478bbB3294d79B0A38C3f5)] = true;
        testingAccounts[address(0xf6daD103eF8EfCA36d6a753a2054501BeAfC9546)] = true;
        testingAccounts[address(0xB78A5508E77b7055baBF6A066B9822E5B4d61A35)] = true;
        testingAccounts[address(0xC9E17429BE795477234AcB0e0148fCc0C26E3d29)] = true;
        testingAccounts[address(0x0557a232d5f40be91cCc4e508573931a8869946d)] = true;
    }
}