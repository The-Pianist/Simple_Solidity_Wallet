// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowance is Ownable{
    event AllowanceChanged(address indexed _forWho, address indexed _fromWhom, uint _oldAmount, uint _newAmount);

    mapping(address=>uint) public allowance;

    function addAllowance(address _who,uint _amount)public onlyOwner{
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who]=_amount;
    }

    modifier ownerOrAllowed(uint _amount){
        require(owner()==msg.sender||allowance[msg.sender]>= _amount, "you are not allowed");
        _;
    }

    function reduceAllowance(address _who, uint _amount)internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who]-_amount);
        allowance[_who] -= _amount;
    }

}


contract SimpleWallet is Allowance{

    event MoneySent(address indexed _benefitciary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);
    
    function withdrawMoney(address payable _to,uint _amount)public ownerOrAllowed(_amount){
        require(_amount <= address (this).balance, "There are not enough fund in the smart Contract");
        if(owner()!=msg.sender){
            reduceAllowance(msg.sender,_amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    function renounceOwner()public view onlyOwner(){
        revert ("Can't reounce ownership here");
    }

    fallback ()external payable{
        emit MoneyReceived(msg.sender, msg.value);
    }
}