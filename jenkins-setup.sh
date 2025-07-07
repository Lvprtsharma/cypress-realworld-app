#!/bin/bash

# Jenkins Setup Script for Cypress Real World App
# This script helps set up the necessary environment for running Cypress tests in Jenkins

echo "🚀 Setting up Jenkins environment for Cypress Real World App..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Jenkins is running
print_step "Checking Jenkins Status"
if ! pgrep -x "jenkins" > /dev/null && ! pgrep -f "jenkins.war" > /dev/null; then
    print_warning "Jenkins doesn't appear to be running. Please start Jenkins first."
    echo "You can start Jenkins with: sudo systemctl start jenkins"
    echo "Or if using war file: java -jar jenkins.war"
fi

# Create necessary directories
print_step "Creating Directory Structure"
mkdir -p cypress/results/api
mkdir -p cypress/results/ui-chrome  
mkdir -p cypress/results/ui-chrome-mobile
mkdir -p cypress/results/component
mkdir -p cypress/screenshots
mkdir -p cypress/videos
print_success "Directory structure created"

# Check Node.js version
print_step "Checking Node.js Version"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    print_success "Node.js version: $NODE_VERSION"
    
    # Check if version is >= 20
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -lt "20" ]; then
        print_warning "Node.js version should be >= 20. Current version: $NODE_VERSION"
        echo "Consider upgrading Node.js for better compatibility."
    fi
else
    print_error "Node.js is not installed. Please install Node.js 20 or higher."
fi

# Check Yarn
print_step "Checking Yarn"
if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn -v)
    print_success "Yarn version: $YARN_VERSION"
else
    print_warning "Yarn is not installed. Installing globally..."
    npm install -g yarn
fi

# Install dependencies
print_step "Installing Dependencies"
if [ -f "package.json" ]; then
    print_success "package.json found, installing dependencies..."
    yarn install --frozen-lockfile
    print_success "Dependencies installed"
else
    print_error "package.json not found. Make sure you're in the correct directory."
fi

# Install Cypress
print_step "Setting up Cypress"
yarn cypress install
yarn cypress verify
print_success "Cypress installed and verified"

# Create test script
print_step "Creating Test Scripts"
cat > run-tests.sh << 'EOF'
#!/bin/bash

# Cypress Test Runner Script
# This script runs all tests in sequence

echo "🧪 Starting Cypress Test Suite..."

# Set environment variables
export NODE_ENV=test
export CYPRESS_CACHE_FOLDER=".cypress-cache"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to cleanup processes
cleanup() {
    echo "Cleaning up processes..."
    pkill -f "node.*backend/app.ts" || true
    pkill -f "vite" || true
    sleep 2
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Run tests
print_step "Running Unit Tests"
yarn test:unit:ci
if [ $? -eq 0 ]; then
    print_success "Unit tests passed"
else
    print_error "Unit tests failed"
fi

print_step "Building Application"
yarn build:ci
if [ $? -eq 0 ]; then
    print_success "Build successful"
else
    print_error "Build failed"
fi

print_step "Running API Tests"
yarn start:ci &
API_PID=$!
echo "API server started with PID: $API_PID"

# Wait for server to be ready
sleep 30

yarn test:api
API_TEST_RESULT=$?

# Kill API server
kill $API_PID || true
sleep 2

if [ $API_TEST_RESULT -eq 0 ]; then
    print_success "API tests passed"
else
    print_error "API tests failed"
fi

print_step "Running UI Tests"
yarn start:ci &
APP_PID=$!
echo "Application started with PID: $APP_PID"

# Wait for application to be ready
sleep 45

# Run Chrome tests
yarn cypress run --browser chrome --spec "cypress/tests/ui/*"
UI_TEST_RESULT=$?

# Kill application
kill $APP_PID || true
sleep 2

if [ $UI_TEST_RESULT -eq 0 ]; then
    print_success "UI tests passed"
else
    print_error "UI tests failed"
fi

print_step "Test Summary"
echo "================================"
echo "Unit Tests: $([ $? -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")"
echo "API Tests: $([ $API_TEST_RESULT -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")"
echo "UI Tests: $([ $UI_TEST_RESULT -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")"
echo "================================"

# Exit with error if any test failed
if [ $API_TEST_RESULT -ne 0 ] || [ $UI_TEST_RESULT -ne 0 ]; then
    exit 1
fi

print_success "All tests completed successfully!"
EOF

chmod +x run-tests.sh
print_success "Test script created: run-tests.sh"

# Create Jenkins job configuration helper
print_step "Creating Jenkins Configuration Helper"
cat > jenkins-job-config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <actions>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin="pipeline-model-definition"/>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin="pipeline-model-definition">
      <jobProperties/>
      <triggers/>
      <parameters/>
      <options/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
  </actions>
  <description>Cypress Real World App - Daily Test Suite</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <hudson.triggers.TimerTrigger>
          <spec>0 2 * * *</spec>
        </hudson.triggers.TimerTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cfs">
    <script>
pipeline {
    agent any
    
    triggers {
        cron('0 2 * * *')
    }
    
    environment {
        NODE_VERSION = '20'
        CYPRESS_CACHE_FOLDER = "${WORKSPACE}/.cypress-cache"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh './jenkins-setup.sh'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh './run-tests.sh'
            }
        }
    }
    
    post {
        always {
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'cypress/results',
                reportFiles: '**/*.html',
                reportName: 'Cypress Test Results'
            ])
            
            archiveArtifacts artifacts: 'cypress/screenshots/**/*', fingerprint: true, allowEmptyArchive: true
            archiveArtifacts artifacts: 'cypress/videos/**/*', fingerprint: true, allowEmptyArchive: true
        }
        
        success {
            echo 'Tests completed successfully!'
        }
        
        failure {
            echo 'Tests failed!'
        }
    }
}
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

print_success "Jenkins job configuration created: jenkins-job-config.xml"

# Create environment file template
print_step "Creating Environment Template"
cat > .env.jenkins << 'EOF'
# Jenkins Environment Variables for Cypress Real World App
# Copy this file to .env.local and configure your actual values

# Database
SEED_DEFAULT_USER_PASSWORD=s3cret

# Pagination
PAGINATION_PAGE_SIZE=25

# Auth0 Configuration (if using Auth0)
AUTH0_USERNAME=your-auth0-username
AUTH0_PASSWORD=your-auth0-password
VITE_AUTH0_DOMAIN=your-auth0-domain
VITE_AUTH0_CLIENTID=your-auth0-client-id

# Okta Configuration (if using Okta)
OKTA_USERNAME=your-okta-username
OKTA_PASSWORD=your-okta-password
VITE_OKTA_DOMAIN=your-okta-domain
VITE_OKTA_CLIENTID=your-okta-client-id

# AWS Cognito Configuration (if using Cognito)
AWS_COGNITO_USERNAME=your-cognito-username
AWS_COGNITO_PASSWORD=your-cognito-password
AWS_COGNITO_DOMAIN=your-cognito-domain

# Google Configuration (if using Google)
GOOGLE_REFRESH_TOKEN=your-google-refresh-token
VITE_GOOGLE_CLIENTID=your-google-client-id
VITE_GOOGLE_CLIENT_SECRET=your-google-client-secret

# Cypress Configuration
CYPRESS_PROJECT_ID=your-cypress-project-id
CYPRESS_RECORD_KEY=your-cypress-record-key
EOF

print_success "Environment template created: .env.jenkins"

print_step "Setup Complete!"
echo
echo "📋 Next Steps:"
echo "1. Configure Jenkins credentials for Cypress Cloud (if using)"
echo "2. Install required Jenkins plugins:"
echo "   - Pipeline"
echo "   - NodeJS"
echo "   - HTML Publisher"
echo "   - Email Extension"
echo "   - Workspace Cleanup"
echo
echo "3. Create a new Pipeline job in Jenkins"
echo "4. Use the Jenkinsfile in this directory as the pipeline script"
echo "5. Configure email notifications in Jenkins"
echo "6. Set up your environment variables in .env.local"
echo
echo "🎯 Jenkins Job Configuration:"
echo "- Job Type: Pipeline"
echo "- Pipeline Script: Use Jenkinsfile from repository"
echo "- Build Triggers: Schedule (0 2 * * * for daily at 2 AM)"
echo
echo "✅ You can now run tests with: ./run-tests.sh"
echo "✅ Or set up the Jenkins job to run automatically!" 