// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

contract Agent {
    struct patient {
        string name;
        uint256 age;
        address[] doctorAccessList;
        uint256[] diagnosis;
        string record;
    }

    struct doctor {
        string name;
        uint256 age;
        address[] patientAccessList;
        string record;
    }

    uint256 creditPool;

    address[] public patientList;
    address[] public doctorList;

    mapping(address => patient) patientInfo;
    mapping(address => doctor) doctorInfo;

    mapping(address => address) Empty;
    mapping(address => string) patientRecords;

    function addAgent(
        string memory _name,
        uint256 _age,
        uint256 _designation,
        string memory _hash
    ) public {
        address addr = msg.sender;
        if (_designation == 0) {
            patient memory temp_patient;
            temp_patient.name = _name;
            temp_patient.age = _age;
            temp_patient.record = _hash;
            patientInfo[msg.sender] = temp_patient;
            patientList.push(addr);
        } else if (_designation == 1) {
            doctor memory temp_doctor;
            temp_doctor.name = _name;
            temp_doctor.age = _age;
            temp_doctor.record = _hash;
            doctorInfo[msg.sender] = temp_doctor;
            doctorList.push(addr);
        }
    }

    function getPatient(address addr)
        public
        view
        returns (
            string memory,
            uint256,
            uint256[] memory,
            address,
            string memory
        )
    {
        return (
            patientInfo[addr].name,
            patientInfo[addr].age,
            patientInfo[addr].diagnosis,
            Empty[addr],
            patientInfo[addr].record
        );
    }

    function getDoctor(address addr)
        public
        view
        returns (string memory, uint256)
    {
        return (doctorInfo[addr].name, doctorInfo[addr].age);
    }

    function getPatientDoctorName(address paddr, address daddr)
        public
        view
        returns (string memory, string memory)
    {
        return (patientInfo[paddr].name, doctorInfo[daddr].name);
    }

    function permitAccess(address payable addr)
        public
        payable
        returns (address[] memory, address[] memory)
    {
        require(msg.value == 1 ether);
        creditPool += 1;
        doctorInfo[addr].patientAccessList.push(msg.sender);
        patientInfo[msg.sender].doctorAccessList.push(addr);
        return (
            patientInfo[msg.sender].doctorAccessList,
            doctorInfo[addr].patientAccessList
        );
    }

    function revokeAccess(address payable daddr) public payable {
        require(msg.value == 1 ether);
        removePatient(msg.sender, daddr);
        payable(msg.sender).transfer(1 ether);
        creditPool -= 1;
    }

    function insuranceClaim(
        address payable _paddr,
        uint256 _diagnosis,
        string memory _hash
    ) public payable {
        bool patientFound = false;
        for (
            uint256 i = 0;
            i < doctorInfo[msg.sender].patientAccessList.length;
            i++
        ) {
            if (doctorInfo[msg.sender].patientAccessList[i] == _paddr) {
                payable(msg.sender).transfer(1 ether);
                creditPool -= 1;
                patientFound = true;
            }
        }
        if (patientFound) {
            setHash(_paddr, _hash);
            removePatient(_paddr, msg.sender);
            bool diagnosisFound = false;
            for (uint256 i = 0; i < patientInfo[_paddr].diagnosis.length; i++) {
                if (patientInfo[_paddr].diagnosis[i] == _diagnosis)
                    diagnosisFound = true;
            }
        }
    }

    function getAccessedDoctorListForPatient(address _addr)
        public
        view
        returns (address[] memory)
    {
        address[] storage doctoraddr = patientInfo[_addr].doctorAccessList;
        return doctoraddr;
    }

    function getAccessedPatientListForDoctor(address _addr)
        public
        view
        returns (address[] memory)
    {
        return doctorInfo[_addr].patientAccessList;
    }

    function getPatientList() public view returns (address[] memory) {
        return patientList;
    }

    function getDoctorList() public view returns (address[] memory) {
        return doctorList;
    }

    function setHash(address _paddr, string memory _hash) private {
        patientInfo[_paddr].record = _hash;
    }

    function getHash(address _paddr) public view returns (string memory) {
        return patientInfo[_paddr].record;
    }

    function removeElementInArray(address[] storage _Array, address _addr)
        private
    {
        uint256 delIndex = _Array.length + 1;
        for (uint256 i = 0; i < _Array.length; i++) {
            if (_Array[i] == _addr) {
                delIndex = i;
                delete _Array[delIndex];
                break;
            }
        }
        if (delIndex != _Array.length + 1) {
            for (uint256 i = delIndex; i < _Array.length - 1; i++) {
                _Array[i] = _Array[i + 1];
            }
        }
        _Array.pop();
    }

    function removePatient(address _paddr, address _daddr) public {
        removeElementInArray(doctorInfo[_daddr].patientAccessList, _paddr);
        removeElementInArray(patientInfo[_paddr].doctorAccessList, _daddr);
    }
}
