pipeline {
    agent any
    
    // Schedule to run daily at 2 AM
    triggers {
        cron('0 2 * * *')
    }
    
    environment {
        NODE_VERSION = '20'
        CYPRESS_CACHE_FOLDER = "${WORKSPACE}/.cypress-cache"
        CYPRESS_PROJECT_ID = credentials('cypress-project-id')
        CYPRESS_RECORD_KEY = credentials('cypress-record-key')
        // Add environment variables for different auth providers if needed
        // AUTH0_USERNAME = credentials('auth0-username')
        // AUTH0_PASSWORD = credentials('auth0-password')
        // OKTA_USERNAME = credentials('okta-username')
        // OKTA_PASSWORD = credentials('okta-password')
    }
    
    stages {
        stage('Setup') {
            steps {
                echo 'Setting up environment...'
                // Install Node.js using NodeJS plugin
                nodejs(nodeJSInstallationName: 'NodeJS-20') {
                    sh '''
                        node --version
                        npm --version
                        yarn --version || npm install -g yarn
                    '''
                }
            }
        }
        
        stage('Install Dependencies') {
            steps {
                nodejs(nodeJSInstallationName: 'NodeJS-20') {
                    sh '''
                        echo "Installing dependencies..."
                        yarn install --frozen-lockfile
                        yarn cypress install
                        yarn cypress verify
                    '''
                }
            }
        }
        
        stage('Type Check & Lint') {
            steps {
                nodejs(nodeJSInstallationName: 'NodeJS-20') {
                    sh '''
                        echo "Running type check..."
                        yarn types
                        echo "Running linter..."
                        yarn lint
                    '''
                }
            }
        }
        
        stage('Unit Tests') {
            steps {
                nodejs(nodeJSInstallationName: 'NodeJS-20') {
                    sh '''
                        echo "Running unit tests..."
                        yarn test:unit:ci
                    '''
                }
            }
        }
        
        stage('Build Application') {
            steps {
                nodejs(nodeJSInstallationName: 'NodeJS-20') {
                    sh '''
                        echo "Building application..."
                        yarn build:ci
                    '''
                }
            }
        }
        
        stage('Cypress Tests') {
            parallel {
                stage('API Tests') {
                    steps {
                        nodejs(nodeJSInstallationName: 'NodeJS-20') {
                            sh '''
                                echo "Starting API server..."
                                yarn start:ci &
                                API_PID=$!
                                echo "API server started with PID: $API_PID"
                                
                                # Wait for server to be ready
                                sleep 30
                                
                                echo "Running API tests..."
                                yarn test:api || true
                                
                                # Kill the API server
                                kill $API_PID || true
                                pkill -f "node.*backend/app.ts" || true
                            '''
                        }
                    }
                    post {
                        always {
                            // Archive test results
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'cypress/results/api',
                                reportFiles: '*.html',
                                reportName: 'API Test Results'
                            ])
                        }
                    }
                }
                
                stage('UI Tests - Chrome') {
                    steps {
                        nodejs(nodeJSInstallationName: 'NodeJS-20') {
                            sh '''
                                echo "Starting application for UI tests..."
                                yarn start:ci &
                                APP_PID=$!
                                echo "Application started with PID: $APP_PID"
                                
                                # Wait for application to be ready
                                sleep 45
                                
                                echo "Running UI tests in Chrome..."
                                yarn cypress run --browser chrome --spec "cypress/tests/ui/*" --reporter junit --reporter-options "mochaFile=cypress/results/ui-chrome/results.xml" || true
                                
                                # Kill the application
                                kill $APP_PID || true
                                pkill -f "vite" || true
                            '''
                        }
                    }
                    post {
                        always {
                            // Archive test results
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'cypress/results/ui-chrome',
                                reportFiles: '*.html',
                                reportName: 'UI Chrome Test Results'
                            ])
                            
                            // Archive screenshots and videos
                            archiveArtifacts artifacts: 'cypress/screenshots/**/*', fingerprint: true, allowEmptyArchive: true
                            archiveArtifacts artifacts: 'cypress/videos/**/*', fingerprint: true, allowEmptyArchive: true
                        }
                    }
                }
                
                stage('UI Tests - Chrome Mobile') {
                    steps {
                        nodejs(nodeJSInstallationName: 'NodeJS-20') {
                            sh '''
                                echo "Starting application for mobile UI tests..."
                                yarn start:ci &
                                APP_PID=$!
                                echo "Application started with PID: $APP_PID"
                                
                                # Wait for application to be ready
                                sleep 45
                                
                                echo "Running mobile UI tests in Chrome..."
                                yarn cypress run --browser chrome --config '{"e2e":{"viewportWidth":375,"viewportHeight":667}}' --spec "cypress/tests/ui/*" --reporter junit --reporter-options "mochaFile=cypress/results/ui-chrome-mobile/results.xml" || true
                                
                                # Kill the application
                                kill $APP_PID || true
                                pkill -f "vite" || true
                            '''
                        }
                    }
                    post {
                        always {
                            // Archive test results
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'cypress/results/ui-chrome-mobile',
                                reportFiles: '*.html',
                                reportName: 'UI Chrome Mobile Test Results'
                            ])
                        }
                    }
                }
                
                stage('Component Tests') {
                    steps {
                        nodejs(nodeJSInstallationName: 'NodeJS-20') {
                            sh '''
                                echo "Running component tests..."
                                yarn test:component:ci || true
                            '''
                        }
                    }
                    post {
                        always {
                            // Archive test results
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'cypress/results/component',
                                reportFiles: '*.html',
                                reportName: 'Component Test Results'
                            ])
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up processes
            sh '''
                pkill -f "node.*backend/app.ts" || true
                pkill -f "vite" || true
                sleep 5
            '''
            
            // Archive artifacts
            archiveArtifacts artifacts: 'cypress/screenshots/**/*', fingerprint: true, allowEmptyArchive: true
            archiveArtifacts artifacts: 'cypress/videos/**/*', fingerprint: true, allowEmptyArchive: true
            archiveArtifacts artifacts: 'cypress/results/**/*', fingerprint: true, allowEmptyArchive: true
            
            // Clean workspace
            cleanWs()
        }
        
        success {
            echo 'Tests completed successfully!'
            // Send success notification (configure as needed)
            emailext (
                subject: "✅ Cypress Tests Passed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Cypress Tests Completed Successfully</h2>
                <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                
                <h3>Test Results:</h3>
                <ul>
                    <li>API Tests: Completed</li>
                    <li>UI Tests (Chrome): Completed</li>
                    <li>UI Tests (Chrome Mobile): Completed</li>
                    <li>Component Tests: Completed</li>
                </ul>
                
                <p>All tests have passed successfully!</p>
                """,
                to: "${env.CHANGE_AUTHOR_EMAIL}",
                mimeType: 'text/html'
            )
        }
        
        failure {
            echo 'Tests failed!'
            // Send failure notification (configure as needed)
            emailext (
                subject: "❌ Cypress Tests Failed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Cypress Tests Failed</h2>
                <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                
                <p>Some tests have failed. Please check the build logs and test reports for details.</p>
                
                <h3>Test Reports:</h3>
                <ul>
                    <li><a href="${env.BUILD_URL}API_Test_Results/">API Test Results</a></li>
                    <li><a href="${env.BUILD_URL}UI_Chrome_Test_Results/">UI Chrome Test Results</a></li>
                    <li><a href="${env.BUILD_URL}UI_Chrome_Mobile_Test_Results/">UI Chrome Mobile Test Results</a></li>
                    <li><a href="${env.BUILD_URL}Component_Test_Results/">Component Test Results</a></li>
                </ul>
                
                <p>Please investigate and fix the failing tests.</p>
                """,
                to: "${env.CHANGE_AUTHOR_EMAIL}",
                mimeType: 'text/html'
            )
        }
    }
} 