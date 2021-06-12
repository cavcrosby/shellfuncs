freeStyleJob ('shellfuncs') {
    
    /*
    #   For Job-DSL API reference see: https://jenkinsci.github.io/job-dsl-plugin/
    #  
    #   The following bindings will need to be added manually to shellfuncs 
    #   job/project configuration.
    #   Username variable/password variable respectfully:
    #   JENKINS_GITHUB_CREDENTIAL_USERNAME 
    #   JENKINS_GITHUB_CREDENTIAL_SECRET
    #
    */

    // Allows Jenkins to schedule and execute multiple builds concurrently.
    concurrentBuild(false) 

    logRotator {
        numToKeep(5)
        artifactNumToKeep(5)
    }

    // Allows to parameterize the job. 
    parameters {
        // Defines a simple text parameter, where users can enter a string value.
        stringParam('GIT_TAG', '', 'Insert if you wish to test shellfuncs from a given commit/tag instead of the tip from the default branch.')
    }

    // Allows a job to check out sources from an SCM provider. 
    scm {
        git {
            remote {
                // a shorten tenary operator...the elvis operator!
                // https://groovy-lang.org/operators.html#_elvis_operator
                // NOTE: aside, this is also a job binding but should not conflict
                credentials(System.getenv('JENKINS_GITHUB_CREDENTIAL_ID') ?: '')
                url('https://github.com/cavcrosby/shellfuncs')
            }
            branch('main')
        }
    }

    // Adds build triggers to the job.
    triggers {
        // Polls SCM/VCS for changes in a cron like fashion.
        scm('H/5 * * * *')
    }

    // Adds pre/post actions to the job. 
    wrappers {
        // Binds environment variables to credentials.
        credentialsBinding {
            usernamePassword {
                /* 
                    Name of an environment variable to be set 
                    to the username during the build.
                */
                usernameVariable("JENKINS_GITHUB_CREDENTIAL_USERNAME ")
                /* 
                    Name of an environment variable to be set 
                    to the password during the build.
                */
                passwordVariable("JENKINS_GITHUB_CREDENTIAL_SECRET")
                // Credentials of an appropriate type to be set to the variable.
                credentialsId(System.getenv('JENKINS_GITHUB_CREDENTIAL_ID') ?: '')
            }
        }

        // deletes friles from the workspace before the build starts
        preBuildCleanup()

        /* 
            defines an absolute timeout with a maximum 
            build time of one hour and thirty minutes
        */
        timeout {
            absolute(90)
        }
    }

    steps {
        // Runs a shell script. 
        shell(readFileFromWorkspace('./jenkins/build'))
    }

    // Adds post-build actions to the job.
    publishers {
        /* 
            If configured, Jenkins will send out an e-mail to 
            the specified recipients when a certain important event occurs. 
        */
        mailer {
            recipients('conner@cavcrosby.tech')
            notifyEveryUnstableBuild(true)
            /* 
                If this option is checked, the notification e-mail will be sent 
                to individuals who have committed changes for the broken build 
                (by assuming that those changes broke the build).
            */
            sendToIndividuals(false) 
        }
    }

}
