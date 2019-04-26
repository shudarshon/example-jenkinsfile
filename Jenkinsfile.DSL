pipeline {
  agent any

  environment {
    MAJOR_VERSION = 1
  }

  stages {
    stage('build') {
      steps {
        sh 'make build'                
      }
      post {
        success {
          archiveArtifacts artifacts: 'artifact.jar', fingerprint: true
        }
      }
    }
    stage('test') {
      steps {
        sh 'make test'
      }
    }
    stage('Promote Development to Master') {
      when {
        branch 'development'
      }
      steps {
        echo "Stashing Local Changes"
        sh "git stash"
        echo "Checking Out Development"
        sh 'git checkout development'
        sh 'git pull origin'
        echo 'Checking Out Master'
        sh 'git checkout master'
        echo "Merging Development into Master"
        sh 'git merge development'
        echo "Git Push to Origin"
        sh 'git push origin master'
      }
      post {
        success {
          emailext(
            subject: "${env.JOB_NAME} [${env.BUILD_NUMBER}] Development Promoted to Master",
            body: """<p>'${env.JOB_NAME} [${env.BUILD_NUMBER}]' Development Promoted to Master":</p>
            <p>Check output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
            to: "user@domain.com"
          )
        }
      }
    }
    stage('Tagging the Release') {
      when {
        branch 'master'
      }
      steps {
        sh "git tag app-${env.MAJOR_VERSION}.${BUILD_NUMBER}"
        sh "git push origin app-${env.MAJOR_VERSION}.${BUILD_NUMBER}"
        sh "ls -l"
      }
      post {
        success {
          emailext(
            subject: "${env.JOB_NAME} [${env.BUILD_NUMBER}] NEW RELEASE",
            body: """<p>'${env.JOB_NAME} [${env.BUILD_NUMBER}]' NEW RELEASE":</p>
            <p>Check output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
            to: "user@domain.com"
          )
        }
      }
    }
  }
}
