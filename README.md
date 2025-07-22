# Community Resilience Platform

A blockchain-based platform designed to strengthen community bonds, enhance disaster preparedness, support local economic development, facilitate civic engagement, and foster intergenerational connections.

## Overview

This platform consists of five interconnected smart contracts that work together to build more resilient communities:

### 1. Social Cohesion Measurement Contract (`social-cohesion.clar`)
- Tracks community connectedness metrics
- Measures mutual support activities
- Rewards positive social interactions
- Maintains community trust scores

### 2. Disaster Preparedness Coordination Contract (`disaster-preparedness.clar`)
- Coordinates emergency response planning
- Manages resource allocation during disasters
- Tracks preparedness levels across communities
- Facilitates volunteer coordination

### 3. Local Economic Development Contract (`local-economy.clar`)
- Supports small business development
- Manages local entrepreneurship programs
- Tracks economic health indicators
- Facilitates community investment

### 4. Civic Engagement Facilitation Contract (`civic-engagement.clar`)
- Encourages participation in local governance
- Tracks voting and meeting attendance
- Manages community proposal systems
- Rewards active civic participation

### 5. Intergenerational Connection Contract (`intergenerational.clar`)
- Facilitates relationships between age groups
- Manages mentorship programs
- Tracks knowledge transfer activities
- Rewards cross-generational collaboration

## Key Features

- **Decentralized Governance**: Community-driven decision making
- **Incentive Systems**: Token rewards for positive community actions
- **Transparency**: All activities recorded on blockchain
- **Privacy Protection**: Personal data handled securely
- **Scalability**: Designed to work for communities of all sizes

## Technical Architecture

### Smart Contract Structure
Each contract is designed to be independent while supporting the overall platform goals:

- **Data Storage**: Uses Clarity maps and variables for efficient data management
- **Access Control**: Principal-based permissions system
- **Error Handling**: Comprehensive error codes and validation
- **Event Logging**: Detailed logging for all major actions

### Security Features
- Input validation on all public functions
- Principal verification for sensitive operations
- Overflow protection on numerical operations
- Comprehensive error handling

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

4. Deploy contracts:
   \`\`\`bash
   clarinet deploy
   \`\`\`

### Usage Examples

#### Measuring Social Cohesion
\`\`\`clarity
;; Record a community support activity
(contract-call? .social-cohesion record-support-activity u1 u100)

;; Get community trust score
(contract-call? .social-cohesion get-trust-score)
\`\`\`

#### Disaster Preparedness
\`\`\`clarity
;; Register as emergency volunteer
(contract-call? .disaster-preparedness register-volunteer "First Aid" u5)

;; Report resource availability
(contract-call? .disaster-preparedness report-resource "Water" u1000)
\`\`\`

#### Local Economic Development
\`\`\`clarity
;; Register a small business
(contract-call? .local-economy register-business "Local Bakery" "Food Service")

;; Invest in community project
(contract-call? .local-economy invest-in-project u1 u500)
\`\`\`

## Testing

The platform includes comprehensive tests for all contracts:

\`\`\`bash
npm test
\`\`\`

Tests cover:
- Contract deployment
- Function execution
- Error handling
- Edge cases
- Integration scenarios

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For questions or support, please open an issue in the repository.
