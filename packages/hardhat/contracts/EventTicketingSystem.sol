// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventTicketing {
    // Address of the event organizer
    address public organizer;
    // Price of each ticket
    uint public ticketPrice;
    // Maximum allowable resale price
    uint public maxResalePrice;
    // Total number of tickets available
    uint public totalTickets;
    // Counter for tickets sold
    uint public ticketsSold;

    // Mapping from Ticket ID to its current owner
    mapping(uint => address) public ticketOwners;
    // Mapping to track if a ticket has been verified
    mapping(uint => bool) public verifiedTickets;

    // Event emitted when a ticket is minted
    event TicketMinted(uint ticketId, address indexed owner);
    // Event emitted when a ticket is transferred
    event TicketTransferred(
        uint ticketId,
        address indexed from,
        address indexed to
    );
    // Event emitted when a ticket is verified
    event TicketVerified(uint ticketId);

    // Modifier to restrict actions to the organizer only
    modifier onlyOrganizer() {
        require(
            msg.sender == organizer,
            "Only the organizer can perform this action"
        );
        _;
    }

    // Modifier to ensure the caller is the owner of the ticket
    modifier onlyOwner(uint ticketId) {
        require(
            ticketOwners[ticketId] == msg.sender,
            "You do not own this ticket"
        );
        _;
    }

    // Constructor to initialize the contract with ticket details
    constructor(uint _ticketPrice, uint _maxResalePrice, uint _totalTickets) {
        // Set the organizer as the contract deployer
        organizer = msg.sender;
        // Set the price for tickets
        ticketPrice = _ticketPrice;
        // Set the maximum resale price
        maxResalePrice = _maxResalePrice;
        // Set the total number of tickets available
        totalTickets = _totalTickets;
    }

    // Function to mint a new ticket
    function mintTicket(uint ticketId) public onlyOrganizer {
        require(ticketOwners[ticketId] == address(0), "Ticket already minted");
        require(ticketsSold < totalTickets, "No tickets left to mint");

        // Assign the ticket to the organizer
        ticketOwners[ticketId] = msg.sender;
        ticketsSold++;

        // Emit the TicketMinted event
        emit TicketMinted(ticketId, msg.sender);
    }

    // Function to buy a ticket from the organizer
    function buyTicket(uint ticketId) public payable {
        require(
            ticketOwners[ticketId] == organizer,
            "Ticket not available for sale"
        );
        require(msg.value == ticketPrice, "Incorrect ticket price");

        // Transfer ownership to the buyer
        ticketOwners[ticketId] = msg.sender;

        // Emit the TicketTransferred event
        emit TicketTransferred(ticketId, organizer, msg.sender);
    }

    // Function to resell a ticket to another user
    function resellTicket(
        uint ticketId,
        address to,
        uint price
    ) public onlyOwner(ticketId) {
        require(price <= maxResalePrice, "Price exceeds max resale limit");
        require(to != address(0), "Invalid buyer address");

        // Transfer ownership to the new buyer
        ticketOwners[ticketId] = to;

        // Emit the TicketTransferred event
        emit TicketTransferred(ticketId, msg.sender, to);
    }

    // Function to verify a ticket
    function verifyTicket(uint ticketId) public {
        require(ticketOwners[ticketId] != address(0), "Ticket does not exist");
        require(!verifiedTickets[ticketId], "Ticket already verified");

        // Mark the ticket as verified
        verifiedTickets[ticketId] = true;

        // Emit the TicketVerified event
        emit TicketVerified(ticketId);
    }
}
