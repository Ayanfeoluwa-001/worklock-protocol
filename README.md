```markdown
# WorkLock Protocol

## Overview

WorkLock Protocol is an advanced freelance escrow and reputation management system built on the Stacks blockchain. It provides a secure, trustless platform for clients and freelancers to collaborate with built-in dispute resolution and rating mechanisms.

## Features

### Core Functionality
- **Job Creation with Escrow**: Clients can create jobs with STX deposits held in smart contract escrow
- **Freelancer Acceptance**: Freelancers can accept available jobs
- **Work Submission**: Freelancers submit completed work for client review
- **Payment Release**: Clients approve work and release STX payments to freelancers
- **Job Cancellation**: Clients can cancel jobs before work submission and receive refunds
- **Expiry Withdrawal**: Freelancers can withdraw funds if jobs expire without approval

### Reputation System
- **User Ratings**: Rate users on a scale of 1-5
- **Rating Storage**: Cumulative ratings and scores tracked per user
- **Trust Building**: Build reputation through successful job completions

### Dispute Management
- **Dispute Raising**: Clients can open disputes for problematic submissions
- **Admin Oversight**: Platform admins can intervene and process emergency refunds
- **Error Handling**: Comprehensive error codes for different failure scenarios

## Smart Contract Details

### Error Codes
| Code | Error | Description |
|------|-------|-------------|
| 100 | ERR-NOT-AUTHORIZED | Sender is not authorized for this action |
| 101 | ERR-NOT-FOUND | Job or resource not found |
| 102 | ERR-INVALID-STATE | Invalid state for operation |
| 103 | ERR-ALREADY-SET | Resource already exists |
| 104 | ERR-EXPIRED | Job or resource has expired |

### State Management
The contract tracks:
- **Jobs**: Client, freelancer, amount, timestamps, and status flags
- **Ratings**: User total ratings and cumulative scores
- **Platform Fee**: Configurable fee percentage (default: 2%)
- **Job Counter**: Auto-incrementing job ID generator

### Data Structures

#### Job Object
```clarity
{
  client: principal,           ;; Job creator
  freelancer: (optional principal), ;; Assigned freelancer
  amount: uint,                ;; STX escrow amount
  created-at: uint,            ;; Block height of creation
  deadline: uint,              ;; Deadline block height
  submitted: bool,             ;; Work submission status
  approved: bool,              ;; Client approval status
  cancelled: bool,             ;; Cancellation status
  disputed: bool               ;; Dispute status
}
```

#### Rating Object
```clarity
{
  total: uint,                 ;; Total ratings received
  score: uint                  ;; Cumulative score sum
}
```

## Public Functions

### Job Management

#### `create-job (amount: uint) (deadline: uint) -> (response uint)`
Creates a new job with escrow.
- **Parameters**:
  - `amount`: STX amount to escrow
  - `deadline`: Block height deadline
- **Returns**: Job ID on success
- **Errors**: ERR-INVALID-STATE if amount is 0

#### `accept-job (job-id: uint) -> (response bool)`
Freelancer accepts a job.
- **Parameters**: `job-id` - The job to accept
- **Returns**: `true` on success
- **Errors**: ERR-NOT-FOUND, ERR-ALREADY-SET if already assigned

#### `submit-work (job-id: uint) -> (response bool)`
Freelancer submits completed work.
- **Parameters**: `job-id` - The job with completed work
- **Returns**: `true` on success
- **Errors**: ERR-NOT-FOUND, ERR-NOT-AUTHORIZED, ERR-INVALID-STATE

#### `cancel-job (job-id: uint) -> (response bool)`
Client cancels job and receives refund.
- **Parameters**: `job-id` - The job to cancel
- **Returns**: `true` on success
- **Errors**: ERR-NOT-FOUND, ERR-NOT-AUTHORIZED, ERR-INVALID-STATE

#### `approve-work (job-id: uint) -> (response bool)`
Client approves work and releases payment.
- **Parameters**: `job-id` - The job to approve
- **Returns**: `true` on success
- **Status**: Stub implementation (in development)

#### `withdraw-expired (job-id: uint) -> (response bool)`
Freelancer withdraws funds from expired job.
- **Parameters**: `job-id` - The expired job
- **Returns**: `true` on success
- **Status**: Stub implementation (in development)

### Reputation & Disputes

#### `rate-user (user: principal) (score: uint) -> (response bool)`
Rate a user on scale of 1-5.
- **Parameters**:
  - `user`: Principal to rate
  - `score`: Rating score (1-5)
- **Returns**: `true` on success
- **Errors**: ERR-INVALID-STATE if score > 5

#### `open-dispute (job-id: uint) -> (response bool)`
Client opens a dispute for a job.
- **Parameters**: `job-id` - The disputed job
- **Returns**: `true` on success
- **Errors**: ERR-NOT-FOUND, ERR-NOT-AUTHORIZED

#### `admin-refund (job-id: uint) -> (response bool)`
Admin processes emergency refund.
- **Parameters**: `job-id` - The job to refund
- **Returns**: `true` on success
- **Errors**: ERR-NOT-AUTHORIZED, ERR-NOT-FOUND
- **Requirements**: Must be called by CONTRACT-ADMIN

### Read-Only Functions

#### `get-job (job-id: uint) -> (optional job)`
Retrieve job details.

#### `get-rating (user: principal) -> (optional rating)`
Retrieve user's cumulative rating.

#### `total-jobs -> uint`
Get total number of jobs created.

## Installation & Setup

### Prerequisites
- Clarinet CLI installed
- Stacks blockchain testnet access
- STX test tokens

### Local Setup
```bash
# Clone the repository
git clone <repository-url>
cd worklock-protocol

# Install dependencies
npm install

# Run tests
npm test

# Check contract compilation
clarinet check

# Deploy locally
clarinet devnet start
```

### Deployment
```bash
# Deploy to testnet
clarinet deployment apply --network testnet

# Deploy to mainnet
clarinet deployment apply --network mainnet
```

## Testing

The contract includes comprehensive unit tests covering:
- ✅ Job creation and escrow
- ✅ Freelancer acceptance
- ✅ Work submission and approval
- ✅ Job cancellation and refunds
- ✅ User rating system
- ✅ Dispute management
- ✅ Admin functions
- ✅ Error handling

Run tests with:
```bash
npm test
```

## Project Status

| Component | Status |
|-----------|--------|
| Core Job Management | ✅ Complete |
| Escrow System | ✅ Complete |
| Rating System | ✅ Complete |
| Dispute Management | ✅ Complete |
| Payment Release | 🚧 In Development |
| Expiry Withdrawal | 🚧 In Development |
| Admin Functions | ✅ Complete |
| Compilation | ✅ Passes |
| Unit Tests | ✅ All Passing |

## Security Considerations

- **Escrow Protection**: All payments held in smart contract until approved
- **Authorization Checks**: Only authorized parties can perform actions
- **State Validation**: Contract verifies all state transitions are valid
- **Emergency Admin**: Contract admin can process emergency refunds
- **Immutable Records**: All transactions recorded on blockchain

## Error Handling

The contract implements comprehensive error handling:
- Validates all user inputs
- Checks authorization before operations
- Verifies state transitions are valid
- Returns meaningful error codes
- Provides detailed error messages

## Gas Optimization

- Efficient data structure design
- Minimal map operations per function
- Optimized state updates using merge operations
- Single transaction per operation where possible

## Future Enhancements

- [ ] Milestone-based payments
- [ ] Automated dispute resolution via arbitration
- [ ] Freelancer portfolio system
- [ ] Advanced search and filtering
- [ ] Batch operations support
- [ ] Integration with Oracle for external data
- [ ] Multi-token support

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Submit a pull request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For issues, questions, or feedback:
- Open an issue on GitHub
- Join our Discord community
- Email: support@worklock.dev

## Acknowledgments

- Built on Stacks blockchain
- Uses Clarity smart contract language
- Inspired by successful freelance platforms

---
