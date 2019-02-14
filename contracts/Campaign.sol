pragma solidity ^0.5.0;

contract Campaign {

    string title;
    string country;
    string description;
    uint goalScore;
    uint ratioProject;
    address payable owner;

    uint totalBalance;
    uint precision = 10000;

    uint startTimeDonations;
    uint runTimeDonations;

    uint startTimeCampaign;
    uint runTimeCampaign;
    
    uint startTimeVoting;
    uint runTimeVoting; 

    struct CommunityProject {
        string title;
        string description;
        uint voteCount;
        address payable account;
    }

    CommunityProject[] public communityProjects;

    mapping (address => uint) donorsAmount;
    mapping (uint => address) idDonor;
    address[] donors;
    uint[] donorsShare;

    mapping (address => uint) gatherersToken;
    address[] gatherers;

    bool public donationInProgress;
    bool public campaignInProgress;
    bool votingInProgress;
        
    constructor() public {
        owner = msg.sender;

        _createCampaign();
        _createAllCommunityProjects();

        donationInProgress = true;
        startTimeDonations = now;
    }

    function _createCampaign() internal {
        title = "Save the Bisons!";
        description = "This is a sample Campaign to demonstrate the power of blockchain technology.";
        country = "Romania";
        goalScore = 100;
        ratioProject = 60;

        runTimeDonations = 30 seconds;
        runTimeCampaign = 30 seconds;
        runTimeVoting = 30 seconds;
    }

    function _createAllCommunityProjects() internal {
        addCommunityProject(
            "Schools 4 Everybody", 
            "Eductation is extremely important. We want to make it available to all the children in our village.",
            0x0fb4256f2dF60eab5788a0e413C7C30b3AfB5333
        );
        
        addCommunityProject(
            "Build a Wall", 
            "I want a big, beautiful wall. It will be the best wall. And the Bulgarians will pay for it.",
            0x0fb4256f2dF60eab5788a0e413C7C30b3AfB5333
        );
    }

    function() external payable {
        require(donationInProgress, "donation not in progress");
        if(donorsAmount[msg.sender] == 0) {
            donors.push(msg.sender);
        }
        donorsAmount[msg.sender] += msg.value;
    }

    function startCampaign() external {
        require(donationInProgress, "donation not in progress");
        require(now >= startTimeDonations + runTimeDonations, "too soon, donations time not yet up.");

        _calculateDonorsShare();
        startTimeCampaign = now;
        donationInProgress = false;
        campaignInProgress = true;

        uint forOwner = (address(this).balance / 100) * ratioProject;
        owner.transfer(forOwner);        
    }

    function _calculateDonorsShare() internal {
        totalBalance = address(this).balance;
        for(uint i = 0; i < donors.length; i++) {
            address donorAddress = donors[i];
            uint donation = donorsAmount[donorAddress];
            uint share = (donation * precision) / totalBalance;
            donorsShare.push(share);
        }
    }

    function _refund() internal {
        uint totalRefund = address(this).balance;
        for(uint i = 0; i < donors.length; i++) {
            uint refundAmount = (totalRefund / precision) * donorsShare[i];
            address payable donorAddress = address(uint160(donors[i]));
            donorAddress.transfer(refundAmount);
        }
        //in case there are some (very small funds) remaining, send it to the owner
        owner.transfer(address(this).balance);
    } 

    function startVoting() external {
        require(campaignInProgress, "campaign not in progress");
        require(now >= startTimeCampaign + runTimeCampaign, "too soon, campaign time not yet up");
        if(_impactGoalsAchieved() == false) {
            _refund();
        } else {
            startTimeVoting = now;
            campaignInProgress = false;
            votingInProgress = true;
        }
    }

    function endVoting() external {
        require(votingInProgress, "voting not in progress");
        require(now >= startTimeVoting + runTimeVoting, "too soon, voting time not yet up");
        //pay out according to tokens invested
    }



    /// * VOTING *

    uint voteCountTotal;

    event votedEvent (
        uint indexed communityProjectId
    );

    function vote(uint _communityProjectId, uint _voteCount) public {
        // check if voting is in progress
        require(votingInProgress, "Voting not in progress");

        // require that they haven sufficient votingTokens
        /* msg.sender: address of the function caller */
        require(gatherersToken[msg.sender] >= _voteCount, "The sender doesn't have enough tokens!");

        // require a valid CommunityProject
        require(_communityProjectId >= 0 && _communityProjectId < communityProjects.length, "The given CommunityProject id is invalid!");

        // reduce votingToken count 
        gatherersToken[msg.sender] -= _voteCount;

        // update CommunityProject vote Count
        communityProjects[_communityProjectId].voteCount += _voteCount;

        voteCountTotal += _voteCount;

        //trigger vote event
        emit votedEvent(_communityProjectId);
    }

    function payout() public{
        for(uint i = 0; i < communityProjects.length; i++ ){
            communityProjects[i].account.transfer(1);
        }
    }

    function addCommunityProject(string memory name, string memory description, address payable account) private {
        communityProjects.push(CommunityProject(name, description, 0, account));
    }




    // ***** PROOFING ******

    function getTokens(address addr, uint num) public{
        gatherersToken[addr] += num;
    }

    function _impactGoalsAchieved() internal returns (bool) {
        //check, whether impactGoals were achieved
        return false;
    }

} 