# Jenkins Setup Guide for Cypress Real World App

This guide will help you set up Jenkins to run your Cypress Real World App tests on a daily basis.

## 🚀 Quick Start

1. **Run the setup script:**
   ```bash
   chmod +x jenkins-setup.sh
   ./jenkins-setup.sh
   ```

2. **Create a new Jenkins Pipeline job using the provided `Jenkinsfile`**

3. **Configure the job to run daily at 2 AM**

## 📋 Prerequisites

### System Requirements
- **Node.js**: Version 20 or higher
- **Yarn**: Package manager
- **Jenkins**: 2.400+ with Pipeline plugin
- **Git**: For repository access

### Jenkins Plugins Required
Install these plugins in Jenkins (Manage Jenkins → Plugins → Available):

1. **Pipeline** - Core pipeline functionality
2. **NodeJS Plugin** - Node.js environment management
3. **HTML Publisher Plugin** - For test reports
4. **Email Extension Plugin** - For notifications
5. **Workspace Cleanup Plugin** - Clean workspace after builds
6. **Timestamper Plugin** - Add timestamps to console output
7. **Build Timeout Plugin** - Prevent hanging builds

## 🔧 Setup Instructions

### Step 1: Install Required Plugins

1. Go to **Manage Jenkins** → **Plugins**
2. Click **Available** tab
3. Search and install the plugins listed above
4. Restart Jenkins when prompted

### Step 2: Configure Node.js

1. Go to **Manage Jenkins** → **Tools**
2. Scroll to **NodeJS** section
3. Click **Add NodeJS**
4. Configure:
   - **Name**: `NodeJS-20`
   - **Version**: `20.x.x` (latest stable)
   - **Global npm packages**: `yarn`
5. Save configuration

### Step 3: Set Up Credentials

If you're using Cypress Cloud for test recording:

1. Go to **Manage Jenkins** → **Credentials**
2. Click **System** → **Global credentials**
3. Add these credentials:
   - **cypress-project-id**: Your Cypress Project ID
   - **cypress-record-key**: Your Cypress Record Key

### Step 4: Create the Jenkins Job

1. **Create New Item**
   - Name: `cypress-realworld-app-daily`
   - Type: **Pipeline**
   - Click **OK**

2. **Configure the Pipeline**
   - **Pipeline Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your repository URL
   - **Branch**: `*/main` or `*/develop`
   - **Script Path**: `Jenkinsfile`

3. **Configure Build Triggers**
   - Check **Build periodically**
   - **Schedule**: `0 2 * * *` (daily at 2 AM)

4. **Save** the configuration

### Step 5: Configure Email Notifications

1. Go to **Manage Jenkins** → **System**
2. Scroll to **Extended E-mail Notification**
3. Configure SMTP settings:
   ```
   SMTP server: your-smtp-server.com
   Default user e-mail suffix: @your-domain.com
   ```
4. Set up authentication if required
5. Save configuration

## 📁 File Structure

After running the setup script, you'll have:

```
cypress-realworld-app/
├── Jenkinsfile                    # Main pipeline configuration
├── jenkins-setup.sh              # Setup script
├── run-tests.sh                  # Test execution script
├── jenkins-job-config.xml        # Job configuration template
├── .env.jenkins                  # Environment variables template
├── cypress/
│   ├── results/                  # Test results directory
│   │   ├── api/
│   │   ├── ui-chrome/
│   │   ├── ui-chrome-mobile/
│   │   └── component/
│   ├── screenshots/              # Test screenshots
│   └── videos/                   # Test recordings
└── JENKINS_SETUP.md             # This guide
```

## 🧪 Test Execution

### What Tests Are Run

The Jenkins pipeline runs the following test suites:

1. **Unit Tests** - Component unit tests using Vitest
2. **API Tests** - Backend API endpoint tests
3. **UI Tests (Chrome)** - End-to-end UI tests in Chrome
4. **UI Tests (Chrome Mobile)** - Mobile viewport UI tests
5. **Component Tests** - React component tests

### Test Execution Flow

1. **Setup** - Install dependencies and verify environment
2. **Lint & Type Check** - Code quality checks
3. **Build** - Build the application
4. **Parallel Test Execution**:
   - API tests run against the backend
   - UI tests run against the full application
   - Component tests run in isolation

### Test Results

After each run, Jenkins will:
- Archive test screenshots and videos
- Generate HTML test reports
- Send email notifications
- Clean up the workspace

## 🔗 Accessing Test Results

### In Jenkins UI
1. Go to your job → **Build History**
2. Click on a build number
3. View **Test Reports** and **Artifacts**

### HTML Reports
- **API Test Results**: Available in build artifacts
- **UI Test Results**: Available in build artifacts
- **Component Test Results**: Available in build artifacts

## 🛠️ Troubleshooting

### Common Issues

#### 1. Node.js Version Issues
```bash
# Check Node.js version in Jenkins
node --version

# If wrong version, configure NodeJS tool in Jenkins
```

#### 2. Permission Issues
```bash
# Make scripts executable
chmod +x jenkins-setup.sh
chmod +x run-tests.sh
```

#### 3. Port Conflicts
```bash
# Check if ports are in use
lsof -i :3000
lsof -i :3001

# Kill processes if needed
pkill -f "node.*backend/app.ts"
pkill -f "vite"
```

#### 4. Cypress Installation Issues
```bash
# Clear Cypress cache
yarn cypress cache clear

# Reinstall Cypress
yarn cypress install
```

### Debug Mode

To run tests in debug mode locally:
```bash
# Enable debug logging
export DEBUG=cypress:*

# Run tests with verbose output
yarn cypress run --headless --spec "cypress/tests/ui/*" --config video=true
```

## 📊 Monitoring and Reporting

### Daily Reports
- Email notifications sent to configured recipients
- Test results archived in Jenkins
- Screenshots and videos saved for failed tests

### Metrics to Track
- **Test Pass Rate**: Percentage of tests passing
- **Test Duration**: Time taken for each test suite
- **Build Frequency**: Number of daily builds
- **Failure Trends**: Patterns in test failures

## 🔄 Maintenance

### Regular Tasks
1. **Update Dependencies**: Monthly dependency updates
2. **Cypress Updates**: Keep Cypress updated
3. **Plugin Updates**: Update Jenkins plugins
4. **Cleanup**: Remove old build artifacts

### Scaling
- **Parallel Execution**: Increase parallel containers
- **Distributed Testing**: Use multiple Jenkins agents
- **Cloud Testing**: Integrate with Cypress Cloud

## 🎯 Best Practices

1. **Environment Isolation**: Use containers for consistent environments
2. **Test Stability**: Implement proper waits and retries
3. **Resource Management**: Clean up processes after tests
4. **Monitoring**: Set up alerts for failed builds
5. **Documentation**: Keep test documentation updated

## 📧 Support

For issues with:
- **Cypress**: Check [Cypress Documentation](https://docs.cypress.io/)
- **Jenkins**: Check [Jenkins Documentation](https://www.jenkins.io/doc/)
- **This Setup**: Review logs and troubleshooting section

## 🔗 Useful Links

- [Cypress Real World App Repository](https://github.com/cypress-io/cypress-realworld-app)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Cypress Best Practices](https://docs.cypress.io/guides/references/best-practices)

---

**Happy Testing! 🧪✨** 