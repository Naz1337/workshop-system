# Data Models Overview (High-Level)

This document provides a high-level overview of the key data models within the Workshop-Foreman Management System. These models represent the core entities and relationships that underpin the system's functionality. A detailed Entity-Relationship Diagram (ERD) can be developed in a future phase. These entities will primarily be stored and managed using **Firebase Cloud Firestore** (or **Realtime Database**) as the backend database.

## Key Entities:

*   **User:**
    *   Represents a generic user of the system.
    *   Attributes: `userID`, `email`, `passwordHash`, `role` (e.g., 'Foreman', 'WorkshopOwner').

*   **Workshop:**
    *   Represents a workshop registered in the system.
    *   Attributes: `workshopID`, `ownerID` (FK to User), `name`, `address`, `contactInfo`, `description`, `servicesOffered`.

*   **ForemanProfile:**
    *   Represents the professional profile of a foreman.
    *   Attributes: `foremanID` (FK to User), `fullName`, `resumeURL`, `pastExperience`, `skills`, `contactInfo`.

*   **WorkApplication:**
    *   Represents a foreman's request to work at a specific workshop.
    *   Attributes: `applicationID`, `foremanID` (FK to ForemanProfile), `workshopID` (FK to Workshop), `status` (e.g., 'Pending', 'Approved', 'Rejected'), `applicationDate`.

*   **TimeSlot:**
    *   Represents an available work period at a workshop.
    *   Attributes: `timeSlotID`, `workshopID` (FK to Workshop), `startTime`, `endTime`, `date`, `isBooked`, `bookedByForemanID` (FK to ForemanProfile, nullable).

*   **PayrollRecord:**
    *   Represents a record of work completed by a foreman and the associated payment.
    *   Attributes: `payrollID`, `foremanID` (FK to ForemanProfile), `workshopID` (FK to Workshop), `timeSlotID` (FK to TimeSlot), `hoursWorked`, `rate`, `amountDue`, `paymentStatus` (e.g., 'Pending', 'Paid'), `paymentDate`.

*   **MarketplaceItem:**
    *   Represents a part or supply available for order by workshop owners.
    *   Attributes: `itemID`, `name`, `description`, `price`, `stockQuantity`, `category`.

*   **Order:**
    *   Represents an order placed by a workshop owner for marketplace items.
    *   Attributes: `orderID`, `workshopID` (FK to Workshop), `orderDate`, `totalAmount`, `status` (e.g., 'Pending', 'Shipped', 'Delivered').
    *   Includes line items linking to `MarketplaceItem`.

*   **Review:**
    *   Represents a review given by a user (foreman or workshop owner) to another user or entity.
    *   Attributes: `reviewID`, `reviewerID` (FK to User), `reviewedEntityID` (FK to User/Workshop/ForemanProfile), `rating`, `comment`, `reviewDate`, `reviewType` (e.g., 'ForemanToWorkshop', 'WorkshopToForeman').
