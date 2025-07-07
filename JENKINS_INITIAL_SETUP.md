# Jenkins Initial Setup Guide for macOS

## 🎉 **Jenkins Installation Complete!**

Jenkins has been successfully installed and is running on your Mac. Follow these steps to complete the initial setup.

## 🔐 **Step 1: Access Jenkins Web Interface**

1. **Open your web browser** and navigate to:
   ```
   http://localhost:8080
   ```

2. **You'll see the "Unlock Jenkins" page** with a password field.

## 🔑 **Step 2: Enter the Initial Admin Password**

Your initial admin password is:
```
2d8f8e8df38c42bd904925d54a1f6b2d
```

**Copy and paste this password** into the "Administrator password" field and click **Continue**.

## 🔌 **Step 3: Install Plugins**

You'll be presented with two options:

### Option A: Install Suggested Plugins (Recommended)
- Click **"Install suggested plugins"**
- This will install the most commonly used plugins
- Wait for the installation to complete (this may take a few minutes)

### Option B: Select Plugins to Install
- Click **"Select plugins to install"**
- Choose specific plugins you want

**For the Cypress project, we recommend using Option A** as it includes most of the plugins we need.

## 👤 **Step 4: Create First Admin User**

1. **Fill in the admin user details:**
   - **Username**: `admin` (or your preferred username)
   - **Password**: Create a strong password
   - **Confirm Password**: Re-enter your password
   - **Full Name**: Your full name
   - **Email**: Your email address

2. **Click "Save and Continue"**

## 🌐 **Step 5: Instance Configuration**

1. **Jenkins URL**: Should be `http://localhost:8080/`
2. **Click "Save and Finish"**

## 🎯 **Step 6: Install Additional Plugins for Cypress**

After completing the initial setup, install these additional plugins:

1. **Go to**: Manage Jenkins → Plugins
2. **Click "Available"** tab
3. **Search and install these plugins:**
   - **NodeJS Plugin** (for Node.js management)
   - **HTML Publisher Plugin** (for test reports)
   - **Email Extension Plugin** (for email notifications)
   - **Workspace Cleanup Plugin** (for cleaning workspaces)
   - **Timestamper Plugin** (for build logs)
   - **Build Timeout Plugin** (prevent hanging builds)

4. **Restart Jenkins** when prompted

## 🛠️ **Step 7: Configure Node.js**

1. **Go to**: Manage Jenkins → Tools
2. **Scroll to "NodeJS"** section
3. **Click "Add NodeJS"**
4. **Configure:**
   - **Name**: `NodeJS-20`
   - **Version**: Select latest Node.js 20.x.x
   - **Global npm packages**: `yarn`
5. **Click "Save"**

## 🚀 **Step 8: Create Your First Cypress Job**

1. **Click "New Item"** on the Jenkins dashboard
2. **Enter item name**: `cypress-realworld-app-daily`
3. **Select "Pipeline"**
4. **Click "OK"**
5. **In the Pipeline section:**
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your repository URL or file path
   - **Branch**: `*/main` or `*/develop`
   - **Script Path**: `Jenkinsfile`
6. **Configure Build Triggers:**
   - Check **"Build periodically"**
   - **Schedule**: `0 2 * * *` (daily at 2 AM)
7. **Click "Save"**

## 📊 **Step 9: Test Your Setup**

1. **Run the setup script** we created earlier:
   ```bash
   ./jenkins-setup.sh
   ```

2. **Test your job** by clicking "Build Now" on your pipeline job

## 🎛️ **Jenkins Management Commands**

### Start Jenkins
```bash
brew services start jenkins-lts
```

### Stop Jenkins
```bash
brew services stop jenkins-lts
```

### Restart Jenkins
```bash
brew services restart jenkins-lts
```

### Check Jenkins Status
```bash
brew services list | grep jenkins
```

### View Jenkins Logs
```bash
brew services logs jenkins-lts
```

## 🔍 **Troubleshooting**

### If Jenkins doesn't start:
1. **Check the logs:**
   ```bash
   brew services logs jenkins-lts
   ```

2. **Check if port 8080 is available:**
   ```bash
   lsof -i :8080
   ```

3. **Restart Jenkins:**
   ```bash
   brew services restart jenkins-lts
   ```

### If you forget your admin password:
1. **Stop Jenkins:**
   ```bash
   brew services stop jenkins-lts
   ```

2. **Edit the config file:**
   ```bash
   nano ~/.jenkins/config.xml
   ```

3. **Remove the `<useSecurity>` section**

4. **Restart Jenkins and reconfigure security**

## 📁 **Important Jenkins Directories**

- **Jenkins Home**: `~/.jenkins/`
- **Jobs**: `~/.jenkins/jobs/`
- **Plugins**: `~/.jenkins/plugins/`
- **Logs**: `~/.jenkins/logs/`

## 🔐 **Security Best Practices**

1. **Use strong passwords**
2. **Enable CSRF protection**
3. **Configure proper user permissions**
4. **Regularly update Jenkins and plugins**
5. **Use HTTPS in production**

## 🎉 **Next Steps**

After completing this setup:

1. **Your Jenkins is ready!** 🎊
2. **Run your Cypress tests** using the pipeline we created
3. **Monitor your daily test runs**
4. **Configure email notifications** for test results

## 📞 **Support**

If you encounter issues:
- Check the Jenkins logs: `brew services logs jenkins-lts`
- Visit Jenkins documentation: https://www.jenkins.io/doc/
- Check our troubleshooting section in `JENKINS_SETUP.md`

---

**Jenkins is now ready to run your Cypress tests daily! 🚀** 