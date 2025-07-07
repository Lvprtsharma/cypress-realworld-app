pipeline {
    agent any
    
    environment {
        CI = 'true'
        CYPRESS_CACHE_FOLDER = "${WORKSPACE}/.cypress-cache"
        NODE_ENV = 'test'
        DATABASE_URL = 'file:./data/database.db'
        PORT = '3000'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'develop',
                    url: 'https://github.com/Lvprtsharma/cypress-realworld-app.git'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }
        
        stage('Build Application') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Database Setup') {
            steps {
                sh 'npm run db:seed'
            }
        }
        
        stage('Start Application') {
            steps {
                script {
                    // Start the application in background
                    sh 'npm start &'
                    
                    // Wait for application to be ready
                    sh 'npx wait-on http://localhost:3000 --timeout 60000'
                }
            }
        }
        
        stage('Run Cypress Tests') {
            parallel {
                stage('E2E Tests') {
                    steps {
                        sh 'npm run cypress:run'
                    }
                }
                
                stage('Component Tests') {
                    steps {
                        sh 'npm run cypress:run:component'
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Archive test results
            archiveArtifacts artifacts: 'cypress/videos/**/*.mp4', allowEmptyArchive: true
            archiveArtifacts artifacts: 'cypress/screenshots/**/*.png', allowEmptyArchive: true
            
            // Publish test results
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'cypress/reports',
                reportFiles: 'index.html',
                reportName: 'Cypress Test Report'
            ])
            
            // Clean up processes
            sh 'pkill -f "npm start" || true'
            sh 'pkill -f "node.*server" || true'
        }
        
        failure {
            emailext (
                subject: "Jenkins Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}