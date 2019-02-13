pragma solidity ^0.5.0;

contract Campaign {

    string title;
    string country;
    string description;
    uint goalScore;
    uint ratioProject;
    address payable owner;

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
    mapping (address => uint) donorsPercentage;
    mapping (uint => address) idDonor;
    address[] donors;

    mapping (address => uint) gatherersToken;
    address[] gatherers;

    bool public donationInProgress;
    bool public campaignInProgress;
    bool votingInProgress;
        
    constructor() public {
        owner = msg.sender;
        ratioProject = 70;

        addCommunityProject("CommunityProject 1");
        addCommunityProject("CommunityProject 2");

        donationInProgress = true;
        startTimeDonations = now;
    }

    function makeDonation() external payable {
        require(donationInProgress);
        if(donorsAmount[msg.sender] == 0) {
            donors.push(msg.sender);
        }
        donorsAmount[msg.sender] += msg.value;
    }

    function startCampaign() external {
        require(donationInProgress);
        startTimeCampaign = now;

        //owner.transfer(address(this).balance * ratioProject);

        uint forOwner = (address(this).balance / 100) * ratioProject;
        owner.transfer(forOwner);

        donationInProgress = false;
        campaignInProgress = true;
    }

    function endCampaign() external {
        require(campaignInProgress);
        //check, if runtime is over
        //check, if votingInProgress
        //check, if impactGoals were reached
        //if yes -> _startVoting();
        //else -> refund();

        campaignInProgress = false;
    } 

    function _refund() internal {

    } 

    function _startVoting() internal {
        //set startTimeVoting;
        votingInProgress = true;
        startTimeVoting = now;
    }

    function endVoting() external {
        //check, if runtime is over
        //check, if votingInProgress
        //pay out according to tokens invested
    }



    /// ***** VOTING *****

    uint totalBalance;
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

    function addCommunityProject(string memory name) private {
        communityProjects.push(CommunityProject(name, "desc", 2, 0x0fb4256f2dF60eab5788a0e413C7C30b3AfB5333));
    }




    // ***** PROOFING ******

    function getTokens(address addr, uint num) public{
        gatherersToken[addr] += num;
    }

} 