// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;
import"./ERC-20.sol";

contract Vote is OwnerHelper{

    struct Voter {
        uint weight;
        uint vote;
        bool voted;
    }
    struct Candidate{
        address _address;
        uint  count;
    } 

    mapping(address => Voter) voters;
    Candidate[] candidates;

    modifier validPhase(Phase req){
        require(state == req);
        _;
    }

    enum Phase{Init, Reg, Vote, Done}
    Phase public state = Phase.Init;

    function ballot(address[] memory candidate) public validPhase(Phase.Reg) onlyOwner   { 
        for(uint i=0; i<3; i++){
            voters[owners[i]].weight = 2;
        }
        for(uint i=0; i<candidate.length; i++)
            candidates.push(Candidate({
                _address : candidate[i], count : 0}));
    }

    function nextState() public onlyOwner{
        if(state == Phase.Init)
            state = Phase.Reg;
        else if(state == Phase.Reg)
            state = Phase.Vote;
        else if(state == Phase.Vote)
            state = Phase.Done;
        else
            state = Phase.Init;
    }

    function register(address voter) public validPhase(Phase.Reg) onlyOwner{
        require(!voters[voter].voted);
        voters[voter].weight = 1;
    }

    function vote(uint num) public validPhase(Phase.Vote){
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);
        require(num < candidates.length);
        sender.voted = true;
        sender.vote = num;
        candidates[num].count += sender.weight;
    }

    function reqWinner() public validPhase(Phase.Done) onlyOwner{
        uint winnerCount1 = 0;
        uint winnerCount2 = 0;
        uint winnerCount3 = 0;
        uint[3] memory winners;
        for(uint i=0; i<candidates.length; i++){
            if(candidates[i].count > winnerCount1){
                winners[2] = winners[1];
                winners[1] = winners[0];
                winners[0] = i;
                winnerCount3 = winnerCount2;
                winnerCount2 = winnerCount1;
                winnerCount1 = candidates[i].count;
            }
            else if(candidates[i].count > winnerCount2){
                winners[2] = winners[1];
                winners[1] = i;
                winnerCount3 = winnerCount2;
                winnerCount2 = candidates[i].count;
            }
            else if(candidates[i].count > winnerCount3){
                winners[2] = i;
                winnerCount3 = candidates[i].count;
            }
        }
        owners[0] = candidates[winners[0]]._address;
        owners[1] = candidates[winners[1]]._address;
        owners[2] = candidates[winners[2]]._address;
    }
}

