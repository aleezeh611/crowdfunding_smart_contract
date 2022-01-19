//SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract crowdfunding{
    // ==== Campaign Details stored in a struct ====
    struct Campaign{
        string name;
        string description;
        uint currentfunds;
        address payable recipient;
        uint investorsCount;
        uint approvalcount;
        string status;
        uint milestones;
        address[] investors; 
        uint fundsneeded;
        bool fundscollected;
    }

    Campaign[] public CampaignsList;
    string inprogress = "in progress";
    string completed = "completed";

    constructor() {
        //do nothing
    }
    
    // ==== create a new contract ====
    function createCampaign(string calldata n, string calldata dsc, uint fn) public {
        //Campaign memory tempitem = Campaign(n, dsc,0, payable(0),0, tempinvestorlist);
        Campaign memory campaignproposal;
        campaignproposal.name = n;
        campaignproposal.description = dsc;
        campaignproposal.currentfunds = 0;
        campaignproposal.recipient = payable(msg.sender);
        campaignproposal.investorsCount = 0;
        campaignproposal.status = inprogress;
        campaignproposal.milestones = 1;
        campaignproposal.fundsneeded = fn;
        campaignproposal.fundscollected = false;
        campaignproposal.approvalcount = 0;
        CampaignsList.push(campaignproposal);
    }

    //Function to let investords invest in the campaign - store the address of each investor 
    function InvestInCampaign( uint indexofcampaign) public payable{
        if (CampaignsList[indexofcampaign].fundscollected == false && keccak256(bytes(CampaignsList[indexofcampaign].status)) == keccak256(bytes(inprogress))){
            CampaignsList[indexofcampaign].currentfunds += msg.value;
            if(CampaignsList[indexofcampaign].fundsneeded == CampaignsList[indexofcampaign].currentfunds){
                CampaignsList[indexofcampaign].fundscollected = true;
            }
            if (CampaignsList[indexofcampaign].investors.length == 1){
                CampaignsList[indexofcampaign].investors[0] = payable(msg.sender);
            }
            else{
                CampaignsList[indexofcampaign].investors.length;
                CampaignsList[indexofcampaign].investors.push(msg.sender);
            }
            CampaignsList[indexofcampaign].investorsCount += 1;
        }
    }


    //Function to get approvals from investors to make sure project is on the right track and therefore worthy of the money
    function giveApproval( uint indexofcampaign) public{
        bool check = false;
        for(uint i = 0 ; i < CampaignsList[indexofcampaign].investors.length; i++){
            if (CampaignsList[indexofcampaign].investors[i] == msg.sender){
                check = true;
                break;
            }
        }
        if (check == true){
            CampaignsList[indexofcampaign].approvalcount += 1;
        }
    }

    //Function for investees to retrieve money
    // money can only be retrieved once all the target funds has been achieved
    // money can only be recieved if investors have given approval (i.e progress shown according to predefined milestones)
    function retrieveMoney(uint indexofcampaign) public payable {
        if (CampaignsList[indexofcampaign].recipient == msg.sender && CampaignsList[indexofcampaign].fundscollected == true && keccak256(bytes(CampaignsList[indexofcampaign].status)) == keccak256(bytes(inprogress))){
            if (CampaignsList[indexofcampaign].milestones == 1){
                uint currentmoney = CampaignsList[indexofcampaign].currentfunds; 
                CampaignsList[indexofcampaign].currentfunds -= currentmoney/4;
                CampaignsList[indexofcampaign].recipient.transfer(currentmoney/4);
            }
            else if (CampaignsList[indexofcampaign].approvalcount >= CampaignsList[indexofcampaign].investorsCount/4){
                uint currentmoney = CampaignsList[indexofcampaign].currentfunds; 
                if (CampaignsList[indexofcampaign].milestones == 2 || CampaignsList[indexofcampaign].milestones == 3 ){
                    CampaignsList[indexofcampaign].currentfunds -= currentmoney/2;
                    CampaignsList[indexofcampaign].recipient.transfer(currentmoney/2);
                }
                else if (CampaignsList[indexofcampaign].milestones == 4){
                    CampaignsList[indexofcampaign].recipient.transfer(currentmoney*(1 ether));
                }
            }
        }
    }
        
    function updateMilestones(uint indexofcampaign) public {
        if(CampaignsList[indexofcampaign].recipient == msg.sender && CampaignsList[indexofcampaign].milestones < 4){
            CampaignsList[indexofcampaign].milestones += 1;
        }
    }

    function EndCampaign(uint indexofcampaign) public {
        if (CampaignsList[indexofcampaign].recipient == msg.sender){
            CampaignsList[indexofcampaign].status = "completed";
        }
    }

    //getter functions for display
    function getCampaignName(uint id) external view returns (string memory){
        return (CampaignsList[id].name );
    }
    function getCampaignDesc(uint id) external view returns (string memory){
        return ( CampaignsList[id].description );
    }
    function getCampaignMilestones(uint id) external view returns ( uint){
        return ( CampaignsList[id].milestones );
    }
    function getCampaignTargetAmount(uint id) external view returns ( uint){
        return ( CampaignsList[id].fundsneeded );
    }
    function getCampaignCurrentFunds(uint id) external view returns ( uint){
        return ( CampaignsList[id].currentfunds );
    }
    function getInvestorsNumber(uint id) external view returns (uint){
        return (CampaignsList[id].investorsCount);
    }
}
