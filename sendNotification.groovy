#!/usr/bin/env groovy

/**
 * this script will send build notification into slack with email to specific email address
 * slack notifier plugin must be installed to make it work 
 * for email server you can use aspmx.l.google.com to integrate email server without SSL integration
 */

def call(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def color = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """<p>${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)

  emailext (
      to: 'user@domain.com',
      subject: subject,
      body: details,
      recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
}

// credit goes to https://github.com/bitwiseman/jenkins-pipeline-shared