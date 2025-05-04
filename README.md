# ThitoHomes

![ThitoHomes Logo](https://via.placeholder.com/200x100?text=ThitoHomes)

## 📋 Overview

ThitoHomes is a comprehensive real estate management web application built with React and Vite. It leverages AWS Amplify for deployment and Supabase for authentication, database, and storage solutions. The platform provides an intuitive interface for property management, tenant tracking, financial analytics, and maintenance request handling.

[![AWS Amplify](https://img.shields.io/badge/AWS%20Amplify-FF9900?style=for-the-badge&logo=aws-amplify&logoColor=white)](https://aws.amazon.com/amplify/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Vite](https://img.shields.io/badge/Vite-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.io/)

## ✨ Features

### Property Management
- Property listing and search functionality
- Detailed property information tracking
- Photo and document management for each property
- Property status tracking (available, occupied, under maintenance)

### Tenant Management
- Tenant profiles with contact information
- Lease tracking and management
- Rent payment history
- Document storage for leases and related paperwork

### Financial Management
- Rent collection and tracking
- Expense tracking by property
- Income and expense reporting
- Financial analytics and forecasting

### Maintenance Requests
- Tenant maintenance request submission
- Request tracking and status updates
- Assigning maintenance tasks to service providers
- Maintenance history by property

### Reporting & Analytics
- Occupancy rate tracking
- Financial performance metrics
- Maintenance cost analysis
- Custom report generation

### User Roles
- Property Owner/Manager dashboard
- Tenant portal with limited access
- Admin capabilities for system management

## 🛠️ Technology Stack

### Frontend
- **React**: UI library for building the user interface
- **Vite**: Next-generation frontend tooling
- **React Router**: For application routing
- **CSS Modules**: For component-scoped styling

### Backend & Infrastructure
- **Supabase Auth**: For user authentication and authorization
- **Supabase Database**: PostgreSQL database for data storage
- **Supabase Storage**: For file and image storage
- **AWS Amplify**: For application deployment and hosting

## 📁 Project Structure

```
src/
├── api/
│   └── supabase/
│       └── supabase.js         # Supabase client configuration
├── assets/
│   └── react.svg               # Static assets
├── components/
│   └── property.jsx            # Reusable property component
├── pages/
│   ├── components/             # Page-specific components
│   │   ├── property.jsx
│   │   └── ui/                 # UI components
│   ├── styles/                 # CSS stylesheets for pages
│   │   ├── add-property.css
│   │   ├── dashboard.css
│   │   ├── financial-management.css
│   │   ├── home_page.css
│   │   ├── maintenance-requests.css
│   │   ├── property-management.css
│   │   ├── report_analytics.css
│   │   ├── tenant-dashboard.css
│   │   └── tenant-management.css
│   ├── dashboard.jsx           # Main dashboard page
│   ├── financial-management.jsx # Financial management page
│   ├── home_page.jsx           # Landing page
│   ├── login_page.jsx          # Authentication page
│   ├── maintenance-requests.jsx # Maintenance request management
│   ├── property-managment.jsx  # Property management page
│   ├── report_analytics.jsx    # Reporting and analytics page
│   ├── signup_page.jsx         # User registration page
│   ├── tenant-dashboard.jsx    # Tenant-specific dashboard
│   └── tenant-management.jsx   # Tenant management for property managers
├── App.jsx                     # Main application component
├── index.css                   # Global styles
└── main.jsx                    # Application entry point
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn package manager
- Supabase account
- AWS account (for Amplify deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/thito-homes.git
   cd thito-homes
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Configure Supabase**
   - Create a `.env` file in the root directory
   - Add your Supabase URL and anon key:
     ```
     VITE_SUPABASE_URL=your_supabase_url
     VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Start the development server**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

5. **Open your browser**
   - Navigate to `http://localhost:5173`

### Supabase Database Setup

1. **Create the following tables in your Supabase project:**
   - `properties`
   - `tenants`
   - `leases`
   - `maintenance_requests`
   - `transactions`
   - `users`

2. **Set up storage buckets:**
   - `property-images`
   - `documents`
   - `profile-pictures`

### Deployment with AWS Amplify

1. **Install AWS Amplify CLI**
   ```bash
   npm install -g @aws-amplify/cli
   amplify configure
   ```

2. **Initialize Amplify in your project**
   ```bash
   amplify init
   ```

3. **Add hosting**
   ```bash
   amplify add hosting
   ```

4. **Deploy the application**
   ```bash
   amplify publish
   ```

## 🧪 Testing

```bash
# Run unit tests
npm run test

# Run end-to-end tests
npm run test:e2e
```

## 📊 Database Schema

### Properties Table
```sql
CREATE TABLE properties (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip TEXT NOT NULL,
  bedrooms INTEGER NOT NULL,
  bathrooms NUMERIC(2,1) NOT NULL,
  square_feet INTEGER NOT NULL,
  rent_amount NUMERIC(10,2) NOT NULL,
  status TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  owner_id UUID REFERENCES users(id)
);
```

### Tenants Table
```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  emergency_contact TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id)
);
```

### Leases Table
```sql
CREATE TABLE leases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id),
  tenant_id UUID REFERENCES tenants(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  rent_amount NUMERIC(10,2) NOT NULL,
  security_deposit NUMERIC(10,2) NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🔐 Authentication Flow

ThitoHomes uses Supabase Auth for authentication, providing:

1. **Email/Password Authentication**
2. **Social Login** (Google, Facebook)
3. **Magic Link Authentication**
4. **Role-based Access Control**:
   - Admin
   - Property Manager
   - Tenant

## 🔄 API Integration

### Supabase API
ThitoHomes integrates with Supabase for data operations:

```javascript
// Sample code from api/supabase/supabase.js
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

## 📱 Responsive Design

ThitoHomes is designed to be fully responsive across devices:
- Mobile-first approach
- Adaptive layouts
- Touch-friendly interface
- Optimized for tablets and desktops

## 🧩 Core Components

### PropertyCard
```jsx
// Sample code from components/property.jsx
import React from 'react';
import './property.css';

const PropertyCard = ({ property }) => {
  const { title, address, bedrooms, bathrooms, rent_amount, image_url } = property;
  
  return (
    <div className="property-card">
      <div className="property-image">
        <img src={image_url || 'default-property.jpg'} alt={title} />
      </div>
      <div className="property-details">
        <h3>{title}</h3>
        <p>{address}</p>
        <div className="property-features">
          <span>{bedrooms} BD</span>
          <span>{bathrooms} BA</span>
        </div>
        <div className="property-price">${rent_amount}/month</div>
      </div>
    </div>
  );
};

export default PropertyCard;
```

## 🔒 Security Considerations

- **Data Encryption**: All sensitive data is encrypted at rest and in transit
- **Input Validation**: Comprehensive validation for all user inputs
- **Authentication**: Secure token-based authentication
- **Role-Based Access**: Strict access controls based on user roles
- **CORS Configuration**: Proper CORS settings to prevent unauthorized access

## 🔄 Continuous Integration/Deployment

### GitHub Actions Workflow
```yaml
name: ThitoHomes CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '16'
        
    - name: Install dependencies
      run: npm ci
        
    - name: Run tests
      run: npm test
        
    - name: Build
      run: npm run build
      
    - name: Deploy to AWS Amplify
      if: github.ref == 'refs/heads/main'
      uses: ambientlight/amplify-cli-action@0.3.0
      with:
        amplify_command: publish
        amplify_env: production
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: us-east-1
```

## 📈 Future Roadmap

### Phase 1 (Current)
- Core property management functionality
- Basic tenant management
- Simple financial tracking

### Phase 2 (Upcoming)
- Advanced financial reporting
- Document e-signing integration
- Mobile application development

### Phase 3 (Future)
- AI-powered rent pricing optimization
- Integration with smart home systems
- Virtual property tours

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

ThitoHomes Team - info@thitohomes.com

Project Link: [https://github.com/your-username/thito-homes](https://github.com/your-username/thito-homes)

---

Made with ❤️ by ThitoHomes Team
